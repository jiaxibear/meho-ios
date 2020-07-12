//
//  ScoredChapter.swift
//  meho-ios
//
//  Created by Meho Dev on 4/11/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ScoredChapter: NSObject {
    let chapter: Chapter
    var score: Float
    var scoredContent: NSAttributedString?
    var shouldDisplayScore = false

    init(chapter: Chapter) {
        self.chapter = chapter
        score = -1
    }
}
