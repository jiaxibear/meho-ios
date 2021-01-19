//
//  BasicUser.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 8/23/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation

struct BasicUser {
    var identifier = ""
    var username = ""
    var email = ""
    var profession = ""
    var goals:[String] = []
    var interests:[String] = []
    var avatarImageKey: S3ResourceKey?
}
