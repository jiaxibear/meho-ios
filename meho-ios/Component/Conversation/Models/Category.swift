//
//  Category.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation

struct Category : Equatable {
    var title = ""
    var identifier = ""
    var coverImageKey:String?
    var coverImageURL:URL?
    var featureType = "Normal"
    var isFeatured:Bool = false
    var featuredSlogan:String?
    var featuredImageKey:String?
}
