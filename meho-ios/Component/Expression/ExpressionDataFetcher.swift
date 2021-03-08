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

    // MARK: - Internal
    func fetchTrendingPhrases(count: Int = 5, completionHandler: @escaping ( Swift.Result<Array<TrendingPhrase>, Error>) -> Void) {
        let query = ListTrendingPhrasesQuery()
        query.limit = count
        appSyncClient?.fetch(query: query, resultHandler: { (result, error) in
            if let error = error {
                print("There is an error getting the response of survival phrases")
                completionHandler(.failure(error))
                return
            }

            guard let items = result?.data?.listTrendingPhrases?.items else {
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
}
