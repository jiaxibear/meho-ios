//
//  NewsDataFetcher.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/3/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class NewsDataFetcher: NSObject {
    // MARK: - Urls
    private let fetchNewsListURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/v2/news/articles/"
    private let fetchNewsDetailURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/v2/news/paragraphs/?limit=20"

    // MARK: - Properties

    private let session = URLSession(configuration: .default)

    // MARK: - Public

    public func fetchNewsDetail(newsID: String, completionHandler: @escaping ( Array<NewsChapter>?, Array<NewsChapter>?, Error?) -> Void) {
        if var fetchNewsDetailURLComponent = URLComponents.init(string: fetchNewsDetailURLString) {
//            let quertItem = URLQueryItem.init(name: dialogIDQueryItemName, value: dialogID)
//            fetchDetailedDialogURLComponent.queryItems = [quertItem]
            // TODO replace with real fetch news by ID
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
        if let newsChaptersJson = newsDetailJson["results"] as? [Dictionary<String, Any>] {
            for newsChapterJson in newsChaptersJson {
                var newsChapter = NewsChapter.init()
                if let content = newsChapterJson["content"] as? String {
                    newsChapter.content = content
                }
                if let language = newsChapterJson["content_type"] as? String {
                    newsChapter.language = language
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


    public func fetchNewsList(completionHandler: @escaping ( Array<News>?, Error?) -> Void) {
        if let newsListUrl = URL.init(string: fetchNewsListURLString) {
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
}
