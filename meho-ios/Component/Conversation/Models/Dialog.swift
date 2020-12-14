//
//  Dialog.swift
//  meho-ios
//
//  Created by Meho Dev on 2/9/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation

struct Dialog: MehoContentAnalytics, ProfileCard {
    // MARK: - ProfileCard
    var profileCardType = ProfileCardType.talk
    var subtitle: String {
        return titleInLocalLanguage
    }

    // MARK: - MehoContentAnalytics
    var contentType = MehoAnalyticsContentType.talk
    var contentID: String {
        return identifier
    }
    var contentTrackingID = UUID().uuidString

    // MARK: - Main
    var identifier = ""
    var title = ""
    var titleInLocalLanguage = ""
    var coverImageURL:URL?
    var coverImageKey:String?
    var chapters: [Chapter] = []
    var difficulty = Difficulty.beginner
    var whyYouShouldLearn = ""
    var imageKey: S3ResourceKey?
    var category: Category?
}
