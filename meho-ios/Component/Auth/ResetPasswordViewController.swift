//
//  ResetPasswordViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 6/14/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient
import FirebaseAnalytics

class ResetPasswordViewController: UIViewController, UITextFieldDelegate, OtherSignInViewDelegate, MehoAnalytics {

    // MARK: - Constants
    private let textFieldsStackViewHeight = CGFloat(324)
    private let textFieldsStackViewSpacing = CGFloat(36)
    private let textFieldsStackViewTopMargin = CGFloat(32)
    private let contentViewLeadingTrailingMargin = CGFloat(20)
    private let errorMessageLabelFontSize = CGFloat(14)
    private let errorMessageLabelCompactFontSize = CGFloat(12)
    private let errorMessageLabelHeight = CGFloat(36)
    private let otherSignInViewBottomMargin = CGFloat(8)
    private let nextButtonTitleFontSize = CGFloat(20)
    private let nextButtonCornerRadius = CGFloat(18)
    private let nextButtonHeight = CGFloat(50)
    private let nextButtonLeadingTrailingMargin = CGFloat(54)
    private let nextButtonTopMargin = CGFloat(24)
    private let passwordMinLength = 8
    private let sendCodeButtonTitleFontSize = CGFloat(16)
    private let sendCodeBackgroundViewColorAlpha = CGFloat(0.1)
    private let sendCodeBackgroundViewCornerRadius = CGFloat(2)
    private let sendCodeTextFieldFontSize = CGFloat(16)
    private let sendCodeSeparatorViewWidth = CGFloat(1)
    private let sendCodeSeparatorViewHeight = CGFloat(30)
    private let sendCodeBackgroundViewHeight = CGFloat(54)
    private let sendCodeBackgroundViewCompactHeight = CGFloat(40)
    private let sendCodeStackViewSpacing = CGFloat(4)
    private let sendCodeButtonExtraWidth = CGFloat(24)

    // MARK: - Properties
    private lazy var emailAddressTextField: SignUpTextField = {
        let emailAddressTextField = SignUpTextField.init(frame: .zero, allowsErrorMessage: true)
        emailAddressTextField.translatesAutoresizingMaskIntoConstraints = false
        emailAddressTextField.textField.placeholder = NSLocalizedString("EmailAddressPlaceholder", comment: "")
        emailAddressTextField.textField.title = NSLocalizedString("EmailAddressPlaceholder", comment: "")
        emailAddressTextField.textField.keyboardType = .emailAddress
        emailAddressTextField.textField.delegate = self
        emailAddressTextField.textField.autocapitalizationType = .none
        return emailAddressTextField
    } ()

    private lazy var createPasswordTextField: SignUpTextField = {
        let createPasswordTextField = SignUpTextField.init(frame: .zero, allowsErrorMessage: true)
        createPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        createPasswordTextField.textField.placeholder = NSLocalizedString("CreatePasswordPlaceholder", comment: "")
        createPasswordTextField.textField.title = NSLocalizedString("CreatePasswordPlaceholder", comment: "")
        createPasswordTextField.textField.isSecureTextEntry = true
        createPasswordTextField.textField.delegate = self
        return createPasswordTextField
    } ()

    private lazy var repeatPasswordTextField: SignUpTextField = {
        let repeatPasswordTextField = SignUpTextField.init(frame: .zero, allowsErrorMessage: true)
        repeatPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        repeatPasswordTextField.textField.placeholder = NSLocalizedString("RepeatPasswordPlaceholder", comment: "")
        repeatPasswordTextField.textField.title = NSLocalizedString("RepeatPasswordPlaceholder", comment: "")
        repeatPasswordTextField.textField.isSecureTextEntry = true
        repeatPasswordTextField.textField.delegate = self
        return repeatPasswordTextField
    } ()

    private lazy var errorMessageLabel: UILabel = {
        let errorMessageLabel = UILabel.init(frame: .zero)
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.textColor = .coral
        let errorMessageLabelFontDescriptor = UIFont.systemFont(ofSize: errorMessageLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        errorMessageLabel.font = UIFont.init(descriptor: errorMessageLabelFontDescriptor!, size: errorMessageLabelFontSize)
        errorMessageLabel.numberOfLines = 0
        return errorMessageLabel
    } ()

    private lazy var sendCodeButton: UIButton = {
        let sendCodeButton = UIButton.init(frame: .zero)
        sendCodeButton.translatesAutoresizingMaskIntoConstraints = false
        sendCodeButton.backgroundColor = .clear
        sendCodeButton.setTitle(NSLocalizedString("sendCodeButtonTitle", comment: ""), for: .normal)
        sendCodeButton.setTitleColor(.greenBlue, for: .normal)
        sendCodeButton.setTitleColor(.lightBlueGrey, for: .disabled)
        let sendCodeButtonFontDescriptor = UIFont.systemFont(ofSize: sendCodeButtonTitleFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        sendCodeButton.titleLabel?.font = UIFont.init(descriptor: sendCodeButtonFontDescriptor!, size: sendCodeButtonTitleFontSize)
        sendCodeButton.isEnabled = false
        sendCodeButton.addTarget(self, action: #selector(didTapSendCodeButton), for: .touchUpInside)
        return sendCodeButton
    } ()

    private lazy var sendCodeSeparatorView: UIView = {
        let sendCodeSeparatorView = UIView.init(frame: .zero)
        sendCodeSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        sendCodeSeparatorView.backgroundColor = .palePurple
        return sendCodeSeparatorView
    } ()

    private lazy var sendCodeTextField: UITextField = {
        let sendCodeTextField = UITextFieldPadding.init(frame: .zero)
        sendCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        let fontDescriptor = UIFont.systemFont(ofSize: sendCodeTextFieldFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        sendCodeTextField.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        sendCodeTextField.autocapitalizationType = .none
        sendCodeTextField.textColor = .textCharcoalGrey
        sendCodeTextField.tintColor = .wisteriaPurple
        sendCodeTextField.backgroundColor = .clear
        sendCodeTextField.isSecureTextEntry = true
        sendCodeTextField.placeholder = NSLocalizedString("verificationCodePlaceholderText", comment: "")
        sendCodeTextField.delegate = self
        return sendCodeTextField
    } ()

    private lazy var sendCodeStackView: UIStackView = {
        let sendCodeStackView = UIStackView.init(arrangedSubviews: [sendCodeTextField, sendCodeSeparatorView, sendCodeButton])
        sendCodeStackView.translatesAutoresizingMaskIntoConstraints = false
        sendCodeStackView.axis = .horizontal
        sendCodeStackView.alignment = .center
        sendCodeStackView.spacing = sendCodeStackViewSpacing
        return sendCodeStackView
    } ()

    private lazy var sendCodeBackgroundView: UIView = {
        let sendCodeBackgroundView = UIView.init(frame: .zero)
        sendCodeBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        sendCodeBackgroundView.backgroundColor = UIColor.skyBlue.withAlphaComponent(sendCodeBackgroundViewColorAlpha)
        sendCodeBackgroundView.layer.cornerRadius = sendCodeBackgroundViewCornerRadius
        sendCodeBackgroundView.clipsToBounds = true
        sendCodeBackgroundView.addSubview(sendCodeStackView)
        return sendCodeBackgroundView
    } ()

    private lazy var textFieldsStackView: UIStackView = {
        let textFieldsStackView = UIStackView.init(arrangedSubviews: [ emailAddressTextField, createPasswordTextField, repeatPasswordTextField, sendCodeBackgroundView ])
        textFieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        textFieldsStackView.axis = .vertical
        textFieldsStackView.distribution = .equalSpacing
        return textFieldsStackView
    } ()

    private lazy var otherSignInView: OtherSignInView = {
        let otherSignInView = OtherSignInView.init(frame: .zero)
        otherSignInView.translatesAutoresizingMaskIntoConstraints = false
        otherSignInView.delegate = self
        otherSignInView.isHidden = true
        return otherSignInView
    } ()

    private lazy var nextButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonTitle = NSLocalizedString("NextButtonTitle", comment: "")
        button.setTitle(buttonTitle, for: .normal)
        button.backgroundColor = .lightBlueGrey
        let fontDescriptor = UIFont.systemFont(ofSize: nextButtonTitleFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        button.titleLabel?.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = nextButtonCornerRadius
        button.clipsToBounds = true
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return button
    } ()

    private lazy var sendCodeButtonWidthAnchor: NSLayoutConstraint = {
        return sendCodeButton.widthAnchor.constraint(equalToConstant: 0)
    } ()

    private var hasEditedVerificationCode = false

    // MARK: MehoAnalytics
    let screenName = "p_meho_login_reset_passwoard"
    let screenClass =  "p_meho_login_signin"

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.backgroundColor = .white
        view.addSubview(textFieldsStackView)
        view.addSubview(otherSignInView)
        view.addSubview(errorMessageLabel)
        view.addSubview(nextButton)

        let textFieldsStackViewTopConstraint = textFieldsStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: textFieldsStackViewTopMargin)
        textFieldsStackViewTopConstraint.isActive = true
        textFieldsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentViewLeadingTrailingMargin).isActive = true
        textFieldsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentViewLeadingTrailingMargin).isActive = true
        let textFieldsStackViewHeightConstraint = textFieldsStackView.heightAnchor.constraint(equalToConstant: textFieldsStackViewHeight)
        textFieldsStackViewHeightConstraint.isActive = true

        sendCodeStackView.topAnchor.constraint(equalTo: sendCodeBackgroundView.topAnchor).isActive = true
        sendCodeStackView.bottomAnchor.constraint(equalTo: sendCodeBackgroundView.bottomAnchor).isActive = true
        sendCodeStackView.leadingAnchor.constraint(equalTo: sendCodeBackgroundView.leadingAnchor).isActive = true
        sendCodeStackView.trailingAnchor.constraint(equalTo: sendCodeBackgroundView.trailingAnchor).isActive = true

        sendCodeSeparatorView.widthAnchor.constraint(equalToConstant: sendCodeSeparatorViewWidth).isActive = true
        sendCodeSeparatorView.heightAnchor.constraint(equalToConstant: sendCodeSeparatorViewHeight).isActive = true

        let sendCodeBackgroundViewHeightConstraint = sendCodeBackgroundView.heightAnchor.constraint(equalToConstant: sendCodeBackgroundViewHeight)
        sendCodeBackgroundViewHeightConstraint.isActive = true

        let sendCodeButtonWidth = sendCodeButton.sizeThatFits(CGSize.init(width: view.bounds.width - 2 * contentViewLeadingTrailingMargin, height: .greatestFiniteMagnitude)).width + sendCodeButtonExtraWidth
        sendCodeButtonWidthAnchor.constant = sendCodeButtonWidth
        sendCodeButtonWidthAnchor.isActive = true

        otherSignInView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentViewLeadingTrailingMargin).isActive = true
        otherSignInView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentViewLeadingTrailingMargin).isActive = true
        otherSignInView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -otherSignInViewBottomMargin).isActive = true

        errorMessageLabel.topAnchor.constraint(equalTo: sendCodeStackView.bottomAnchor).isActive = true
        errorMessageLabel.heightAnchor.constraint(equalToConstant: errorMessageLabelHeight).isActive = true
        errorMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentViewLeadingTrailingMargin).isActive = true
        errorMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentViewLeadingTrailingMargin).isActive = true
        errorMessageLabel.text = ""

        let nextButtonTopConstraint = nextButton.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: nextButtonTopMargin)
        nextButtonTopConstraint.isActive = true
        nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: nextButtonLeadingTrailingMargin).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -nextButtonLeadingTrailingMargin).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: nextButtonHeight).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = NSLocalizedString("ResetPasswordScreenTitle", comment: "")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == sendCodeTextField {
            hasEditedVerificationCode = true
        } else {
            textField.placeholder = ""
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.isDescendant(of: emailAddressTextField) {
            if let emailAddress = textField.text, isValidEmail(emailAddress) {
                emailAddressTextField.status = .valid
                sendCodeButton.isEnabled = true
            } else {
                emailAddressTextField.status = .invalid
                sendCodeButton.isEnabled = false
            }
            emailAddressTextField.textField.placeholder = NSLocalizedString("EmailAddressPlaceholder", comment: "")
        } else if textField.isDescendant(of: repeatPasswordTextField) {
            if let repeatedPassword = textField.text, let password = createPasswordTextField.textField.text, repeatedPassword == password {
                repeatPasswordTextField.status = .valid
            } else {
                repeatPasswordTextField.status = .invalid
            }
            repeatPasswordTextField.textField.placeholder = NSLocalizedString("RepeatPasswordPlaceholder", comment: "")
        } else if textField.isDescendant(of: createPasswordTextField) {
            if let repeatedPassword = repeatPasswordTextField.textField.text, repeatedPassword.count > 0 {
                if let password = textField.text, repeatedPassword == password {
                    repeatPasswordTextField.status = .valid
                } else {
                    repeatPasswordTextField.status = .invalid
                }
            }
            if let password = textField.text, password.count >= passwordMinLength  {
                createPasswordTextField.status = .valid
            } else {
                createPasswordTextField.status = .invalid
            }
            createPasswordTextField.textField.placeholder = NSLocalizedString("CreatePasswordPlaceholder", comment: "")
        }
        if emailAddressTextField.status == .valid && repeatPasswordTextField.status == .valid && createPasswordTextField.status == .valid && sendCodeTextField.text != nil && sendCodeTextField.text!.count > 0 {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .skyBlue
            errorMessageLabel.text = ""
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .lightBlueGrey
            if emailAddressTextField.status == .invalid {
                emailAddressTextField.errorMessage = NSLocalizedString("InvalidEmailAddressErrorMessage", comment: "")
            }
            if createPasswordTextField.status == .invalid {
                createPasswordTextField.errorMessage = NSLocalizedString("passwordMinLengthMessage", comment: "")
            }
            if repeatPasswordTextField.status == .invalid {
                repeatPasswordTextField.errorMessage = NSLocalizedString("passwordNotMatchMessage", comment: "")
            }
            if hasEditedVerificationCode && (sendCodeTextField.text == nil || sendCodeTextField.text!.count == 0) {
                errorMessageLabel.text = NSLocalizedString("VerificationCodeEmptyMessage", comment: "")
            }
        }
    }

    // MARK: - OtherSignInViewDelegate
    func otherSignInViewDidTapURL(_ URL: URL) {
        let title = URL.absoluteString.contains("PrivacyPolicy") ? NSLocalizedString("privacyPolicy", comment: "") : NSLocalizedString("termsOfUse", comment: "")
        let webViewController = WebViewController.init(title: title, contentURL: URL, screenName: "p_meho_profiles_setting_privacy_policy", screenClass: "p_meho_profiles_setting")
        self.title = ""
        navigationController?.pushViewController(webViewController, animated: true)
    }

    func otherSignInViewDidTapFacebookButton() {

    }

    func otherSignInViewDidTapGoogleButton() {

    }

    func otherSignInViewDidTapAppleButton() {

    }

    // MARK: - Private
    @objc
    func didTapSendCodeButton() {
        if let emailAddress = emailAddressTextField.textField.text {
            AWSMobileClient.default().forgotPassword(username: emailAddress) { (forgotPasswordResult, error) in
                if forgotPasswordResult?.forgotPasswordState == .confirmationCodeSent {
                    let alertController = UIAlertController.init(title: NSLocalizedString("VerificationCodeSentTitle", comment: ""), message: NSLocalizedString("VerificationCodeSentMessage", comment: ""), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction.init(title: NSLocalizedString("OKButtonTitle", comment: ""), style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                        self.sendCodeButton.setTitle(NSLocalizedString("sendAgainButtonTitle", comment: ""), for: .normal)
                        let sendCodeButtonWidth = self.sendCodeButton.sizeThatFits(CGSize.init(width: self.view.bounds.width - 2 * self.contentViewLeadingTrailingMargin, height: .greatestFiniteMagnitude)).width + self.sendCodeButtonExtraWidth
                        self.sendCodeButtonWidthAnchor.constant = sendCodeButtonWidth
                    }
                } else {
                    let alertController = UIAlertController.init(title: NSLocalizedString("verificationCodeErrorTitle", comment: ""), message: NSLocalizedString("genericVerificationErrorMessage", comment: ""), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction.init(title: NSLocalizedString("OKButtonTitle", comment: ""), style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    @objc
    func didTapNextButton() {
        if let emailAddress = emailAddressTextField.textField.text?.lowercased(), let password = createPasswordTextField.textField.text, let verificationCode = sendCodeTextField.text {
            AWSMobileClient.default().confirmForgotPassword(username: emailAddress, newPassword: password, confirmationCode: verificationCode) { (forgotPasswordResult, error) in
                if forgotPasswordResult?.forgotPasswordState == .done {
                    DispatchQueue.main.async {
                        self.navigationController?.setViewControllers([MehoCoverViewController.init(notificationURLString: nil), SignInViewController.init()], animated: false)
                    }
                } else {
                    var errorMessage = NSLocalizedString("genericForgetPasswordErrorMessage", comment: "")
                    if let mobileClientError = error as? AWSMobileClientError {
                        switch mobileClientError {
                        case let .codeMismatch(message):
                            errorMessage = message
                            break
                        case let .invalidPassword(message):
                            errorMessage = message
                            break
                        default:
                            break
                        }
                    }
                    let alertController = UIAlertController.init(title: NSLocalizedString("forgetPasswordErrorTitle", comment: ""), message: errorMessage, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction.init(title: NSLocalizedString("OKButtonTitle", comment: ""), style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
