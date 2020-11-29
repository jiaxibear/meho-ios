//
//  ScoredChapter.swift
//  meho-ios
//
//  Created by Meho Dev on 4/11/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ScoredChapter: NSObject, MehoContentAnalytics {
    // MARK: - MehoContentAnalytics
    let contentType = MehoAnalyticsContentType.expression
    var contentID: String {
        return chapter.identifier
    }
    var contentTrackingID = UUID().uuidString

    // MARK: - Main
    let chapter: Chapter
    var score: Float
    var scoredContent: NSAttributedString?
    var shouldDisplayScore = false
    var isExpressionChapter = false

    init(chapter: Chapter) {
        self.chapter = chapter
        score = -1
    }

    init(chapter: Chapter, displaySaveButton: Bool) {
        self.chapter = chapter
        self.isExpressionChapter = displaySaveButton
        score = -1
    }
}
