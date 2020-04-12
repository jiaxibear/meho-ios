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

    // MARK: - Properties

    private let session = URLSession(configuration: .default)

    // MARK: - Public

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
                if let title = newsItemJson["title_en_US"] as? String {
                    news.title = title
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
                newsList.append(news)
            }
        }

        return newsList
    }
}
