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
    enum ExpressionDataFetcherError: Error {
        case invalidURL
        case noData
        case JSONParse
    }

    // MARK: - URLs
    private let mustKnowPhrasesURLString = "https://np6vw6ipgk.execute-api.us-west-2.amazonaws.com/dev/profile/expression/"

    // MARK: - Properties
    private var appSyncClient: AWSAppSyncClient?
    private let session = URLSession(configuration: .default)

    // MARK: - Init
    override init() {
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
    }

    // MARK: - Internal
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
                if let audioKey = remoteChapter.audioKey {
                    chapter.contentAudioKey = audioKey
                } else if let audioKey = remoteChapter.audio?.key {
                    chapter.contentAudioKey = audioKey
                }
                chapterList.append(chapter)
            }
            completionHandler(.success(chapterList))
        }
    }

    func fetchTrendingPhrases(count: Int = 100, completionHandler: @escaping ( Swift.Result<Array<TrendingPhrase>, Error>) -> Void) {
        let query = GetTrendingPhrasesByStatusQuery()
        query.limit = count
        query.status = "published"
        query.sortDirection = .desc
        appSyncClient?.fetch(query: query, resultHandler: { (result, error) in
            if let error = error {
                print("There is an error getting the response of trending phrases")
                completionHandler(.failure(error))
                return
            }

            guard let items = result?.data?.getTrendingPhrasesByStatus?.items else {
                completionHandler(.success([]))
                return
            }

            var trendingPhrases = [TrendingPhrase].init()
            for item in items {
                guard let item = item else {
                    continue
                }

                var trendingPhrase = TrendingPhrase.init()
                trendingPhrase.content_zh = item.contentZh
                if let contentPinyin = item.contentPinyin {
                    trendingPhrase.content_pinyin = contentPinyin
                }
                if let contentExplanation = item.description {
                    trendingPhrase.content_explanation = contentExplanation
                }
                if let audioKey = item.audioKey {
                    trendingPhrase.audioKey = S3ResourceKey.init(bucket: "", key: audioKey)
                }
                trendingPhrase.identifier = item.id
                trendingPhrases.append(trendingPhrase)
            }
            completionHandler(.success(trendingPhrases))
        })
    }

    func fetchMustKnowPhrases(userID: String, completionHandler: @escaping ( Swift.Result<Array<MustKnowPhraseCategory>, Error>) -> Void) {
        guard let mustKnowPhrasesURL = URL.init(string: mustKnowPhrasesURLString.appending(userID)) else {
            completionHandler(.failure(ExpressionDataFetcherError.invalidURL))
            return
        }

        let session = URLSession(configuration: .default)
        let request = URLRequest.init(url: mustKnowPhrasesURL)
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }

            guard let data = data else {
                completionHandler(.failure(ExpressionDataFetcherError.noData))
                return
            }

            do {
                if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completionHandler(.success(self.parseMustKnowPhrasesResult(responseDict: responseDict)))
                } else {
                    completionHandler(.failure(ExpressionDataFetcherError.JSONParse))
                }
            }
            catch {
                completionHandler(.failure(ExpressionDataFetcherError.JSONParse))
            }

        }.resume()
    }

    func parseMustKnowPhrasesResult(responseDict: [String: Any]) -> [MustKnowPhraseCategory] {
        var mustKnowPhrasesCategories: [MustKnowPhraseCategory] = []
        guard let detail = responseDict["detail"] as? [String: Any] else {
            return mustKnowPhrasesCategories
        }

        for (title, category) in detail {
            if let category = category as? [String: Any] {
                let total = category["total"] as? Int ?? 0
                let practiced = category["practiced"] as? Int ?? 0
                let imageURLString = category["image"] as? String
                let mustKnowPhraseCategory = MustKnowPhraseCategory.init(title: title, total: total, practiced: practiced, imageURLString: imageURLString)
                mustKnowPhrasesCategories.append(mustKnowPhraseCategory)
            }
        }
        return mustKnowPhrasesCategories
    }
}
