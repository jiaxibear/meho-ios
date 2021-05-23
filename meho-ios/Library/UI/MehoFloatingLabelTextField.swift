//
//  Meho.swift
//  meho-ios
//
//  Created by Meho Dev on 5/16/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class MehoFloatingLabelTextField: SkyFloatingLabelTextField {

    private let padding = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

    private let textFieldFontSize = CGFloat(18)
    private let textFieldTitleFontSize = CGFloat(12)

    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }

    private func customInit() {
        titleFormatter = { (text: String) -> String in
            return text
        }
        borderStyle = .none
        translatesAutoresizingMaskIntoConstraints = false
        var font = UIFont.systemFont(ofSize: textFieldFontSize, weight: .light)
        if let fontDescriptor = font.fontDescriptor.withDesign(.rounded) {
            font = UIFont.init(descriptor: fontDescriptor, size: textFieldFontSize)
        }
        self.font = font
        textColor = .darkGrayTwo

        titleColor = .darkGrayTwo
        selectedTitleColor = .darkGrayTwo
        var titleFont = UIFont.systemFont(ofSize: textFieldTitleFontSize, weight: .light)
        if let titleFontDescriptor = titleFont.fontDescriptor.withDesign(.rounded) {
            titleFont = UIFont.init(descriptor: titleFontDescriptor, size: textFieldTitleFontSize)
        }
        self.titleFont = titleFont

        tintColor = .darkGrayTwo
        lineColor = .clear
        selectedLineColor = .clear
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }
}
