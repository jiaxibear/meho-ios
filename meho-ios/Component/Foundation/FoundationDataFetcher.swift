//
//  FoundationDataFetcher.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class FoundationDataFetcher: NSObject {

    private let fetchPictographListURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/foundation/pictograph/?limit=30"
    private let fetchPinyinDetailURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/foundation/pinyins/"

    private let pinyinQueryName = "identifier"
    // MARK: - Properties

    private let session = URLSession(configuration: .default)

    public func fetchPictrographList(completionHandler: @escaping ( Array<Pictograph>?, Error?) -> Void) {
           if let newsListUrl = URL.init(string: fetchPictographListURLString) {
               let dataPictographsTask = session.dataTask(with: newsListUrl, completionHandler: { (data, URLResponse, error) in
                   if error != nil {
                       print("There is an error getting the response of pictography list")
                       completionHandler(nil, error)
                       return
                   }
                   if data == nil {
                       print("The response of pictography list is empty")
                       completionHandler(nil, nil)
                       return
                   }
                   do {
                       if let pictographListJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                           let pictographList = self.parsePictographListJSON(pictographListJson: pictographListJson)
                           completionHandler(pictographList, nil)
                       }
                   } catch let JSONError as NSError {
                       print("Failed to parse pictography list JSON: \(JSONError.localizedDescription)")
                       completionHandler(nil, JSONError)
                   }
               })
               dataPictographsTask.resume()
           } else {
               completionHandler(nil, nil)
           }
       }

       private func parsePictographListJSON(pictographListJson: [String: Any]) -> Array<Pictograph> {

           var pictographList:[Pictograph] = []
           if let pictographsJson = pictographListJson["results"] as? [Dictionary<String, Any>] {
               for pictographJson in pictographsJson {
                   var pictograph = Pictograph.init()
                   if let content = pictographJson["content"] as? String {
                       pictograph.content_zh = content
                   }
                   if let local_language_content = pictographJson["local_language_content"] as? String {
                       pictograph.content_en = local_language_content
                   }
                   if let identifier = pictographJson["id"] as? Int {
                       pictograph.identifier = identifier
                   }
                   if let gifURLString = pictographJson["gif"] as? String {
                       pictograph.gifImageURL = gifURLString
                   }
                   pictographList.append(pictograph)
               }
           }

           return pictographList
       }

    public func fetchDetailedPinyin(pinyin: String, completionHandler: @escaping ( Pinyin?, Error?) -> Void) {
        if var fetchPinyinDetailURLComponent = URLComponents.init(string: fetchPinyinDetailURLString) {
            let quertItem = URLQueryItem.init(name: pinyinQueryName, value: pinyin)
            fetchPinyinDetailURLComponent.queryItems = [quertItem]
            if let fetchPinyinDetailURL = fetchPinyinDetailURLComponent.url {
                let detailedPinyinDataTask = session.dataTask(with: fetchPinyinDetailURL, completionHandler: { (data, URLResponse, error) in
                    if error != nil {
                        print("There is an error getting the response of the detailed pinyin")
                        completionHandler(nil, error)
                        return
                    }
                    if data == nil {
                        print("The response of the detailed pinyin is empty")
                        completionHandler(nil, nil)
                        return
                    }
                    do {
                        if let detailedPinyinJSON = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            let detailedPinyin = self.parsePinyinJSON(pinyinJson: detailedPinyinJSON)
                            completionHandler(detailedPinyin, nil)
                        } else {
                            completionHandler(nil, nil)
                        }
                    } catch let JSONError as NSError {
                        print("Failed to parse the detailed pinyin JSON: \(JSONError.localizedDescription)")
                        completionHandler(nil, JSONError)
                    }
                })
                detailedPinyinDataTask.resume()
            } else {
                completionHandler(nil, nil)
            }
        } else {
            completionHandler(nil, nil)
        }
    }

    private func parsePinyinJSON(pinyinJson: [String : Any]) -> Pinyin {
        var pinyin = Pinyin.init()
        if let pinyinJsonResults = pinyinJson["results"] as? [Dictionary<String, Any>] {
            if !pinyinJsonResults.isEmpty {
                let pinyinJsonResult = pinyinJsonResults[0]
                if let identifier = pinyinJsonResult["id"] as? Int {
                    pinyin.identifier = identifier
                }
                if let one_symbol = pinyinJsonResult["one_symbol"] as? String {
                    pinyin.toneOneSymbol = one_symbol
                }
                if let one_character = pinyinJsonResult["one_character"] as? String {
                    pinyin.toneOneCharacter = one_character
                }
                if let one_pronounce = pinyinJsonResult["one_pronounce"] as? String {
                    if let pronounceAudioURL = URL.init(string: one_pronounce) {
                        pinyin.toneOnePronounceUrl = pronounceAudioURL
                    }
                }
                if let two_symbol = pinyinJsonResult["two_symbol"] as? String {
                    pinyin.toneTwoSymbol = two_symbol
                }
                if let two_character = pinyinJsonResult["two_character"] as? String {
                    pinyin.toneTwoCharacter = two_character
                }
                if let two_pronounce = pinyinJsonResult["two_pronounce"] as? String {
                    if let pronounceAudioURL = URL.init(string: two_pronounce) {
                        pinyin.toneTwoPronounceUrl = pronounceAudioURL
                    }
                }
                if let three_symbol = pinyinJsonResult["three_symbol"] as? String {
                    pinyin.toneThreeSymbol = three_symbol
                }
                if let three_character = pinyinJsonResult["three_character"] as? String {
                    pinyin.toneThreeCharacter = three_character
                }
                if let three_pronounce = pinyinJsonResult["three_pronounce"] as? String {
                    if let pronounceAudioURL = URL.init(string: three_pronounce) {
                        pinyin.toneThreePronounceUrl = pronounceAudioURL
                    }
                }
                if let four_symbol = pinyinJsonResult["four_symbol"] as? String {
                    pinyin.toneFourSymbol = four_symbol
                }
                if let four_character = pinyinJsonResult["four_character"] as? String {
                    pinyin.toneFourCharacter = four_character
                }
                if let four_pronounce = pinyinJsonResult["four_pronounce"] as? String {
                    if let pronounceAudioURL = URL.init(string: four_pronounce) {
                        pinyin.toneFourPronounceUrl = pronounceAudioURL
                    }
                }
            }
        }
        return pinyin
    }
}
