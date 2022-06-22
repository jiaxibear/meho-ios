//
//  UserDataFetcher.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 8/22/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSAppSync
import AWSCore
import AWSMobileClient
import Signals

class UserDataFetcher: NSObject {

    private var appSyncClient: AWSAppSyncClient?
    private let session = URLSession(configuration: .default)

    static let shared = UserDataFetcher.init()
    private var currentUser: BasicUser?
    private let dialogRecordingHistoryUrlPrefix = "https://np6vw6ipgk.execute-api.us-west-2.amazonaws.com/dev/profile/user_score_history/dialogue/"

    let userSignal = Signal<BasicUser>.init()

    // MARK: - Init
    private override init() {
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
    }

    public func deactivateCurrentUser() {
        currentUser = nil
    }

    // MARK: - User table related
    public func createUser(userId: String, username: String, userEmail: String, completionHandler: @escaping ( BasicUser?, Error?) -> Void) {
        let createUserInput = CreateUserInput(id: userId, username: username, email: userEmail)
        let m = CreateUserMutation(input: createUserInput)
        appSyncClient?.perform(mutation: m, resultHandler: { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            guard let createdUser = result?.data?.createUser else {
                completionHandler(nil, nil)
                return
            }
            var newUser = BasicUser.init()
            newUser.identifier = createdUser.id
            newUser.username = createdUser.username
            newUser.email = createdUser.email
            completionHandler(newUser, nil)
        })
    }

    public func getUser(userId: String, completionHandler: @escaping ( BasicUser?, Error?) -> Void) {
        if currentUser != nil {
            completionHandler(currentUser, nil)
            return
        }
        let q = GetUserQuery(id: userId)
        appSyncClient?.fetch(query: q) { (result, error) in

            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            guard let remoteuser = result?.data?.getUser else {
                completionHandler(nil, nil)
                return
            }

            var basicUser = BasicUser.init()
            basicUser.identifier = remoteuser.id
            basicUser.email = remoteuser.email
            basicUser.username = remoteuser.username

            if let avatar_key = remoteuser.avatar?.key, let avatar_bucket = remoteuser.avatar?.bucket {
                basicUser.avatarImageKey = S3ResourceKey.init(bucket: avatar_bucket, key: avatar_key)
            } else if let avatarKey = remoteuser.avatarKey {
                basicUser.avatarImageKey = S3ResourceKey.init(bucket: "", key: avatarKey)
            }

            if let goals = remoteuser.goals {
                basicUser.goals = goals
            }

            if let interests = remoteuser.interests {
                basicUser.interests = interests
            }

            if let profession = remoteuser.profession {
                basicUser.profession = profession
            }
            if let credit = remoteuser.credit {
                basicUser.credit = credit
            }
            self.currentUser = basicUser
            completionHandler(basicUser, nil)
        }
    }

    func increaseCurrentUserCredit(creditIncreased: Int, completionHandler: @escaping ( BasicUser?, Error?) -> Void) {
        guard let currentUser = currentUser else {
            return
        }

        let newCredit = currentUser.credit + creditIncreased
        updateUser(id: currentUser.identifier, credit:newCredit, completionHandler: completionHandler)
    }

    public func updateUser(id: String, username: String? = nil, email: String? = nil, avatar: S3ObjectInput? = nil, avatarKey: String? = nil, goals: [String]? = nil, interests: [String]? = nil, profession: String? = nil, credit: Int? = nil, completionHandler: @escaping ( BasicUser?, Error?) -> Void) {
        let updateUserInput = UpdateUserInput.init(id: id, username: username, email: email, avatar: avatar, avatarKey: avatarKey, goals: goals, interests: interests, profession: profession, credit: credit)
        let m = UpdateUserMutation(input: updateUserInput)
        appSyncClient?.perform(mutation: m, resultHandler: { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            guard let remoteUser = result?.data?.updateUser else {
                completionHandler(nil, nil)
                return
            }
            var updatedUser = BasicUser.init()
            updatedUser.identifier = remoteUser.id
            updatedUser.username = remoteUser.username
            updatedUser.email = remoteUser.email

            if let avatar_key = remoteUser.avatar?.key, let avatar_bucket = remoteUser.avatar?.bucket {
                updatedUser.avatarImageKey = S3ResourceKey.init(bucket: avatar_bucket, key: avatar_key)
            } else if let avatarKey = remoteUser.avatarKey {
                updatedUser.avatarImageKey = S3ResourceKey.init(bucket: "", key: avatarKey)
            }

            if let goals = remoteUser.goals {
                updatedUser.goals = goals
            }

            if let interests = remoteUser.interests {
                updatedUser.interests = interests
            }

            if let profession = remoteUser.profession {
                updatedUser.profession = profession
            }
            if let credit = remoteUser.credit {
                updatedUser.credit = credit
            }
            self.currentUser = updatedUser
            self.userSignal.fire(updatedUser)
            completionHandler(updatedUser, nil)
        })
    }

    // MARK: - User Vocabulary save related
    public func getUserVocabularySave(userId: String, vocaularyId: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
        let userVocabSaveId = userId + "+" + vocaularyId
        let q = GetUserVocabularySaveQuery(id: userVocabSaveId)
        appSyncClient?.fetch(query: q, cachePolicy: .returnCacheDataAndFetch ) { (result, error) in

            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            guard (result?.data?.getUserVocabularySave) != nil else {
                completionHandler(false, nil)
                return
            }

            completionHandler(true, nil)
        }
    }

    public func createUserVocabularySave(userId: String, vocabularyId: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
        let userVocabSaveId = userId + "+" + vocabularyId
        let createUserVocabularySaveInput = CreateUserVocabularySaveInput(id: userVocabSaveId, vocabularyId: vocabularyId, userVocabularySaveUsersId: userId)
        let m = CreateUserVocabularySaveMutation(input: createUserVocabularySaveInput)
        appSyncClient?.perform(mutation: m, resultHandler: { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            guard (result?.data?.createUserVocabularySave) != nil else {
                completionHandler(false, nil)
                return
            }
            completionHandler(true, nil)
        })
    }

    public func deleteUserVocabularySave(userId: String, vocabularyId: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
        let userVocabSaveID = userId + "+" + vocabularyId
        let deleteUserVocabularySaveInput = DeleteUserVocabularySaveInput(id: userVocabSaveID)
        let m = DeleteUserVocabularySaveMutation(input: deleteUserVocabularySaveInput)
        appSyncClient?.perform(mutation: m, resultHandler: { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            guard (result?.data?.deleteUserVocabularySave) != nil else {
                completionHandler(false, nil)
                return
            }
            _ = self.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) in
                let query = GetUserVocabularySaveQuery(id: userVocabSaveID)
                try transaction.update(query: query, { (data: inout GetUserVocabularySaveQuery.Data) in
                    data.getUserVocabularySave = nil
                })
            })
            completionHandler(true, nil)
        })
    }

    // MARK: - User item save related
     public func getUserItemSave(userId: String, itemId: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
         let userItemSaveID = userId + "+" + itemId
         let q = GetUserItemSaveQuery(id: userItemSaveID)
        
         appSyncClient?.fetch(query: q, cachePolicy: .returnCacheDataAndFetch) { (result, error) in
             print (error?.localizedDescription as Any)
             guard error == nil else {
                 completionHandler(false, error)
                 return
             }
             guard (result?.data?.getUserItemSave) != nil else {
                 completionHandler(false, nil)
                 return
             }

             completionHandler(true, nil)
         }
     }

    public func createUserItemSave(userId: String, itemId: String, itemType: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
        let userItemSaveID = userId + "+" + itemId
        let createUserItemSaveInput = CreateUserItemSaveInput(id: userItemSaveID, itemType: itemType, itemId: itemId, userItemSaveUserId: userId)
        let m = CreateUserItemSaveMutation(input: createUserItemSaveInput)
        appSyncClient?.perform(mutation: m, resultHandler: { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            guard result?.data?.createUserItemSave != nil else {
                completionHandler(false, nil)
                return
            }
            completionHandler(true, nil)
        })
     }

     public func deleteUserItemSave(userId: String, itemId: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
         let userItemSaveID = userId + "+" + itemId
         let deleteUserItemSaveInput = DeleteUserItemSaveInput(id: userItemSaveID)
         let m = DeleteUserItemSaveMutation(input: deleteUserItemSaveInput)
         appSyncClient?.perform(mutation: m, resultHandler: { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            guard (result?.data?.deleteUserItemSave) != nil else {
                completionHandler(false, nil)
                return
            }
            _ = self.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) in
                let query = GetUserItemSaveQuery(id: userItemSaveID)
                try transaction.update(query: query, { (data: inout GetUserItemSaveQuery.Data) in
                    data.getUserItemSave = nil
                })
            })
            completionHandler(true, nil)
        })
     }

    // MARK: - User Item inProgress related
     public func getUserItemInProgress(userId: String, itemId: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
         let userItemInProgressId = userId + "+" + itemId
         let q = GetUserItemInProgressQuery(id: userItemInProgressId)
         appSyncClient?.fetch(query: q) { (result, error) in

             print (error?.localizedDescription as Any)
             guard error == nil else {
                 completionHandler(false, error)
                 return
             }
             guard (result?.data?.getUserItemInProgress) != nil else {
                 completionHandler(false, nil)
                 return
             }

             completionHandler(true, nil)
         }
     }

    public func createUserItemInProgress(userId: String, itemId: String, itemType: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
        let userItemInProgressId = userId + "+" + itemId
        let createUserItemInProgressInput = CreateUserItemInProgressInput(id: userItemInProgressId, itemType: itemType, itemId: itemId, userItemInProgressUserId: userId)
         let m = CreateUserItemInProgressMutation(input: createUserItemInProgressInput)
        appSyncClient?.perform(mutation: m, resultHandler: { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            guard (result?.data?.createUserItemInProgress) != nil else {
                completionHandler(false, nil)
                return
            }
            completionHandler(true, nil)
        })
     }

     public func deleteUserItemInProgress(userId: String, itemId: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
         let userItemInProgressId = userId + "+" + itemId
         let deleteUserItemInProgressInput = DeleteUserItemInProgressInput(id: userItemInProgressId)
         let m = DeleteUserItemInProgressMutation(input: deleteUserItemInProgressInput)
        appSyncClient?.perform(mutation: m, resultHandler: { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            guard (result?.data?.deleteUserItemInProgress) != nil else {
                completionHandler(false, nil)
                return
            }
            completionHandler(true, nil)
        })
     }


    // MARK: - User Item Complete related
     public func getUserItemCompleted(userId: String, itemId: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
         let userItemCompletedId = userId + "+" + itemId
         let q = GetUserItemCompletedQuery(id: userItemCompletedId)
         appSyncClient?.fetch(query: q) { (result, error) in

             print (error?.localizedDescription as Any)
             guard error == nil else {
                 completionHandler(false, error)
                 return
             }
             guard (result?.data?.getUserItemCompleted) != nil else {
                 completionHandler(false, nil)
                 return
             }

             completionHandler(true, nil)
         }
     }

    public func createUserItemCompleted(userId: String, itemId: String, itemType: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
        let userItemCompletedId = userId + "+" + itemId
        let createUserItemCompletedInput = CreateUserItemCompletedInput(id: userItemCompletedId, itemType: itemType, itemId: itemId, userItemCompletedUserId: userId)
         let m = CreateUserItemCompletedMutation(input: createUserItemCompletedInput)
        appSyncClient?.perform(mutation: m, resultHandler: { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            guard (result?.data?.createUserItemCompleted) != nil else {
                completionHandler(false, nil)
                return
            }
            completionHandler(true, nil)
        })
     }

     public func deleteUserItemCompleted(userId: String, itemId: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
         let userItemCompletedId = userId + "+" + itemId
         let deleteUserItemCompletedInput = DeleteUserItemCompletedInput(id: userItemCompletedId)
         let m = DeleteUserItemCompletedMutation(input: deleteUserItemCompletedInput)
        appSyncClient?.perform(mutation: m, resultHandler: { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            guard (result?.data?.deleteUserItemCompleted) != nil else {
                completionHandler(false, nil)
                return
            }
            completionHandler(true, nil)
        })
     }

    func startItemProgressIfNeeded(userId: String, itemId: String, itemType: String) {
        var isInProgressFlag: Bool?
        var isCompletedFlag: Bool?
        getUserItemInProgress (userId: userId, itemId: itemId, completionHandler: { (isInProgress, error) in
            if (error == nil && isInProgress) {
                isInProgressFlag = true
            } else {
                isInProgressFlag = false
            }
            self.startProgressIfNeeded(userId: userId, itemId: itemId, itemType: itemType, isInProgress: isInProgressFlag, isCompleted: isCompletedFlag)
        })
        getUserItemCompleted (userId: userId, itemId: itemId, completionHandler: { (isCompleted, error) in
            if (error == nil && isCompleted) {
                isCompletedFlag = true
            } else {
                isCompletedFlag = false
            }
            self.startProgressIfNeeded(userId: userId, itemId: itemId, itemType: itemType, isInProgress: isInProgressFlag, isCompleted: isCompletedFlag)
        })

    }

    func startProgressIfNeeded(userId:String, itemId:String, itemType: String, isInProgress:Bool?, isCompleted:Bool?) {
        if let isInProgressFlag = isInProgress, let isCompletedFlag = isCompleted {
            if !isInProgressFlag && !isCompletedFlag {
                createUserItemInProgress(userId: userId, itemId: itemId, itemType: itemType) { (createInProgressSuccess, error) in
                    if (error == nil && createInProgressSuccess) {
                        // do nothing
                        print("user:" + userId + ",item " + itemType + ":" + itemId + " - added inprogress successful")
                    } else {
                        print("user:" + userId + ",item " + itemType + ":" + itemId + " - added inprogress failed")
                    }
                }
            } else {
                var status = "not started"
                if isInProgressFlag {
                    status = "in progress"
                } else if isCompletedFlag {
                    status = "completed"
                }
                print("user:" + userId + ",item " + itemType + ":" + itemId + ", status:" + status)
            }
        } else {
            print("user:" + userId + ",item " + itemType + ":" + itemId + " - not all status fetched yet, do nothing")
        }
    }

    public func createUserChapterRecording(userId: String, chapterId: String, mode: String, score:Double? = nil, scoreDetail:String? = nil, completionHandler: @escaping ( String?, Error?) -> Void) {
        let createUserChapterRecordingInput = CreateUserChapterRecordingInput(userId: userId, chapterId: chapterId, mode: mode, score: score, scoreExtra: scoreDetail)

        let m = CreateUserChapterRecordingMutation(input: createUserChapterRecordingInput)
        appSyncClient?.perform(mutation: m, resultHandler:  { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            guard let createdUserChapterRecording = result?.data?.createUserChapterRecording else {
                completionHandler(nil, nil)
                return
            }

            completionHandler(createdUserChapterRecording.id, nil)
        })
    }

    public func createUserExpressionRecording(userId: String, expressionId: String, score:Double? = nil, scoreDetail:String? = nil, completionHandler: @escaping ( String?, Error?) -> Void) {
        let createUserExpressionRecordingInput = CreateUserExpressionRecordingInput(userId: userId, expressionId: expressionId, score: score, scoreExtra: scoreDetail)


        let m = CreateUserExpressionRecordingMutation(input: createUserExpressionRecordingInput)
        appSyncClient?.perform(mutation: m, resultHandler:  { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            guard let createdUserExpressionRecording = result?.data?.createUserExpressionRecording else {
                completionHandler(nil, nil)
                return
            }

            completionHandler(createdUserExpressionRecording.id, nil)
        })
    }

    // MARK: - Restful APIs for customized logic
    public func fetchLatestDuoScoresOfDialogRest(dialogID: String, userID: String, completionHandler: @escaping ( Dictionary<String, Double>?, Error?) -> Void) {
        if var fetchLatestDuoScoresURLComponent = URLComponents.init(string: dialogRecordingHistoryUrlPrefix) {
            let dialogIdQueryItem = URLQueryItem.init(name: "dialogue", value: dialogID)
            let userIdQueryItem = URLQueryItem.init(name: "user", value: userID)
            fetchLatestDuoScoresURLComponent.queryItems = [dialogIdQueryItem, userIdQueryItem]
            if let fetchLatestDuoScoresUrl = fetchLatestDuoScoresURLComponent.url {
                let dataCategoriesTask = session.dataTask(with: fetchLatestDuoScoresUrl, completionHandler: { (data, URLResponse, error) in
                    if error != nil {
                        print("There is an error getting the response of news list")
                        completionHandler(nil, error)
                        return
                    }
                    if data == nil {
                        print("The response of news list is empty")
                        completionHandler(nil, nil)
                        return
                    }
                    do {
                        if let scoreHistoriesJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            let newsList = self.parseDuoScoresOfDialog(scoreHistoriesJson: scoreHistoriesJson)
                            completionHandler(newsList, nil)
                        }
                    } catch let JSONError as NSError {
                        print("Failed to parse news list JSON: \(JSONError.localizedDescription)")
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

    private func parseDuoScoresOfDialog(scoreHistoriesJson: [String: Any]) -> Dictionary<String, Double> {
        var chapterIdToScores:[String:Double] = [:]
        guard let recordsMapJson = scoreHistoriesJson["records"] as? [String: Any] else {
            return chapterIdToScores
        }

        guard let duoItemsArrayJson = recordsMapJson["DUO"] as? [[String: Any]] else {
            return chapterIdToScores
        }

        for duoItemJson in duoItemsArrayJson {
            if let chapterId = duoItemJson["chapter_id"] as? String,
               let historicalScores = duoItemJson["history_scores"] as? [[String: Any]],
               historicalScores.count > 0 {

                if let firstRecord = historicalScores.first,
                   let scoreS = firstRecord["score"] as? String,
                   let scoreD = Double(scoreS) {
                    chapterIdToScores[chapterId] = scoreD
                }
            }
        }

        return chapterIdToScores
    }
}
