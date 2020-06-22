//
//  TrendingPhraseWrapper.swift
//  meho-ios
//
//  Created by Meho Dev on 6/21/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class TrendingPhraseWrapper: NSObject {
    let trendingPhrase: TrendingPhrase
    var isExpanded = false

    init(trendingPhrase: TrendingPhrase) {
        self.trendingPhrase = trendingPhrase
    }
}
