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
    private let fetchNewsListURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/v2/news/articles/"
    private let fetchNewsDetailURLBaseString = "http://meho.us-west-2.elasticbeanstalk.com/api/v2/news/articleDetails/"
    private let fetchVocabulariesURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/v2/news/vocabularies/"
    private let fetchRecapVocabulariesURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/v2/news/vocabularies/?limit=3"

    // MARK: - Properties
    private var appSyncClient: AWSAppSyncClient?
    private let session = URLSession(configuration: .default)

    // MARK: - Init
    override init() {
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
    }

    // MARK: - GraphQL based queries
    public func fetchNewsDetail(newsID: String, completionHandler: @escaping ( Array<NewsChapter>?, Array<NewsChapter>?, Array<Vocabulary>?, Dictionary<String, Vocabulary>?, Error?) -> Void) {
        let q = GetArticleQuery(id: newsID)
        appSyncClient?.fetch(query: q) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, nil, nil, nil, error)
                return
            }
            guard let items = result?.data?.getArticle?.paragraphs?.items, items.count > 0 else {
                completionHandler(nil, nil, nil, nil, nil)
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

            guard let allVocabs = result?.data?.getArticle?.vocabularies?.items else {
                completionHandler(nil, nil, nil, nil, nil)
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

            completionHandler(enParagraphs, zhParagraphs, recabVocabs, allVocabDict, nil)
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
