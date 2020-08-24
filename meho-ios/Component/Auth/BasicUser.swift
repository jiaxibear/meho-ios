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
    var professional = ""
    var goals:[String] = []
    var interests:[String] = []
    var avatar_bucket:String?
    var avatar_key:String?
}
