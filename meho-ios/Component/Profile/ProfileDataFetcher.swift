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
    // MARK: - Init
    override init() {
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
    }
    
    public func fetchUserInteractions(userId: String, completionHandler: @escaping ( Array<Array<String>>?, Array<ProfileCard>?, Array<ProfileCard>?, Error?) -> Void) {
        let q = GetUserQuery(id: userId)
        appSyncClient?.fetch(query: q) { (result, error) in

            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, nil, nil, error)
                return
            }
            guard let remoteuser = result?.data?.getUser else {
                completionHandler(nil, nil, nil, nil)
                return
            }

            var completedItems:[[String]] = []
            if let rawItems = remoteuser.completedItems?.items {
                completedItems = self.parseCompletedItemList(rawItems: rawItems)
            }


            completionHandler(completedItems, nil, nil, nil)
        }
    }

    private func parseCompletedItemList(rawItems: [GetUserQuery.Data.GetUser.CompletedItem.Item?]) -> [[String]] {
        var storyIds:[String] = []
        var expressionIds:[String] = []
        var talkIds:[String] = []

        for maybeRawItem in rawItems {
            guard let rawItem = maybeRawItem else { continue }
            guard let itemType = rawItem.itemType else { continue }
            switch itemType {
            case "ARTICLE":
                storyIds.append(rawItem.itemId)
                break;
            case "EXPRESSION":
                expressionIds.append(rawItem.itemId)
                break;
            case "TALK":
                talkIds.append(rawItem.itemId)
                break;
            default:
                break;
            }
        }
        return [storyIds, expressionIds, talkIds]
    }
}
