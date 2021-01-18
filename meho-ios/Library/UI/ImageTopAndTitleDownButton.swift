//
//  ImageTopAndTitleDownButton.swift
//  meho-ios
//
//  Created by Meho Dev on 1/12/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

class ImageTopAndTitleDownButton: UIButton {

    var imageAndTitleMargin = CGFloat(16)
    var imageWidth = CGFloat(60)
    var imageHeight = CGFloat(60)

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let originalTitleRect = super.titleRect(forContentRect: contentRect)
        let originalTitleHeight = originalTitleRect.height
        return CGRect.init(x: 0, y: contentRect.height - originalTitleHeight, width: contentRect.width, height: originalTitleHeight)
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect.init(x: (contentRect.width - imageWidth) / 2, y: 0, width: imageWidth, height: imageHeight)
    }

    override var intrinsicContentSize: CGSize {
        guard let titleSize = titleLabel?.sizeThatFits(CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)) else {
            return super.intrinsicContentSize
        }

        let width = max(titleSize.width, imageWidth)
        let height = titleSize.height + imageHeight + imageAndTitleMargin
        return CGSize.init(width: width, height: height)
    }
}
