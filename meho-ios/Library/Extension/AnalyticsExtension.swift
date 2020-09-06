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

extension Analytics {
    class func logScreenViewEvent(viewController: MehoAnalytics) {
        let parameters = [
            AnalyticsParameterScreenName: viewController.screenName,
            AnalyticsParameterScreenClass: viewController.screenClass,
        ]
        Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
    }
}
