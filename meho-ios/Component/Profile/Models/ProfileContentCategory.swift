//
//  ProfileContentCategory.swift
//  meho-ios
//
//  Created by Meho Dev on 11/22/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation

enum ProfileContentCategoryType {
    case all
    case story
    case expression
    case talk
}

struct ProfileContentCategory {
    let categoryType: ProfileContentCategoryType
    let title: String
    var isSelected = false
    let isSubType: Bool
}
