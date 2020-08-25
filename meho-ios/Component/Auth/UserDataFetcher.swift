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

class UserDataFetcher: NSObject {

    private var appSyncClient: AWSAppSyncClient?

    // MARK: - Init
    override init() {
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
    }

    // MARK: - User table related
    public func createUser(userId: String, username: String, userEmail: String, completionHandler: @escaping ( BasicUser?, Error?) -> Void) {
        let createUserInput = CreateUserInput(id: userId, username: username, email: userEmail)
        let m = CreateUserMutation(input: createUserInput)
        appSyncClient?.perform(mutation: m) { (result, error) in
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
        }
    }

    public func getUser(userId: String, completionHandler: @escaping ( BasicUser?, Error?) -> Void) {
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

            if let avatar_key = remoteuser.avatar?.key {
                basicUser.avatar_key = avatar_key
            }
            if let avatar_bucket = remoteuser.avatar?.bucket {
                basicUser.avatar_bucket = avatar_bucket
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
            completionHandler(basicUser, nil)
        }
    }

    public func updateUser(id:String, username: String? = nil, email: String? = nil, avatar: S3ObjectInput? = nil, avatarKey: String? = nil, goals: [String]? = nil, interests: [String]? = nil, profession: String? = nil, completionHandler: @escaping ( BasicUser?, Error?) -> Void) {
        let updateUserInput = UpdateUserInput.init(id: id, username: username, email: email, avatar: avatar, avatarKey: avatarKey, goals: goals, interests: interests, profession: profession)
        let m = UpdateUserMutation(input: updateUserInput)
        appSyncClient?.perform(mutation: m) { (result, error) in
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

            if let avatar_key = remoteUser.avatar?.key {
                updatedUser.avatar_key = avatar_key
            }
            if let avatar_bucket = remoteUser.avatar?.bucket {
                updatedUser.avatar_bucket = avatar_bucket
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

            completionHandler(updatedUser, nil)
        }
    }

    // MARK: - User save related
    public func getUserVocabularySave(userId: String, vocaularyId: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
        let userVocabSaveId = userId + "+" + vocaularyId
        let q = GetUserVocabularySaveQuery(id: userVocabSaveId)
        appSyncClient?.fetch(query: q) { (result, error) in

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
        appSyncClient?.perform(mutation: m) { (result, error) in
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
        }
    }

    public func deleteUserVocabularySave(userId: String, vocabularyId: String, completionHandler: @escaping ( Bool, Error?) -> Void) {
        let userVocabSaveId = userId + "+" + vocabularyId
        let createUserVocabularySaveInput = DeleteUserVocabularySaveInput(id: userVocabSaveId)
        let m = DeleteUserVocabularySaveMutation(input: createUserVocabularySaveInput)
        appSyncClient?.perform(mutation: m) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            guard (result?.data?.deleteUserVocabularySave) != nil else {
                completionHandler(false, nil)
                return
            }
            completionHandler(true, nil)
        }
    }
}
