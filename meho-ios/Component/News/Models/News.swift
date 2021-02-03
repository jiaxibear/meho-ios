//
//  News.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 3/29/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation

struct News: MehoContentAnalytics, ProfileCard {

    // MARK: - ProfileCard
    var profileCardType = ProfileCardType.story
    var title: String {
        return title_zh
    }
    var subtitle: String {
        return title_en
    }

    // MARK: - MehoContentAnalytics
    let contentType = MehoAnalyticsContentType.story
    var contentID: String {
        return identifier
    }
    var contentTrackingID = UUID().uuidString

    // MARK: - Main
    var identifier = ""
    var title_en = ""
    var title_zh = ""
    var reason = ""
    var source = ""
    var renderType = ""
    var coverImageURL: URL?
    var imageKey: S3ResourceKey?
    var date = ""
    var audioEnKey: S3ResourceKey?
    var audioZhKey: S3ResourceKey?
}
