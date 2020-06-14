//
//  OtherSignInView.swift
//  meho-ios
//
//  Created by Meho Dev on 6/13/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class OtherSignInView: UIView {

    // MARK: - Constants
    private let orLabelFontSize = CGFloat(14)
    private let orLabelLeadingTrailingMargin = CGFloat(30)
    private let barHeight = CGFloat(1)
    private let buttonsStackViewSpacing = CGFloat(16)
    private let buttonsStackViewTopMargin = CGFloat(24)
    private let buttonsStackViewLeadingTrailingMargin = CGFloat(4)
    private let buttonHeight = CGFloat(48)
    private let buttonCornerRadius = CGFloat(8)
    private let buttonTitleFontSize = CGFloat(16)
    private let thirdPartySignInTextFontSize = CGFloat(10)
    private let viewHeight = CGFloat(240)

    // MARK: - Properties
    private lazy var leftBar: UIView = {
        let leftBar = UIView.init(frame: .zero)
        leftBar.translatesAutoresizingMaskIntoConstraints = false
        leftBar.backgroundColor = .lightBlueGreyTwo
        return leftBar
    } ()

    private lazy var rightBar: UIView = {
        let rightBar = UIView.init(frame: .zero)
        rightBar.translatesAutoresizingMaskIntoConstraints = false
        rightBar.backgroundColor = .lightBlueGreyTwo
        return rightBar
    } ()

    private lazy var orLabel: UILabel = {
        let orLabel = UILabel.init(frame: .zero)
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        orLabel.textColor = .lightBlueGreyTwo
        let orLabelfontDescriptor = UIFont.systemFont(ofSize: orLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        orLabel.font = UIFont.init(descriptor: orLabelfontDescriptor!, size: orLabelFontSize)
        orLabel.text = NSLocalizedString("OrText", comment: "").uppercased()
        return orLabel
    } ()

    private lazy var facebookButton: UIButton = {
        let facebookButton = UIButton.init(frame: .zero)
        facebookButton.translatesAutoresizingMaskIntoConstraints = false
        facebookButton.layer.cornerRadius = buttonCornerRadius
        facebookButton.clipsToBounds = true
        facebookButton.backgroundColor = UIColor.init(hex: "#1778F2")!
        facebookButton.setTitleColor(.white, for: .normal)
        facebookButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonTitleFontSize, weight: .semibold)
        facebookButton.setTitle(NSLocalizedString("FacebookButtonTitle", comment: ""), for: .normal)
        return facebookButton
    } ()

    private lazy var googleButton: UIButton = {
        let googleButton = UIButton.init(frame: .zero)
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        googleButton.layer.cornerRadius = buttonCornerRadius
        googleButton.clipsToBounds = true
        googleButton.backgroundColor = UIColor.init(hex: "#db3236")!
        googleButton.setTitleColor(.white, for: .normal)
        googleButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonTitleFontSize, weight: .semibold)
        googleButton.setTitle(NSLocalizedString("GoogleButtonTitle", comment: ""), for: .normal)
        return googleButton
    } ()

    private lazy var appleButton: UIButton = {
        let appleButton = UIButton.init(frame: .zero)
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.layer.cornerRadius = buttonCornerRadius
        appleButton.clipsToBounds = true
        appleButton.backgroundColor = .darkGray
        appleButton.setTitleColor(.white, for: .normal)
        appleButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonTitleFontSize, weight: .semibold)
        appleButton.setTitle(NSLocalizedString("AppleButtonTitle", comment: ""), for: .normal)
        return appleButton
    } ()

    private lazy var buttonsStackView: UIStackView = {
        let buttonsStackView = UIStackView.init(arrangedSubviews: [self.facebookButton, self.googleButton, self.appleButton])
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = buttonsStackViewSpacing
        return buttonsStackView
    } ()

    private lazy var thirdPartySignInTextView: UITextView = {
        let thirdPartySignInTextView = UITextView.init(frame: .zero)
        thirdPartySignInTextView.translatesAutoresizingMaskIntoConstraints = false
        thirdPartySignInTextView.isScrollEnabled = false
        let thirdPartySignInTextFormat = NSLocalizedString("ThirdPartySignInText", comment: "")
        let termsAndConditionsText = NSLocalizedString("TermsAndConditionsText", comment: "")
        let privacyStatementText = NSLocalizedString("PrivacyStatementText", comment: "")
        let thirdPartySignInText = String.init(format: thirdPartySignInTextFormat, termsAndConditionsText, privacyStatementText)
        let thirdPartySignInAttributedText = NSMutableAttributedString.init(string: thirdPartySignInText)
        let termsAndConditionsTextRange = thirdPartySignInAttributedText.mutableString.range(of: termsAndConditionsText)
        let privacyStatementTextRange = thirdPartySignInAttributedText.mutableString.range(of: privacyStatementText)
        thirdPartySignInAttributedText.addAttribute(.link, value: URL.init(string: "https://www.google.com")!, range: termsAndConditionsTextRange)
        thirdPartySignInAttributedText.addAttribute(.link, value: URL.init(string: "https://www.google.com")!, range: privacyStatementTextRange)
        thirdPartySignInAttributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: thirdPartySignInTextFontSize), range: NSRange.init(location: 0, length: thirdPartySignInText.count))
        thirdPartySignInAttributedText.addAttribute(.foregroundColor, value: UIColor.black.withAlphaComponent(0.25), range: NSRange.init(location: 0, length: thirdPartySignInText.count))
        thirdPartySignInTextView.attributedText = thirdPartySignInAttributedText
        thirdPartySignInTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.greenBlue.withAlphaComponent(0.75)]
        return thirdPartySignInTextView
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
        addSubview(leftBar)
        addSubview(rightBar)
        addSubview(orLabel)
        addSubview(buttonsStackView)
        addSubview(thirdPartySignInTextView)

        orLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        orLabel.leadingAnchor.constraint(equalTo: leftBar.trailingAnchor, constant: orLabelLeadingTrailingMargin).isActive = true
        orLabel.trailingAnchor.constraint(equalTo: rightBar.leadingAnchor, constant: -orLabelLeadingTrailingMargin).isActive = true
        orLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        leftBar.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
        leftBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        leftBar.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor).isActive = true

        rightBar.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
        rightBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        rightBar.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor).isActive = true

        buttonsStackView.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: buttonsStackViewTopMargin).isActive = true
        buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonsStackViewLeadingTrailingMargin).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -buttonsStackViewLeadingTrailingMargin).isActive = true
        buttonsStackView.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true

        thirdPartySignInTextView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        thirdPartySignInTextView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        thirdPartySignInTextView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // MARK: - UIView
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: 0, height: viewHeight)
    }
}
