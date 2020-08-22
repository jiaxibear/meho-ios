//
//  NewsEnChapter.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/13/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation

struct NewsChapter {
    var identifier = ""
    var content = ""
    var language = ""
    var seq = -1
    var contentImageURL:URL?
    var image_bucket:String?
    var image_key:String?
    var vocabularies:[Vocabulary] = []
}
