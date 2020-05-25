//
//  UIColorExtentsion.swift
//  meho-ios
//
//  Created by Meho Dev on 2/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

extension UIColor {
    class var backgroundGray: UIColor  {
        return UIColor.init(hex: "#0c000000")!
    }

    class var borderGray: UIColor {
        return UIColor.init(hex: "#d8d8d8")!
    }

    class var mehoDarkGray: UIColor {
        return UIColor.init(hex: "#2c2c2e")!
    }

    class var darkGrayTwo: UIColor {
        return UIColor.init(hex: "#1c1c1e")!
    }

    class var textBlueGray: UIColor {
        return UIColor.init(hex: "#8e8e93")!
    }

    class var wisteriaPurple: UIColor {
        return UIColor.init(hex: "#9576cd")!
    }

    class var textCharcoalGrey: UIColor {
        return UIColor.init(hex: "#48484a")!
    }

    class var paleLilac: UIColor {
        return UIColor.init(hex: "#e5e5ea")!
    }

    class var skyBlue: UIColor {
        return UIColor.init(hex: "#7baffa")!
    }

    class var sunYellow: UIColor {
        return UIColor.init(hex: "#ffd52e")!
    }

    class var coral: UIColor {
        return UIColor.init(hex: "#ff5937")!
    }

    class var barShadow: UIColor {
        return UIColor.init(hex: "#a6b3c2")!
    }

    class var paleGray: UIColor {
        return UIColor.init(hex: "#f2f2f7")!
    }

    class var greenBlue: UIColor {
        return UIColor.init(hex: "#29cb88")!
    }

    class var slateGrey: UIColor {
        return UIColor.init(hex: "#636366")!
    }

    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            let hexColorCount = hexColor.count
            if hexColorCount == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            } else if hexColorCount == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff)) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }

        return nil
    }
}
