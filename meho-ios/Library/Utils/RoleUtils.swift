//
//  RoleUtils.swift
//  meho-ios
//
//  Created by Meho Dev on 4/11/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class RoleUtils: NSObject {

    static let roleJackie = "JACKIE"
    static let roleJikai = "JIKAI"
    static let roleChuhan = "CHUHAN"
    static let roleCharlie = "CHARLIE"
    static let roleJackieImageName = "conversation_facepile1"
    static let roleJikaiImageName = "conversation_facepile2"
    static let roleChuhanImageName = "conversation_facepile3"
    static let roleCharlieImageName = "conversation_facepile4"

    class func avatarImage(with role:String) -> UIImage {
        var imageName:String
        if role == roleJackie {
            imageName = roleJackieImageName
        } else if role == roleJikai {
            imageName = roleJikaiImageName
        } else if role == roleChuhan {
            imageName = roleChuhanImageName
        } else if role == roleCharlie {
            imageName = roleCharlieImageName
        } else {
            imageName = roleJackieImageName
        }
        return UIImage.init(named: imageName)!
    }
}
