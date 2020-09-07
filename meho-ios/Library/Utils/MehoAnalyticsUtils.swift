//
//  MehoAnalyticsUtils.swift
//  meho-ios
//
//  Created by Meho Dev on 9/4/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

enum MehoAnalyticsParameterInteraction: String {
    case shortPress = "SHORT_PRESS"
}

enum MehoAnalyticsContentType: String {
    case story = "STORY"
    case talk = "TALK"
    case expression = "EXPRESSION"
    case idiom = "IDIOM"
    case graphic = "GRAPHIC"
}

class MehoAnalyticsUtils: NSObject {
    static let MehoAnalyticsEventInteractions = "control_interactions"
    static let MehoAnalyticsEventContentImpressions = "content_impressions"
    static let MehoAnalyticsParameterInteractionType = "interaction_type"
    static let MehoAnalyticsParameterControlName = "control_name"
    static let MehoAnalyticsParameterControlID = "control_id"
    static let MehoAnalyticsParameterScreenName = "screen_name"
    static let MehoAnalyticsParameterContentID = "content_id"
    static let MehoAnalyticsParameterContentType = "content_type"
    static let MehoAnalyticsParameterContentTrackingID = "content_tracking_id"
}
