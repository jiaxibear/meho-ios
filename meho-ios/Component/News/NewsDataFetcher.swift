//
//  NewsDataFetcher.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/3/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSAppSync
import AWSS3
import AWSCore

class NewsDataFetcher: NSObject {
    // MARK: - Urls for Restful APIs
    private let fetchRelatedNewsURLString = "https://9c76f3msu7.execute-api.us-west-2.amazonaws.com/dev/content/batch_get_article?ids="

    // MARK: - Properties
    private var appSyncClient: AWSAppSyncClient?
    private let session = URLSession(configuration: .default)

    // MARK: - Init
    override init() {
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
    }

    public func fetchRelatedArticleList(relatedArticleIDs: String, completionHandler: @escaping ( Array<News>?, Error?) -> Void) {

        guard let fetchRelatedNewsURL = URL.init(string: fetchRelatedNewsURLString.appending(relatedArticleIDs)) else {
            completionHandler(nil, nil)
            return
        }

        let request = URLRequest.init(url: fetchRelatedNewsURL)
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            guard data != nil else {
                completionHandler(nil, nil)
                return
            }
            do {
                if let responseDict = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any], let profileDetails = self.parseArticleRest(responseDict: responseDict) {
                    completionHandler(profileDetails, nil)
                } else {
                    completionHandler(nil, nil)
                }
            }
            catch {
                completionHandler(nil, error)
            }
        }.resume()
    }

    private func parseArticleRest(responseDict: [String: Any]) -> Array<News>? {
        var articleItems: [News] = []

        guard let newsJSONArray = responseDict["data"] as? [[String: Any]] else {
            return nil
        }
        for newsJSONObject in newsJSONArray {
            var news = News.init()
            if let coverImageDict = newsJSONObject["coverImage"] as? [String: String], let bucket = coverImageDict["bucket"], let key = coverImageDict["key"] {
                news.imageKey = S3ResourceKey.init(bucket: bucket, key: key)
            }
            if let titleEn = newsJSONObject["titleEn"] as? String {
                news.title_en = titleEn
            }
            if let titleZh = newsJSONObject["titleZh"] as? String {
                news.title_zh = titleZh
            }
            if let subtitle = newsJSONObject["whyYouShouldReadThisArticle"] as? String {
                news.reason = subtitle
            }
            if let source = newsJSONObject["sourcer"] as? String {
                news.source = source
            }
            if let identifier = newsJSONObject["id"] as? String {
                news.identifier = identifier
            }
            if let date = newsJSONObject["createdAt"] as? String {
                news.date = date
            }
            if let slug = newsJSONObject["slug"] as? String {
                news.slug = slug
            }
//            if let audioEnKey = newsJSONObject["audioEnKey"] as? String {
//                news.audioEnKey = S3ResourceKey.init(bucket: "", key: audioEnKey)
//            }
//            if let audioZhKey = newsJSONObject["audioZhKey"] as? String {
//                news.audioZhKey = S3ResourceKey.init(bucket: "", key: audioZhKey)
//            }
            news.renderType = "S"
            articleItems.append(news)

        }

        return articleItems
    }

    // MARK: - GraphQL based queries
    public func fetchNews(newsID: String, completionHandler: @escaping ( News?, Error?) -> Void) {
        let q = GetArticleQuery(id: newsID)
        appSyncClient?.fetch(query: q) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            guard let article = result?.data?.getArticle else {
                completionHandler(nil, nil)
                return
            }

            var news = News.init()
            news.identifier = article.id
            news.title_en = article.titleEn
            news.title_zh = article.titleZh
            news.reason = article.whyYouShouldReadThisArticle
            news.date = article.createdAt
            news.slug = article.slug
            if let sourcer = article.sourcer {
                news.source = sourcer
            }
            if let key = article.coverImage?.key, let bucket = article.coverImage?.bucket {
                news.imageKey = S3ResourceKey.init(bucket: bucket, key: key)
            }
            if let audioEnKey = article.audioEnKey {
                news.audioEnKey = S3ResourceKey.init(bucket: "", key: audioEnKey)
            }
            if let audioZhKey = article.audioZhKey {
                news.audioZhKey = S3ResourceKey.init(bucket: "", key: audioZhKey)
            }
            news.renderType = "S"

            completionHandler(news, nil)
        }
    }

    public func fetchNewsDetail(newsID: String, completionHandler: @escaping ( Array<NewsChapter>?, Array<NewsChapter>?, Array<Vocabulary>?, Dictionary<String, Vocabulary>?, String?, Error?) -> Void) {
        let q = GetArticleQuery(id: newsID)
        appSyncClient?.fetch(query: q) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, nil, nil, nil, nil, error)
                return
            }
            guard let items = result?.data?.getArticle?.paragraphs?.items, items.count > 0 else {
                completionHandler(nil, nil, nil, nil, nil, nil)
                return
            }
            var zhParagraphDict:Dictionary<String, NewsChapter> = [:]
            var enParagraphs:[NewsChapter] = []

            for item in items {
                guard let chapter = item else {continue}
                var newsChapter = NewsChapter.init()
                newsChapter.identifier = chapter.id
                newsChapter.language = chapter.contentType
                newsChapter.content = chapter.content
                newsChapter.seq = chapter.seqNumber
                newsChapter.videoURL = chapter.videoUrl

                if let image_key = chapter.contentImage?.key {
                    newsChapter.image_key = image_key
                }
                if let image_bucket = chapter.contentImage?.bucket {
                    newsChapter.image_bucket = image_bucket
                }

                if newsChapter.language == "EN" {
                    enParagraphs.append(newsChapter)
                } else {
                    zhParagraphDict[chapter.id] = newsChapter
                }

            }

            // TODO shall we rather degrade when vocabulary fetch were missing??
            guard let allVocabs = result?.data?.getArticle?.vocabularies?.items else {
                completionHandler(nil, nil, nil, nil, nil, nil)
                return
            }
            var recabVocabs: [Vocabulary] = []
            var recabVocabIdSet:Set<String> = []
            var allVocabDict:Dictionary<String, Vocabulary> = [:]
            for maybeArticleVocab in allVocabs {
                guard let articleVocab = maybeArticleVocab else { continue }
                guard let remoteVocab = articleVocab.vocabulary else { continue }
                var vocab = Vocabulary.init()
                vocab.identifier = remoteVocab.id
                vocab.content_en = remoteVocab.contentEn
                vocab.content_zh = remoteVocab.contentZh
                vocab.content_pinyin = remoteVocab.contentPinyin
                if let contentOptional = remoteVocab.optionContent {
                    vocab.content_optional = contentOptional
                }
                if let key = remoteVocab.audioKey {
                    vocab.audioKey = S3ResourceKey.init(bucket: "fakebucket", key: key)
                }

                if let startIndex = articleVocab.startIndex {
                    vocab.chapter_offset = startIndex
                }

                if remoteVocab.label == "MEHO_CURATED", !recabVocabIdSet.contains(vocab.identifier) {
                    recabVocabs.append(vocab)
                    recabVocabIdSet.insert(vocab.identifier)
                } else if let chapterId = articleVocab.paragraphId, zhParagraphDict[chapterId] != nil {
                    zhParagraphDict[chapterId]!.vocabularies.append(vocab)
                }

                allVocabDict[vocab.identifier] = vocab
            }

            var zhParagraphs = Array(zhParagraphDict.values)
            zhParagraphs.sort { $0.seq < $1.seq }
            enParagraphs.sort { $0.seq < $1.seq }

            var relatedArticleIDs:String?
            if let relatedArticleIDArray = result?.data?.getArticle?.relatedArticlesId, relatedArticleIDArray.count > 0 {
                var idConcatenated = ""
                for maybeArticleID in relatedArticleIDArray {
                    if let articleID = maybeArticleID {
                        idConcatenated = idConcatenated + articleID + ","
                    }
                }
                idConcatenated.removeLast()
                relatedArticleIDs = idConcatenated
            }

            completionHandler(enParagraphs, zhParagraphs, recabVocabs, allVocabDict, relatedArticleIDs, nil)
        }
    }


    public func fetchNewsList(count: String = "50", completionHandler: @escaping ( Array<News>?, Error?) -> Void) {
        let q = GetArticlesByStatusQuery()
        q.sortDirection = ModelSortDirection.desc
        q.status = "PUBLISHED"
        q.limit = 50
        appSyncClient?.fetch(query: q, cachePolicy: .fetchIgnoringCacheData) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, nil)
                return
            }
            guard let items = result?.data?.getArticlesByStatus?.items, items.count > 0 else {
                completionHandler(nil, nil)
                return
            }

            var newsList:[News] = []
            for item in items {
                guard let article = item else {continue}
                var news = News.init()
                news.identifier = article.id
                news.title_en = article.titleEn
                news.title_zh = article.titleZh
                news.reason = article.whyYouShouldReadThisArticle
                news.date = article.createdAt
                news.slug = article.slug
                if let sourcer = article.sourcer {
                    news.source = sourcer
                }
                if let key = article.coverImage?.key, let bucket = article.coverImage?.bucket {
                    news.imageKey = S3ResourceKey.init(bucket: bucket, key: key)
                }
                if let audioEnKey = article.audioEnKey {
                    news.audioEnKey = S3ResourceKey.init(bucket: "", key: audioEnKey)
                }
                if let audioZhKey = article.audioZhKey {
                    news.audioZhKey = S3ResourceKey.init(bucket: "", key: audioZhKey)
                }
                news.renderType = "S"
                newsList.append(news)
            }
            newsList[0].renderType = "L"
            completionHandler(newsList, nil)
        }
    }
}
