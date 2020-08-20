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
    // MARK: - Urls
    private let fetchNewsListURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/v2/news/articles/"
    private let fetchNewsDetailURLBaseString = "http://meho.us-west-2.elasticbeanstalk.com/api/v2/news/articleDetails/"
    private let fetchVocabulariesURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/v2/news/vocabularies/"
    private let fetchRecapVocabulariesURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/v2/news/vocabularies/?limit=3"

    // MARK: - Properties
    private var appSyncClient: AWSAppSyncClient?
    private let session = URLSession(configuration: .default)
    //handles download
    var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?

    // MARK: - Init
    override init() {
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
    }

    // MARK: - GraphQL based queries
    public func fetchNewsDetail(newsID: String, completionHandler: @escaping ( Array<NewsChapter>?, Array<NewsChapter>?, Error?) -> Void) {
        let q = GetArticleQuery(id: newsID)
        appSyncClient?.fetch(query: q) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {return}
            guard let items = result?.data?.getArticle?.paragraphs?.items, items.count > 0 else { return }
            var zhParagraphs:[NewsChapter] = []
            var enParagraphs:[NewsChapter] = []

            for item in items {
                guard let chapter = item else {continue}
                var newsChapter = NewsChapter.init()
                newsChapter.identifier = chapter.id
                newsChapter.language = chapter.contentType
                newsChapter.content = chapter.content
                newsChapter.seq = chapter.seqNumber

                if let image_key = chapter.contentImage?.key {
                    newsChapter.image_key = image_key
                }
                if let image_bucket = chapter.contentImage?.bucket {
                    newsChapter.image_bucket = image_bucket
                }

                if newsChapter.language == "EN" {
                    enParagraphs.append(newsChapter)
                } else {
                    zhParagraphs.append(newsChapter)
                }

            }
            zhParagraphs.sort { $0.seq < $1.seq }
            enParagraphs.sort { $0.seq < $1.seq }

            completionHandler(enParagraphs, zhParagraphs, nil)
        }

        completionHandler(nil, nil, nil)
    }


    public func fetchNewsList(count: String = "50", completionHandler: @escaping ( Array<News>?, Error?) -> Void) {
        let q = ListArticlesQuery()
        appSyncClient?.fetch(query: q) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {return}
            guard let items = result?.data?.listArticles?.items, items.count > 0 else { return }

            var newsList:[News] = []
            for item in items {
                guard let article = item else {continue}
                var news = News.init()
                news.identifier = article.id
                news.title_en = article.titleEn
                news.title_zh = article.titleZh
                news.reason = article.whyYouShouldReadThisArticle
                if let sourcer = article.sourcer as? String {
                    news.source = sourcer
                }
                if let image_key = article.coverImage?.key {
                    news.image_key = image_key
                }
                if let image_bucket = article.coverImage?.bucket {
                    news.image_bucket = image_bucket
                }
                news.renderType = "S"
                newsList.append(news)
            }
            newsList[0].renderType = "L"
            completionHandler(newsList, nil)
        }

        completionHandler(nil, nil)
    }

    public func fetchNewsListRest(count: String = "50", completionHandler: @escaping ( Array<News>?, Error?) -> Void) {



            if var fetchNewsListURLComponent = URLComponents.init(string: fetchNewsListURLString) {
                let quertItem = URLQueryItem.init(name: "limit", value: count)
                fetchNewsListURLComponent.queryItems = [quertItem]
                if let newsListUrl = fetchNewsListURLComponent.url {
                    let dataCategoriesTask = session.dataTask(with: newsListUrl, completionHandler: { (data, URLResponse, error) in
                        if error != nil {
                            print("There is an error getting the response of news list")
                            completionHandler(nil, error)
                            return
                        }
                        if data == nil {
                            print("The response of news list is empty")
                            completionHandler(nil, nil)
                            return
                        }
                        do {
                            if let newsListJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                let newsList = self.parseNewsListJSON(newsListJson: newsListJson)
                                completionHandler(newsList, nil)
                            }
                        } catch let JSONError as NSError {
                            print("Failed to parse news list JSON: \(JSONError.localizedDescription)")
                            completionHandler(nil, JSONError)
                        }
                    })
                    dataCategoriesTask.resume()
                } else {
                    completionHandler(nil, nil)
                }
            } else {
                completionHandler(nil, nil)
            }
        }

    private func parseNewsListJSON(newsListJson: [String: Any]) -> Array<News> {

        var newsList:[News] = []
        if let newsItemsJson = newsListJson["results"] as? [Dictionary<String, Any>] {
            for newsItemJson in newsItemsJson {
                var news = News.init()
                if let title_en = newsItemJson["title_en_US"] as? String {
                    news.title_en = title_en
                }
                if let title_zh = newsItemJson["title_zh_CN"] as? String {
                    news.title_zh = title_zh
                }
                if let reason = newsItemJson["why_you_should_read_this_article"] as? String {
                    news.reason = reason
                }
                if let identifier = newsItemJson["id"] as? String {
                    news.identifier = identifier
                }
                if let renderType = newsItemJson["render_type"] as? String {
                    news.renderType = renderType
                }
                if let coverImageURLString = newsItemJson["cover_image"] as? String {
                    let coverImageURL = URL.init(string: coverImageURLString)
                    news.coverImageURL = coverImageURL
                }
                if let sourceObj = newsItemJson["source"] as? Dictionary<String, Any> {
                    if let sourceName = sourceObj["name"] as? String {
                        news.source = sourceName
                    }
                }
                newsList.append(news)
            }
        }

        return newsList
    }


    // MARK: - Rest based queries
    public func fetchNewsDetailRest(newsID: String, completionHandler: @escaping ( Array<NewsChapter>?, Array<NewsChapter>?, Error?) -> Void) {
        let fetchNewsDetailURLString = fetchNewsDetailURLBaseString + newsID
        if let fetchNewsDetailURLComponent = URLComponents.init(string: fetchNewsDetailURLString) {
            if let fetchNewsDetailURL = fetchNewsDetailURLComponent.url {
                let newsDetailDataTask = session.dataTask(with: fetchNewsDetailURL, completionHandler: { (data, URLResponse, error) in
                    if error != nil {
                        print("There is an error getting the response of the detailed dialog")
                        completionHandler(nil, nil, error)
                        return
                    }
                    if data == nil {
                        print("The response of the detailed dialog is empty")
                        completionHandler(nil, nil, nil)
                        return
                    }
                    do {
                        if let newsDetailJSON = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            let (englishNewsChapters, chineseNewsChapters) = self.parseNewsDetailJSON(newsDetailJson: newsDetailJSON)
                            completionHandler(englishNewsChapters, chineseNewsChapters, nil)
                        }
                    } catch let JSONError as NSError {
                        print("Failed to parse the detailed dialog JSON: \(JSONError.localizedDescription)")
                        completionHandler(nil, nil, JSONError)
                    }
                })
                newsDetailDataTask.resume()
            } else {
                completionHandler(nil, nil, nil)
            }
        } else {
            completionHandler(nil, nil, nil)
        }
    }

    private func parseNewsDetailJSON(newsDetailJson: [String: Any]) -> (Array<NewsChapter>, Array<NewsChapter>) {

        var englishNewsChapters:[NewsChapter] = []
        var chineseNewsChapters:[NewsChapter] = []
        if let newsChaptersJson = newsDetailJson["paragraphs"] as? [Dictionary<String, Any>] {
            for newsChapterJson in newsChaptersJson {
                var newsChapter = NewsChapter.init()
                if let language = newsChapterJson["content_type"] as? String {
                    newsChapter.language = language
                }
                if let content = newsChapterJson["content"] as? String {
                    if newsChapter.language == "en-US" {
                        newsChapter.content = content
                    }
                }
                if let content_embed_vocab = newsChapterJson["content_after_embed_vocab"] as? String {
                    if newsChapter.language == "zh-CN" {
                        newsChapter.content = content_embed_vocab
                    }
                }
                if let identifier = newsChapterJson["id"] as? String {
                    newsChapter.identifier = identifier
                }
                if let contentImageURLString = newsChapterJson["content_image"] as? String {
                    let contentImageURL = URL.init(string: contentImageURLString)
                    newsChapter.contentImageURL = contentImageURL
                }
                if newsChapter.language == "en-US" {
                    englishNewsChapters.append(newsChapter)
                } else {
                    chineseNewsChapters.append(newsChapter)
                }
            }
        }

        return (englishNewsChapters, chineseNewsChapters)
    }

    public func fetchRecapVocabularies(completionHandler: @escaping ( Array<Vocabulary>?, Error?) -> Void) {
        if let fetchRecapVocabularyListURLComponent = URLComponents.init(string: fetchRecapVocabulariesURLString) {
            if let recapVocabulariesUrl = fetchRecapVocabularyListURLComponent.url {
                let dataCategoriesTask = session.dataTask(with: recapVocabulariesUrl, completionHandler: { (data, URLResponse, error) in
                    if error != nil {
                        print("There is an error getting the response of news list")
                        completionHandler(nil, error)
                        return
                    }
                    if data == nil {
                        print("The response of news list is empty")
                        completionHandler(nil, nil)
                        return
                    }
                    do {
                        if let vocabulariesJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            let newsList = self.parseVocabularies(vocabulariesJson: vocabulariesJson)
                            completionHandler(newsList, nil)
                        }
                    } catch let JSONError as NSError {
                        print("Failed to parse news list JSON: \(JSONError.localizedDescription)")
                        completionHandler(nil, JSONError)
                    }
                })
                dataCategoriesTask.resume()
            }
        }

    }

    private func parseVocabularies(vocabulariesJson: [String: Any]) -> Array<Vocabulary> {
        var vocabularies:[Vocabulary] = []
        if let vocabularyListJson = vocabulariesJson["results"] as? [Dictionary<String, Any>] {
            for vocabularyJson in vocabularyListJson {
                let vocabulary = parseVocabulary(vocabularyJson: vocabularyJson)
                vocabularies.append(vocabulary)
            }
        }
        return vocabularies
    }

    public func fetchVocabulary(vocabularyId: String, completionHandler: @escaping ( Vocabulary?, Error?) -> Void) {
        let vocabularyUrlString = fetchVocabulariesURLString + vocabularyId
        if let fetchVocabularyURLComponent = URLComponents.init(string: vocabularyUrlString) {
            if let vocabularyUrl = fetchVocabularyURLComponent.url {
                let dataCategoriesTask = session.dataTask(with: vocabularyUrl, completionHandler: { (data, URLResponse, error) in
                    if error != nil {
                        print("There is an error getting the response of news list")
                        completionHandler(nil, error)
                        return
                    }
                    if data == nil {
                        print("The response of news list is empty")
                        completionHandler(nil, nil)
                        return
                    }
                    do {
                        if let vocabularyJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            let vocabulary = self.parseVocabulary(vocabularyJson: vocabularyJson)
                            completionHandler(vocabulary, nil)
                        }
                    } catch let JSONError as NSError {
                        print("Failed to parse news list JSON: \(JSONError.localizedDescription)")
                        completionHandler(nil, JSONError)
                    }
                })
                dataCategoriesTask.resume()
            }
        }
    }

    private func parseVocabulary(vocabularyJson: [String: Any]) -> Vocabulary {

        var vocabulary = Vocabulary.init()

        if let content_zh_pinyin = vocabularyJson["content_zh_pinyin"] as? String {
            vocabulary.content_pinyin = content_zh_pinyin
        }
        if let content_zh_CN = vocabularyJson["content_zh_CN"] as? String {
            vocabulary.content_zh = content_zh_CN
        }
        if let content_en_US = vocabularyJson["content_en_US"] as? String {
            vocabulary.content_en = content_en_US
        }
        if let optional_content = vocabularyJson["optional_content"] as? String {
            vocabulary.content_optional = optional_content
        }
        if let identifier = vocabularyJson["id"] as? String {
            vocabulary.identifier = identifier
        }
        if let pronounceURLString = vocabularyJson["pronounce"] as? String {
            let audioURL = URL.init(string: pronounceURLString)
            vocabulary.audioURL = audioURL
        }
        return vocabulary
    }
}
