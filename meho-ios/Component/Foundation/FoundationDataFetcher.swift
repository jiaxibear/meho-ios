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
}
