//
//  Expression.swift
//  meho-ios
//
//  Created by Meho Dev on 12/5/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation

struct Expression: ProfileCard {
    // MARK: - ProfileCard
    let profileCardType: ProfileCardType = .expression
    var title: String {
        return contentZh
    }

    var subtitle: String {
        return contentEn
    }

    var imageKey: S3ImageViewKey?
    var identifier = ""
    var contentZh = ""
    var contentPinyin = ""
    var contentEn = ""
    var audioKey: URL?
    var category: SurvivalPhraseCategoryIdentifier = .basic
}
