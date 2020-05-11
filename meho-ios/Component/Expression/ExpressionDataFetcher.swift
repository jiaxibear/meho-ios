//
//  ExpressionDataFetcher.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/26/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ExpressionDataFetcher: NSObject {
    // MARK: - Urls
    private let fetchTrendingPhraseURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/v2/lightening/trendingPhrase/"

    // MARK: - Properties
    private let session = URLSession(configuration: .default)

    public func fetchTrendingPhrases(count: String = "5", completionHandler: @escaping ( Array<TrendingPhrase>?, Error?) -> Void) {
        if var fetchTrendingPhraseURLComponent = URLComponents.init(string: fetchTrendingPhraseURLString) {
            let quertItem = URLQueryItem.init(name: "limit", value: count)
            fetchTrendingPhraseURLComponent.queryItems = [quertItem]
            if let trendingPhraseURLString = fetchTrendingPhraseURLComponent.url {
                let dataCategoriesTask = session.dataTask(with: trendingPhraseURLString, completionHandler: { (data, URLResponse, error) in
                    if error != nil {
                        print("There is an error getting the response of news list")
                        completionHandler(nil, error)
                        return
                    }
                    if data == nil {
                        print("The response of trending phrase is empty")
                        completionHandler(nil, nil)
                        return
                    }
                    do {
                        if let phrasesJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            let phrases = self.parseTrendingPhrasesJSON(phrasesJson: phrasesJson)
                            completionHandler(phrases, nil)
                        }
                    } catch let JSONError as NSError {
                        print("Failed to parse trending phrase list JSON: \(JSONError.localizedDescription)")
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

    private func parseTrendingPhrasesJSON(phrasesJson: [String: Any]) -> Array<TrendingPhrase> {
        var trendingPhrases:[TrendingPhrase] = []
        if let phraseListJson = phrasesJson["results"] as? [Dictionary<String, Any>] {
            for phraseJson in phraseListJson {
                var phrase = TrendingPhrase.init()
                if let content = phraseJson["content"] as? String {
                    phrase.content_zh = content
                }
                if let content_pinyin = phraseJson["content_pinyin"] as? String {
                    phrase.content_pinyin = content_pinyin
                }
                if let content_explanation = phraseJson["content_explanation"] as? String {
                    phrase.content_explanation = content_explanation
                }
                if let identifier = phraseJson["id"] as? String {
                    phrase.identifier = identifier
                }
                if let audioURLString = phraseJson["content_audio"] as? String {
                    let audioUrl = URL.init(string: audioURLString)
                    phrase.audioURL = audioUrl
                }
                trendingPhrases.append(phrase)
            }
        }

        return trendingPhrases
    }
}
