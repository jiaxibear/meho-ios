//
//  ExpressionDataFetcher.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/26/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSAppSync

class ExpressionDataFetcher: NSObject {
    // MARK: - URLs
    private let fetchTrendingPhraseURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/v2/lightening/trendingPhrase/"
    private let fetchSurvivalPhraseByCategoryURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/foundation/survival/"

    // MARK: - Properties
    private var appSyncClient: AWSAppSyncClient?
    private let session = URLSession(configuration: .default)

    // MARK: - Init
    override init() {
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
    }

    public func fetchSurvivalPhrases(category: String, completionHandler: @escaping (Swift.Result<Array<Chapter>, Error>) -> Void) {
        let q = GetExpressionsByLabelQuery()
        q.label = category
        q.limit = 100
        appSyncClient?.fetch(query: q) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                print("There is an error getting the response of survival phrases")
                completionHandler(.failure(error!))
                return
            }
            guard let items = result?.data?.getExpressionsByLabel?.items, items.count > 0 else {
                print("The response of survival phrase is empty")
                completionHandler(.success([]))
                return
            }

            var chapterList:[Chapter] = []
            for maybeRemoteChapter in items {
                guard let remoteChapter = maybeRemoteChapter else { continue }
                var chapter = Chapter.init()
                chapter.identifier = remoteChapter.id
                if let contentEn = remoteChapter.contentEn {
                    chapter.contentInLocalLanguage = contentEn
                }
                if let contentPinyin = remoteChapter.contentPinyin {
                    chapter.contentPinyin = contentPinyin
                }
                if let contentInLocalLanguage = remoteChapter.contentZh {
                    chapter.content = contentInLocalLanguage
                }
                if let audioKey = remoteChapter.audio?.key {
                    chapter.contentAudioKey = audioKey
                }
                chapterList.append(chapter)
            }
            completionHandler(.success(chapterList))
        }
    }

    // MARK: - Internal
    func fetchTrendingPhrases(count: String = "5", completionHandler: @escaping ( Array<TrendingPhrase>?, Error?) -> Void) {
        if var fetchTrendingPhraseURLComponent = URLComponents.init(string: fetchTrendingPhraseURLString) {
            let quertItem = URLQueryItem.init(name: "limit", value: count)
            fetchTrendingPhraseURLComponent.queryItems = [quertItem]
            if let trendingPhraseURLString = fetchTrendingPhraseURLComponent.url {
                let dataCategoriesTask = session.dataTask(with: trendingPhraseURLString, completionHandler: { (data, URLResponse, error) in
                    if error != nil {
                        print("There is an error getting the response of tranding phrases")
                        completionHandler(nil, error)
                        return
                    }
                    if data == nil {
                        print("The response of trending phrases is empty")
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

    func fetchSurvivalPhrasesRest(category: String, completionHandler: @escaping (Swift.Result<Array<Chapter>, Error>) -> Void) {
        if var fetchTrendingPhraseURLComponent = URLComponents.init(string: fetchSurvivalPhraseByCategoryURLString) {
            let quertItem = URLQueryItem.init(name: "category", value: category)
            let limitQuertItem = URLQueryItem.init(name: "limit", value: "100")
            fetchTrendingPhraseURLComponent.queryItems = [quertItem, limitQuertItem]
            if let trendingPhraseURLString = fetchTrendingPhraseURLComponent.url {
                let dataCategoriesTask = session.dataTask(with: trendingPhraseURLString, completionHandler: { (data, URLResponse, error) in
                    if error != nil {
                        print("There is an error getting the response of survival phrases")
                        completionHandler(.failure(error!))
                        return
                    }
                    if data == nil {
                        print("The response of survival phrase is empty")
                        completionHandler(.success([]))
                        return
                    }
                    do {
                        if let phrasesJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            let phrases = self.parseSurvivalPhrasesJSON(phrasesJson: phrasesJson)
                            completionHandler(.success(phrases))
                        }
                    } catch let JSONError as NSError {
                        print("Failed to parse survival phrase list JSON: \(JSONError.localizedDescription)")
                        completionHandler(.failure(JSONError))
                    }
                })
                dataCategoriesTask.resume()
            } else {
                completionHandler(.success([]))
            }
        } else {
            completionHandler(.success([]))
        }
    }

    // MARK: - Private
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

    private func parseSurvivalPhrasesJSON(phrasesJson: [String: Any]) -> Array<Chapter> {
        var survivalPhrases:[Chapter] = []
        if let phraseListJson = phrasesJson["results"] as? [Dictionary<String, Any>] {
            for phraseJson in phraseListJson {
                var phrase = Chapter.init()
                if let content = phraseJson["content"] as? String {
                    phrase.content = content
                }
                if let contentPinyin = phraseJson["pinyin_content"] as? String {
                    phrase.contentPinyin = contentPinyin
                }
                if let contentInLocalLanguage = phraseJson["local_language_content"] as? String {
                    phrase.contentInLocalLanguage = contentInLocalLanguage
                }
                if let contentAudioURLString = phraseJson["audio_media"] as? String, let contentAudioURL = URL.init(string: contentAudioURLString) {
                    phrase.contentAudioURL = contentAudioURL
                }
                survivalPhrases.append(phrase)
            }
        }

        return survivalPhrases
    }
}
