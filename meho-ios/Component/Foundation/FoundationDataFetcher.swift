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

    public func fetchPictrographList(completionHandler: @escaping ( Result<[Pictograph], Error>) -> Void) {
        var bird = Pictograph.init()
        bird.content_en = "fire"
        bird.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/bird.gif")
        var cloud = Pictograph.init()
        cloud.content_en = "cloud"
        cloud.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/cloud.gif")
        var door = Pictograph.init()
        door.content_en = "door"
        door.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/door.gif")
        var earth = Pictograph.init()
        earth.content_en = "earth"
        earth.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/earth.gif")
        var eye = Pictograph.init()
        eye.content_en = "eye"
        eye.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/eye.gif")
        var field = Pictograph.init()
        field.content_en = "field"
        field.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/field.gif")
        var fire = Pictograph.init()
        fire.content_en = "fire"
        fire.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/fire.gif")
        var fish = Pictograph.init()
        fish.content_en = "fish"
        fish.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/fish.gif")
        var goat = Pictograph.init()
        goat.content_en = "goat"
        goat.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/goat.gif")
        var hand = Pictograph.init()
        hand.content_en = "hand"
        hand.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/hand.gif")
        var human = Pictograph.init()
        human.content_en = "human"
        human.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/human.gif")
        var moon = Pictograph.init()
        moon.content_en = "moon"
        moon.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/moon.gif")
        var mountain = Pictograph.init()
        mountain.content_en = "mountain"
        mountain.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/mountain.gif")
        var mouth = Pictograph.init()
        mouth.content_en = "mouth"
        mouth.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/mouth.gif")
        var rain = Pictograph.init()
        rain.content_en = "rain"
        rain.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/rain.gif")
        var sun = Pictograph.init()
        sun.content_en = "sun"
        sun.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/sun.gif")
        var water = Pictograph.init()
        water.content_en = "water"
        water.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/water.gif")
        var wood = Pictograph.init()
        wood.content_en = "wood"
        wood.gifImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/wood.gif")
        let pictrographList = [ bird, cloud, door, earth, eye, field, fire, fish, goat, hand, human, moon, mountain, mouth, rain, sun, water, wood ]
        completionHandler(.success(pictrographList))
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
                if let pinyinroot = pinyinJsonResult["pinyin"] as? String {
                    pinyin.pinyin = pinyinroot
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
