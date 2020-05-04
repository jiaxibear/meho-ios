//
//  UITextFieldPadding.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 5/3/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class UITextFieldPadding: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

//    required init?(coder aDecoder: NSCoder) {
//      super.init(coder: aDecoder)
//    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }
}
