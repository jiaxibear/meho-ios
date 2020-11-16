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
            let bodyDictionary = [ "userId" : "28743420-f2e3-4935-b015-847a3d527f4b" ]
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
                completedItems.append(parseProfileCard(profileCardJSONObject: completedItemJSONObject))
            }
            profileDetails.completedItems = completedItems
        }
        if let inProgressItemsJSONArray = profileDetailsDict["in_progress_items"] as? [[String : Any]] {
            var inProgressItems: [ProfileCard] = []
            for inProgressItemJSONObject in inProgressItemsJSONArray {
                inProgressItems.append(parseProfileCard(profileCardJSONObject: inProgressItemJSONObject))
            }
            profileDetails.inProgressItems = inProgressItems
        }
        if let savedItemsJSONArray = profileDetailsDict["saved_items"] as? [[String : Any]] {
            var savedItems: [ProfileCard] = []
            for savedItemJSONObject in savedItemsJSONArray {
                savedItems.append(parseProfileCard(profileCardJSONObject: savedItemJSONObject))
            }
            profileDetails.savedItems = savedItems
        }
        return profileDetails
    }

    private func parseProfileCard(profileCardJSONObject: [String: Any]) -> ProfileCard {
        var profileCard = ProfileCard.init()
        if let typeName = profileCardJSONObject["__typename"] as? String {
            profileCard.contentType = typeName
        }
        if let coverImageDict = profileCardJSONObject["coverImage"] as? [String: String], let bucket = coverImageDict["bucket"], let key = coverImageDict["key"] {
            profileCard.imageKey = S3ImageViewKey.init(bucket: bucket, key: key)
        }
        if let titleEn = profileCardJSONObject["titleEn"] as? String {
            profileCard.titleEn = titleEn
        }
        if let titleZh = profileCardJSONObject["titleZh"] as? String {
            profileCard.titleZh = titleZh
        }
        if let subtitle = profileCardJSONObject["whyYouShouldReadThisArticle"] as? String {
            profileCard.subtitle = subtitle
        }
        return profileCard
    }
}
