//
//  Difficulty.swift
//  meho-ios
//
//  Created by Meho Dev on 2/17/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation

struct Difficulty : Equatable {
    public private(set) var title: String
    public private(set) var identifier: DifficultyIdentifier

    static var beginner: Difficulty {
        return Difficulty.init(title: NSLocalizedString("DifficultyBeginner", comment: ""), identifier: .beginner)
    }

    static var intermediate: Difficulty {
        return Difficulty.init(title: NSLocalizedString("DifficultyIntermediate", comment: ""), identifier: .intermediate)
    }

    static var advanced: Difficulty {
        return Difficulty.init(title: NSLocalizedString("DifficultyAdvanced", comment: ""), identifier: .advanced)
    }
}

enum DifficultyIdentifier : String {
    case beginner = "BEGINNER"
    case intermediate = "INTERMEDIATE"
    case advanced = "ADVANCED"
}
