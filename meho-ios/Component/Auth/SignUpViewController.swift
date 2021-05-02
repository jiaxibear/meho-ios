//
//  SignUpViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 6/14/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient
import FirebaseAnalytics

class SignUpViewController: UIViewController, UITextFieldDelegate, MehoAnalytics {

    // MARK: - Constants
    private let textFieldsStackViewHeight = CGFloat(234)
    private let textFieldsStackViewSpacing = CGFloat(36)
    private let textFieldsStackViewTopMargin = CGFloat(32)
    private let contentViewLeadingTrailingMargin = CGFloat(20)
    private let errorMessageLabelFontSize = CGFloat(16)
    private let errorMessageLabelCompactFontSize = CGFloat(12)
    private let errorMessageLabelTopMargin = CGFloat(24)
    private let nextButtonTitleFontSize = CGFloat(20)
    private let nextButtonCornerRadius = CGFloat(18)
    private let nextButtonHeight = CGFloat(50)
    private let nextButtonLeadingTrailingMargin = CGFloat(54)
    private let nextButtonTopMargin = CGFloat(24)
    private let passwordMinLength = 8

    // MARK: - Properties
    private lazy var emailAddressTextField: SignUpTextField = {
        let emailAddressTextField = SignUpTextField.init(frame: .zero)
        emailAddressTextField.translatesAutoresizingMaskIntoConstraints = false
        emailAddressTextField.textField.placeholder = NSLocalizedString("EmailAddressPlaceholder", comment: "")
        emailAddressTextField.textField.keyboardType = .emailAddress
        emailAddressTextField.textField.delegate = self
        return emailAddressTextField
    } ()

    private lazy var createPasswordTextField: SignUpTextField = {
        let createPasswordTextField = SignUpTextField.init(frame: .zero)
        createPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        createPasswordTextField.textField.placeholder = NSLocalizedString("CreatePasswordPlaceholder", comment: "")
        createPasswordTextField.textField.isSecureTextEntry = true
        createPasswordTextField.textField.delegate = self
        return createPasswordTextField
    } ()

    private lazy var repeatPasswordTextField: SignUpTextField = {
        let repeatPasswordTextField = SignUpTextField.init(frame: .zero)
        repeatPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        repeatPasswordTextField.textField.placeholder = NSLocalizedString("RepeatPasswordPlaceholder", comment: "")
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
        errorMessageLabel.textAlignment = .center
        errorMessageLabel.numberOfLines = 0
        return errorMessageLabel
    } ()

    private lazy var textFieldsStackView: UIStackView = {
        let textFieldsStackView = UIStackView.init(arrangedSubviews: [ emailAddressTextField, createPasswordTextField, repeatPasswordTextField])
        textFieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        textFieldsStackView.axis = .vertical
        textFieldsStackView.distribution = .equalSpacing
        return textFieldsStackView
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

    // MARK: MehoAnalytics
    let screenName = "p_meho_login_signup_email"
    let screenClass =  "p_meho_login_signup"

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.backgroundColor = .white
        view.addSubview(textFieldsStackView)
        view.addSubview(errorMessageLabel)
        view.addSubview(nextButton)

        let textFieldsStackViewTopConstraint = textFieldsStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: textFieldsStackViewTopMargin)
        textFieldsStackViewTopConstraint.isActive = true
        textFieldsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentViewLeadingTrailingMargin).isActive = true
        textFieldsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentViewLeadingTrailingMargin).isActive = true
        let textFieldsStackViewHeightConstraint = textFieldsStackView.heightAnchor.constraint(equalToConstant: textFieldsStackViewHeight)
        textFieldsStackViewHeightConstraint.isActive = true

        let errorMessageLabelTopConstraint = errorMessageLabel.topAnchor.constraint(equalTo: textFieldsStackView.bottomAnchor, constant: errorMessageLabelTopMargin)
        errorMessageLabelTopConstraint.isActive = true
        errorMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentViewLeadingTrailingMargin).isActive = true
        errorMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentViewLeadingTrailingMargin).isActive = true
        errorMessageLabel.text = "a\na\na"
        let errorMessageLabelHeight = errorMessageLabel.sizeThatFits(CGSize.init(width: view.bounds.width - 2 * contentViewLeadingTrailingMargin, height: .greatestFiniteMagnitude)).height
        errorMessageLabel.heightAnchor.constraint(equalToConstant: errorMessageLabelHeight).isActive = true
        errorMessageLabel.text = ""

        let nextButtonTopConstraint = nextButton.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: nextButtonTopMargin)
        nextButtonTopConstraint.isActive = true
        nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: nextButtonLeadingTrailingMargin).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -nextButtonLeadingTrailingMargin).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: nextButtonHeight).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = NSLocalizedString("SignUpScreenTitle", comment: "")
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

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let signUpTextField = textField.superview as? SignUpTextField {
            if signUpTextField == emailAddressTextField  {
                if let emailAddress = textField.text, isValidEmail(emailAddress) {
                    signUpTextField.status = .valid
                } else {
                    signUpTextField.status = .invalid
                }
            } else if signUpTextField == repeatPasswordTextField {
                if let repeatedPassword = textField.text, let password = createPasswordTextField.textField.text, repeatedPassword == password {
                    signUpTextField.status = .valid
                } else {
                    signUpTextField.status = .invalid
                }
            } else if signUpTextField == createPasswordTextField {
                if let repeatedPassword = repeatPasswordTextField.textField.text, repeatedPassword.count > 0 {
                    if let password = textField.text, repeatedPassword == password {
                        repeatPasswordTextField.status = .valid
                    } else {
                        repeatPasswordTextField.status = .invalid
                    }
                }
                if let password = textField.text, password.count >= passwordMinLength  {
                    signUpTextField.status = .valid
                } else {
                    signUpTextField.status = .invalid
                }
            }
        }
        if emailAddressTextField.status == .valid && repeatPasswordTextField.status == .valid && createPasswordTextField.status == .valid {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .skyBlue
            errorMessageLabel.text = ""
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .lightBlueGrey
            var errorMessages: [String] = []
            if emailAddressTextField.status == .invalid {
                errorMessages.append(NSLocalizedString("InvalidEmailAddressErrorMessage", comment: ""))
            }
            if createPasswordTextField.status == .invalid {
                errorMessages.append(NSLocalizedString("passwordMinLengthMessage", comment: ""))
            }
            if repeatPasswordTextField.status == .invalid {
                errorMessages.append(NSLocalizedString("passwordNotMatchMessage", comment: ""))
            }
            if errorMessages.count > 0 {
                errorMessageLabel.text = errorMessages.joined(separator: "\n")
            } else {
                errorMessageLabel.text = ""
            }
        }
    }

    // MARK: - Private
    @objc
    func didTapNextButton() {
        if let emailAddress = emailAddressTextField.textField.text, let password = createPasswordTextField.textField.text {
            AWSMobileClient.default().signUp(username: emailAddress, password: password) { (signupResult, error) in
                var errorMessage: String?
                if error != nil {
                    if let mobileClientError = error as? AWSMobileClientError {
                        switch mobileClientError {
                        case let .usernameExists(message):
                            errorMessage = message
                            break
                        case let .invalidPassword(message):
                            errorMessage = message
                            break
                        case let .userNotConfirmed(message):
                            errorMessage = message
                            break
                        default:
                            errorMessage = NSLocalizedString("genericSignUpErrorMessage", comment: "")
                        }
                    } else {
                        errorMessage = NSLocalizedString("genericSignUpErrorMessage", comment: "")
                    }
                }
                if signupResult != nil {
                    let alertTitle = NSLocalizedString("VerificationEmailSentTitle", comment: "")
                    let alertMessage = NSLocalizedString("VerificationEmailSentMessage", comment: "")
                    let alertController = UIAlertController.init(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                    let okTitle = NSLocalizedString("OKButtonTitle", comment: "")
                    let okAction = UIAlertAction.init(title:okTitle, style:.default) { (action) in
                        DispatchQueue.main.async {
                            self.navigationController?.setViewControllers([SignInViewController.init()], animated: false)
                        }
                    }
                    alertController.addAction(okAction)
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else if errorMessage != nil {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController.init(title: NSLocalizedString("signUpErrorTitle", comment: ""), message: errorMessage, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction.init(title: NSLocalizedString("OKButtonTitle", comment: ""), style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
