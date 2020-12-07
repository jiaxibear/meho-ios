//
//  ProfileCard.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 9/12/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

enum ProfileCardType {
    case story
    case expression
    case talk
    case vocabulary
}

protocol ProfileCard {
    var identifier: String {
        get
    }
    var profileCardType: ProfileCardType {
        get
    }
    var title: String {
        get
    }
    var imageKey: S3ImageViewKey? {
        get
    }
    var subtitle: String {
        get
    }
}
