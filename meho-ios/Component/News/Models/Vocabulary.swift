//
//  Vocabulary.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/20/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation

struct Vocabulary: MehoContentAnalytics, ProfileCard {
    // MARK: - MehoContentAnalytics
    let contentType = MehoAnalyticsContentType.vocabulary
    var contentID: String {
        return identifier
    }
    var contentTrackingID = UUID().uuidString

    // MARK: - MehoContentAnalytics
    let profileCardType: ProfileCardType = .vocabulary

    var title: String {
        return content_zh
    }

    var imageKey: S3ResourceKey? {
        return nil
    }

    var subtitle: String {
        return content_en
    }

    // MARK: - Main
    var identifier = ""
    var content_pinyin = ""
    var content_zh = ""
    var content_en = ""
    var content_optional = ""
    var chapter_offset = -1
    var audioURL:URL?
    var audio_bucket:String?
    var audio_key:String?
}
