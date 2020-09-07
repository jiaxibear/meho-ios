//
//  Idiom.swift
//  meho-ios
//
//  Created by Meho Dev on 8/22/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation

struct Idiom: MehoContentAnalytics {
    // MARK: - MehoContentAnalytics
    let contentType = MehoAnalyticsContentType.idiom
    var contentID: String {
        return title
    }
    var contentTrackingID = UUID().uuidString

    // MARK: - Main
    let title: String
    let explanation: String
    let backgroundImageURL: URL
    let audioURL: URL
    let firstWord: String
    let firstWordExplanation: String
    let secondWord: String
    let secondWordExplanation: String
    let thirdWord: String
    let thirdWordExplanation: String
    let fourthWord: String
    let fourthWordExplanation: String
}
