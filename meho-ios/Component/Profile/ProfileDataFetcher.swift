//
//  ProfileDataFetcher.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 9/12/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSAppSync
import AWSCore
import AWSMobileClient


class ProfileDataFetcher: NSObject {

    private var appSyncClient: AWSAppSyncClient?
    private let session = URLSession(configuration: .default)

    private let fetchProfileDetailURLString = "https://4taqoyya3m.execute-api.us-west-2.amazonaws.com/dev/getProfileDetail"

    // MARK: - Init
    override init() {
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
    }

    public func fetchProfileDetail(userID: String, completionHandler: @escaping ( ProfileDetails?, Error?) -> Void) {
        guard let fetchProfileDetailURL = URL.init(string: fetchProfileDetailURLString) else {
            completionHandler(nil, nil)
            return
        }

        do {
            var request = URLRequest.init(url: fetchProfileDetailURL)
            request.httpMethod = "POST"
            let bodyDictionary = [ "userId" : userID ]
            let bodyJSONString = try JSONSerialization.data(withJSONObject: bodyDictionary, options: .prettyPrinted)
            request.httpBody = bodyJSONString
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            session.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    completionHandler(nil, error)
                    return
                }
                guard data != nil else {
                    completionHandler(nil, nil)
                    return
                }
                do {
                    if let responseDict = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any], let profileDetails = self.parseProfileDetails(responseDict: responseDict) {
                        completionHandler(profileDetails, nil)
                    } else {
                        completionHandler(nil, nil)
                    }
                }
                catch {
                    completionHandler(nil, error)
                }
            }.resume()
        } catch {
            completionHandler(nil, error)
        }
    }

    private func parseProfileDetails(responseDict: [String: Any]) -> ProfileDetails? {
        guard let profileDetailsDict = responseDict["response"] as? [String: Any] else {
            return nil
        }

        var profileDetails = ProfileDetails.init()
        if let completedItemsJSONArray = profileDetailsDict["completed_items"] as? [[String : Any]] {
            var completedItems: [ProfileCard] = []
            for completedItemJSONObject in completedItemsJSONArray {
                if let profileCard = parseProfileCard(profileCardJSONObject: completedItemJSONObject) {
                    completedItems.append(profileCard)
                }
            }
            profileDetails.completedItems = completedItems
        }
        if let inProgressItemsJSONArray = profileDetailsDict["in_progress_items"] as? [[String : Any]] {
            var inProgressItems: [ProfileCard] = []
            for inProgressItemJSONObject in inProgressItemsJSONArray {
                if let profileCard = parseProfileCard(profileCardJSONObject: inProgressItemJSONObject) {
                    inProgressItems.append(profileCard)
                }
            }
            profileDetails.inProgressItems = inProgressItems
        }
        if let savedItemsJSONArray = profileDetailsDict["saved_items"] as? [[String : Any]] {
            var savedItems: [ProfileCard] = []
            for savedItemJSONObject in savedItemsJSONArray {
                if let profileCard = parseProfileCard(profileCardJSONObject: savedItemJSONObject) {
                    savedItems.append(profileCard)
                }
            }
            profileDetails.savedItems = savedItems
        }
        return profileDetails
    }

    private func parseProfileCard(profileCardJSONObject: [String: Any]) -> ProfileCard? {
        guard let typeName = profileCardJSONObject["__typename"] as? String else {
            return nil
        }
        if typeName == "Article" {
            var news = News.init()
            if let coverImageDict = profileCardJSONObject["coverImage"] as? [String: String], let bucket = coverImageDict["bucket"], let key = coverImageDict["key"] {
                news.imageKey = S3ImageViewKey.init(bucket: bucket, key: key)
            }
            if let titleEn = profileCardJSONObject["titleEn"] as? String {
                news.title_en = titleEn
            }
            if let titleZh = profileCardJSONObject["titleZh"] as? String {
                news.title_zh = titleZh
            }
            if let subtitle = profileCardJSONObject["whyYouShouldReadThisArticle"] as? String {
                news.reason = subtitle
            }
            if let source = profileCardJSONObject["sourcer"] as? String {
                news.source = source
            }
            if let identifier = profileCardJSONObject["id"] as? String {
                news.identifier = identifier
            }
            if let date = profileCardJSONObject["createdAt"] as? String {
                news.date = date
            }
            return news
        } else if typeName == "Dialogue" {
            var dialog = Dialog.init()
            if let titleZh = profileCardJSONObject["titleZh"] as? String {
                dialog.title = titleZh
            }
            if let titleEn = profileCardJSONObject["titleEn"] as? String {
                dialog.titleInLocalLanguage = titleEn
            }
            if let difficultyLevel = profileCardJSONObject["difficultyLevel"] as? String {
                if difficultyLevel == DifficultyIdentifier.advanced.rawValue {
                    dialog.difficulty = .advanced
                } else if difficultyLevel == DifficultyIdentifier.intermediate.rawValue {
                    dialog.difficulty = .intermediate
                } else if difficultyLevel == DifficultyIdentifier.beginner.rawValue {
                    dialog.difficulty = .beginner
                }
            }
            if let whyYouShouldLearnThisDialogue = profileCardJSONObject["whyYouShouldLearnThisDialogue"] as? String {
                dialog.whyYouShouldLearn = whyYouShouldLearnThisDialogue
            }
            if let identifier = profileCardJSONObject["id"] as? String {
                dialog.identifier = identifier
            }
            if let coverImageDict = profileCardJSONObject["coverImage"] as? [String: String], let bucket = coverImageDict["bucket"], let key = coverImageDict["key"] {
                dialog.imageKey = S3ImageViewKey.init(bucket: bucket, key: key)
            }
            return dialog
        }
        return nil
    }
}
