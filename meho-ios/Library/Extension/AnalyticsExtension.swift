//
//  AnalyticsExtension.swift
//  meho-ios
//
//  Created by Meho Dev on 9/4/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics

protocol MehoAnalytics {
    var screenName: String { get }
    var screenClass: String { get }
}

protocol MehoContentAnalytics {
    var contentType: MehoAnalyticsContentType { get }
    var contentID: String { get }
    var contentTrackingID: String { get }
}

extension Analytics {
    class func logScreenViewEvent(viewController: MehoAnalytics) {
        let parameters = [
            AnalyticsParameterScreenName: viewController.screenName,
            AnalyticsParameterScreenClass: viewController.screenClass,
        ]
        Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
    }

    class func logContentImpression(content: MehoContentAnalytics, screenName: String) {
        let parameters = [
            AnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterContentID: content.contentID,
            MehoAnalyticsUtils.MehoAnalyticsParameterContentType: content.contentType.rawValue,
            MehoAnalyticsUtils.MehoAnalyticsParameterContentTrackingID: content.contentTrackingID
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventContentImpressions, parameters: parameters)
    }
}
