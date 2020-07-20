//
//  SignUpTextField.swift
//  meho-ios
//
//  Created by Meho Dev on 6/14/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class SignUpTextField: UIView {

    enum SignUpTextFieldStatus {
        case notStarted
        case valid
        case invalid
    }

    // MARK: - Constants
    private let textFieldFontSize = CGFloat(16)
    private let textFieldCornerRadius = CGFloat(2)
    private let textFieldBackgroundColorAlpha = CGFloat(0.1)
    private let viewHeight = CGFloat(54)
    private let statusImageViewSideWidth = CGFloat(30)
    private let statusImageViewSideHeight = CGFloat(30)
    private let statusImageViewLeadingTrailingMargin = CGFloat(10)
    private let statusValidImageName = "login_check"
    private let statusInvalidImageName = "login_wrong"

    // MARK: - Properties
    lazy var textField: UITextField = {
        let textField = UITextFieldPadding.init(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        let fontDescriptor = UIFont.systemFont(ofSize: textFieldFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        textField.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        textField.autocapitalizationType = .none
        textField.textColor = .textCharcoalGrey
        textField.layer.cornerRadius = textFieldCornerRadius
        textField.tintColor = .wisteriaPurple
        textField.backgroundColor = UIColor.skyBlue.withAlphaComponent(textFieldBackgroundColorAlpha)
        textField.keyboardType = .emailAddress
        textField.clipsToBounds = true
        return textField
    } ()

    var status = SignUpTextFieldStatus.notStarted {
        didSet {
            switch status {
            case .notStarted:
                statusImageView.isHidden = true
                break
            case .valid:
                statusImageView.isHidden = false
                statusImageView.image = UIImage.init(named: statusValidImageName)
                break
            case .invalid:
                statusImageView.isHidden = false
                statusImageView.image = UIImage.init(named: statusInvalidImageName)
                break
            }
        }
    }

    private lazy var statusImageView: UIImageView = {
        let statusImageView = UIImageView.init(frame: .zero)
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        return statusImageView
    } ()

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textField)
        addSubview(statusImageView)

        statusImageView.widthAnchor.constraint(equalToConstant: statusImageViewSideWidth).isActive = true
        statusImageView.heightAnchor.constraint(equalToConstant: statusImageViewSideHeight).isActive = true
        statusImageView.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: statusImageViewLeadingTrailingMargin).isActive = true
        statusImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -statusImageViewLeadingTrailingMargin).isActive = true
        statusImageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true

        textField.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // MARK: - UIView
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: 0, height: viewHeight)
    }
}
