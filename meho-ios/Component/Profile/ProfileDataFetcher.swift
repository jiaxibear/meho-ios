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

    private let fetchProfileDetailURLString = "https://np6vw6ipgk.execute-api.us-west-2.amazonaws.com/dev/profile/"

    // MARK: - Init
    override init() {
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
    }

    public func fetchProfileDetail(userID: String, completionHandler: @escaping ( ProfileDetails?, Error?) -> Void) {

        guard let fetchProfileDetailURL = URL.init(string: fetchProfileDetailURLString.appending(userID)) else {
            completionHandler(nil, nil)
            return
        }

        let request = URLRequest.init(url: fetchProfileDetailURL)
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
    }

    private func parseProfileDetails(responseDict: [String: Any]) -> ProfileDetails? {
        guard let profileDetailsDict = responseDict["detail"] as? [String: Any] else {
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
        if let savedVocabulariesJSONArray = profileDetailsDict["saved_vocabs"] as? [[String : Any]] {
            var savedVocabularies: [Vocabulary] = []
            for vocabularyJSONObject in savedVocabulariesJSONArray {
                let vocabulary = parseVocabulary(vocabularyJson: vocabularyJSONObject)
                savedVocabularies.append(vocabulary)
            }
            profileDetails.savedVocabularies = savedVocabularies
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
        } else if typeName == "Expression" {
            var expression = Expression.init()
            if let contentEn = profileCardJSONObject["contentEn"] as? String {
                expression.contentEn = contentEn
            }
            if let audioKeyURLString = profileCardJSONObject["audio_key"] as? String, let audioKeyURL = URL.init(string: audioKeyURLString){
                expression.audioKey = audioKeyURL
            }
            if let identifier = profileCardJSONObject["id"] as? String {
                expression.identifier = identifier
            }
            if let contentPinyin = profileCardJSONObject["contentPinyin"] as? String {
                expression.contentPinyin = contentPinyin
            }
            if let contentZh = profileCardJSONObject["contentZh"] as? String {
                expression.contentZh = contentZh
            }
            if let categoryString = profileCardJSONObject["type"] as? String {
                var category: SurvivalPhraseCategoryIdentifier?
                switch categoryString {
                case "Basic":
                    category = .basic
                    break
                case "Number":
                    category = .numbers
                    break
                case "Shopping":
                    category = .shopping
                    break
                case "Travel":
                    category = .travel
                    break
                case "Dining":
                    category = .dining
                    break
                case "Business":
                    category = .business
                    break
                case "Entertainment":
                    category = .entertainment
                    break
                case "Family":
                    category = .family
                    break
                case "Flirting":
                    category = .flirting
                    break
                case "Festivities":
                    category = .festivities
                    break
                default:
                    break
                }
                if category != nil {
                    expression.category = category!
                }
            }
            return expression
        }
        return nil
    }

    private func parseVocabulary(vocabularyJson: [String: Any]) -> Vocabulary {
        var vocabulary = Vocabulary.init()
        if let contentPinyin = vocabularyJson["contentPinyin"] as? String {
            vocabulary.content_pinyin = contentPinyin
        }
        if let contentZh = vocabularyJson["contentZh"] as? String {
            vocabulary.content_zh = contentZh
        }
        if let contentEn = vocabularyJson["contentEn"] as? String {
            vocabulary.content_en = contentEn
        }
        if let identifier = vocabularyJson["id"] as? String {
            vocabulary.identifier = identifier
        }
        return vocabulary
    }
}
