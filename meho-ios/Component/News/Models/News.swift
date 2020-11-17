//
//  News.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 3/29/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation

struct News: MehoContentAnalytics {
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
    var imageKey: S3ImageViewKey?
    var date = ""
}
