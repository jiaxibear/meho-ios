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

    public func createUser(userId: String, username: String, userEmail: String, completionHandler: @escaping ( BasicUser?, Error?) -> Void) {
        let createUserInput = CreateUserInput(id: userId, username: username, email: userEmail)
        let m = CreateUserMutation(input: createUserInput)
        appSyncClient?.perform(mutation: m) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {return}
            guard let createdUser = result?.data?.createUser else {return}
            var newUser = BasicUser.init()
            newUser.identifier = createdUser.id
            newUser.username = createdUser.username
            newUser.email = createdUser.email
            completionHandler(newUser, nil)
        }
        completionHandler(nil, nil)
    }

    public func getUser(userId: String, completionHandler: @escaping ( BasicUser?, Error?) -> Void) {
        let q = GetUserQuery(id: userId)
        appSyncClient?.fetch(query: q) { (result, error) in

            print (error?.localizedDescription as Any)
            guard error == nil else {return}
            guard let remoteuser = result?.data?.getUser else {return}

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
                var goalsToAdd:[String] = []
                for goal in goals {
                    guard let goalString = goal else { continue }
                    goalsToAdd.append(goalString)
                }
                basicUser.goals = goalsToAdd
            }

            if let goals = remoteuser.goals {
                var goalsToAdd:[String] = []
                for goal in goals {
                    guard let goalString = goal else { continue }
                    goalsToAdd.append(goalString)
                }
                basicUser.goals = goalsToAdd
            }

            if let interests = remoteuser.interests {
                var interestsToAdd:[String] = []
                for interest in interests {
                    guard let interestString = interest else { continue }
                    interestsToAdd.append(interestString)
                }
                basicUser.interests = interestsToAdd
            }

            if let profession = remoteuser.professional {
                basicUser.professional = profession
            }

            completionHandler(basicUser, nil)
        }
        completionHandler(nil, nil)
    }


}
