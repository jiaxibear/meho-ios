//
//  CALayerExtension.swift
//  meho-ios
//
//  Created by Meho Dev on 2/9/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
    func applySketchShadow(color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4, spread: CGFloat = 0) {
        masksToBounds = false
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }

    func redrawShadowPath(bounds: CGRect) {
        if let shadowPath = shadowPath {
            let boundingBoxPath = shadowPath.boundingBoxOfPath
            if boundingBoxPath.width != bounds.width || boundingBoxPath.height != bounds.height {
                let newRect = bounds.insetBy(dx: boundingBoxPath.origin.x, dy: boundingBoxPath.origin.y)
                self.shadowPath = UIBezierPath(rect: newRect).cgPath
            }
        }
    }
}
