//
//  SignUpTextField.swift
//  meho-ios
//
//  Created by Meho Dev on 6/14/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class SignUpTextField: UIView, UITextFieldDelegate {

    enum SignUpTextFieldStatus {
        case notStarted
        case valid
        case invalid
    }

    // MARK: - Constants
    private let viewHeight = CGFloat(54)
    private let compactViewHeight = CGFloat(40)
    private let borderCornerRadius = CGFloat(8)
    private let notStartedBorderWidth = CGFloat(1)
    private let startedBorderWidth = CGFloat(2)
    private let textFieldLeadingTrailingMargin = CGFloat(10)
    private let textFieldTopBottomMargin = CGFloat(6)
    private let errorMessageLabelExtraHeight = CGFloat(36)
    private let errorMessageFontSize = CGFloat(14)

    // MARK: - Properties
    var status: SignUpTextFieldStatus = .notStarted {
        didSet {
            switch status {
            case .notStarted:
                textFieldWrapperView.layer.borderWidth = notStartedBorderWidth
                textFieldWrapperView.layer.borderColor = UIColor.paleGray.cgColor
                errorMessage = nil
            case .invalid:
                textFieldWrapperView.layer.borderWidth = startedBorderWidth
                textFieldWrapperView.layer.borderColor = UIColor.darkGrayTwo.cgColor
            case .valid:
                textFieldWrapperView.layer.borderWidth = startedBorderWidth
                textFieldWrapperView.layer.borderColor = UIColor.darkGrayTwo.cgColor
                errorMessage = nil
            }
        }
    }
    private let allowsErrorMessage: Bool
    var errorMessage: String? {
        didSet {
            if allowsErrorMessage {
                errorMessageLabel.text = errorMessage
            }
        }
    }

    lazy var textField: MehoFloatingLabelTextField = {
        let textField = MehoFloatingLabelTextField.init(frame: .zero)
        textField.delegate = self
        return textField
    } ()

    private lazy var textFieldWrapperView: UIView = {
        let textFieldWrapperView = UIView.init(frame: .zero)
        textFieldWrapperView.translatesAutoresizingMaskIntoConstraints = false
        textFieldWrapperView.layer.cornerRadius = borderCornerRadius
        textFieldWrapperView.layer.masksToBounds = true
        textFieldWrapperView.addSubview(textField)
        textFieldWrapperView.layer.borderWidth = notStartedBorderWidth
        textFieldWrapperView.layer.borderColor = UIColor.paleGray.cgColor
        return textFieldWrapperView
    } ()

    private lazy var errorMessageLabel: UILabel = {
        let errorMessageLabel = UILabel.init(frame: .zero)
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.textColor = .coral
        var errorMessageFont = UIFont.systemFont(ofSize: errorMessageFontSize, weight: .medium)
        if let errorMessageFontDescriptor = errorMessageFont.fontDescriptor.withDesign(.rounded) {
            errorMessageFont = UIFont.init(descriptor: errorMessageFontDescriptor, size: errorMessageFontSize)
        }
        errorMessageLabel.font = errorMessageFont
        return errorMessageLabel
    } ()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.init(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.addArrangedSubview(textFieldWrapperView)
        if allowsErrorMessage {
            stackView.addArrangedSubview(errorMessageLabel)
        }
        return stackView
    } ()

    private lazy var textFieldHeight = {
        return viewHeight
    } ()

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect, allowsErrorMessage: Bool)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame: CGRect, allowsErrorMessage: Bool)")
    }

    override init(frame: CGRect) {
        fatalError("Use init(frame: CGRect, allowsErrorMessage: Bool)")
    }

    init(frame: CGRect, allowsErrorMessage: Bool) {
        self.allowsErrorMessage = allowsErrorMessage
        super.init(frame: frame)
        addSubview(stackView)

        textField.leadingAnchor.constraint(equalTo: textFieldWrapperView.leadingAnchor, constant: textFieldLeadingTrailingMargin).isActive = true
        textField.trailingAnchor.constraint(equalTo: textFieldWrapperView.trailingAnchor, constant: -textFieldLeadingTrailingMargin).isActive = true
        textField.topAnchor.constraint(equalTo: textFieldWrapperView.topAnchor, constant: textFieldTopBottomMargin).isActive = true
        textField.bottomAnchor.constraint(equalTo: textFieldWrapperView.bottomAnchor, constant: -textFieldTopBottomMargin).isActive = true
        textFieldWrapperView.heightAnchor.constraint(equalToConstant: textFieldHeight).isActive = true

        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // MARK: - UIView
    override var intrinsicContentSize: CGSize {
        var height = textFieldHeight
        if allowsErrorMessage {
            height += errorMessageLabelExtraHeight
        }
        return CGSize.init(width: 0, height: height)
    }
}
