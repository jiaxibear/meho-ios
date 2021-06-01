//
//  ToastExtension.swift
//  meho-ios
//
//  Created by Meho Dev on 5/23/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import Foundation
import Toast_Swift

extension UIView {

    private var errorMessageViewLeadingTrailingMargin: CGFloat {
        return 30
    }

    private var errorMessageViewHeight: CGFloat {
        return 94
    }

    private var errorMessageViewBottomMargin: CGFloat {
        return 100
    }

    func showErrorMessageView(errorMessageView: ErrorMessageView) {
        let width = bounds.width
        let frame = CGRect.init(x: 0, y: 0, width: width - 2 * errorMessageViewLeadingTrailingMargin, height: errorMessageViewHeight)
        errorMessageView.frame = frame
        showToast(errorMessageView, point: CGPoint.init(x: width / 2, y: bounds.height - errorMessageViewBottomMargin))
    }
}
