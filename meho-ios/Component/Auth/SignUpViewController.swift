//
//  SignUpViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 6/14/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

class SignUpViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Constants
    private let textFieldsStackViewHeight = CGFloat(324)
    private let textFieldsStackViewTopMargin = CGFloat(32)
    private let contentViewLeadingTrailingMargin = CGFloat(20)
    private let errorMessageLabelFontSize = CGFloat(16)
    private let errorMessageLabelTopMargin = CGFloat(36)
    private let otherSignInViewBottomMargin = CGFloat(8)
    private let nextButtonTitleFontSize = CGFloat(20)
    private let nextButtonCornerRadius = CGFloat(18)
    private let nextButtonHeight = CGFloat(50)
    private let nextButtonLeadingTrailingMargin = CGFloat(54)
    private let nextButtonTopMargin = CGFloat(32)

    // MARK: - Properties
    private lazy var nickNameTextField: SignUpTextField = {
        let nickNameTextField = SignUpTextField.init(frame: .zero)
        nickNameTextField.translatesAutoresizingMaskIntoConstraints = false
        nickNameTextField.textField.placeholder = NSLocalizedString("NickNamePlaceholder", comment: "")
        nickNameTextField.textField.delegate = self
        return nickNameTextField
    } ()

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
        return errorMessageLabel
    } ()

    private lazy var textFieldsStackView: UIStackView = {
        let textFieldsStackView = UIStackView.init(arrangedSubviews: [nickNameTextField, emailAddressTextField, createPasswordTextField, repeatPasswordTextField])
        textFieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        textFieldsStackView.axis = .vertical
        textFieldsStackView.distribution = .equalSpacing
        return textFieldsStackView
    } ()

    private lazy var otherSignInView: OtherSignInView = {
        let otherSignInView = OtherSignInView.init(frame: .zero)
        otherSignInView.translatesAutoresizingMaskIntoConstraints = false
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

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("SignUpScreenTitle", comment: "")
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.backgroundColor = .white
        view.addSubview(textFieldsStackView)
        view.addSubview(otherSignInView)
        view.addSubview(errorMessageLabel)
        view.addSubview(nextButton)

        textFieldsStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: textFieldsStackViewTopMargin).isActive = true
        textFieldsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentViewLeadingTrailingMargin).isActive = true
        textFieldsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentViewLeadingTrailingMargin).isActive = true
        textFieldsStackView.heightAnchor.constraint(equalToConstant: textFieldsStackViewHeight).isActive = true

        otherSignInView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentViewLeadingTrailingMargin).isActive = true
        otherSignInView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentViewLeadingTrailingMargin).isActive = true
        otherSignInView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -otherSignInViewBottomMargin).isActive = true

        errorMessageLabel.topAnchor.constraint(equalTo: textFieldsStackView.bottomAnchor, constant: errorMessageLabelTopMargin).isActive = true
        errorMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentViewLeadingTrailingMargin).isActive = true
        errorMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentViewLeadingTrailingMargin).isActive = true

        nextButton.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: nextButtonTopMargin).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: nextButtonLeadingTrailingMargin).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -nextButtonLeadingTrailingMargin).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: nextButtonHeight).isActive = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let signUpTextField = textField.superview as? SignUpTextField {
            if signUpTextField == emailAddressTextField  {
                if let emailAddress = textField.text, isValidEmail(emailAddress) {
                    signUpTextField.status = .valid
                } else {
                    signUpTextField.status = .invalid
                    errorMessageLabel.text = NSLocalizedString("InvalidEmailAddressErrorMessage", comment: "")
                }
            } else if signUpTextField == repeatPasswordTextField {
                if let repeatedPassword = textField.text, let password = createPasswordTextField.textField.text, repeatedPassword == password {
                    signUpTextField.status = .valid
                } else {
                    signUpTextField.status = .invalid
                }
            } else if signUpTextField == createPasswordTextField {
                if let repeatedPassword = textField.text, let password = createPasswordTextField.textField.text, repeatedPassword == password {
                    repeatPasswordTextField.status = .valid
                } else {
                    repeatPasswordTextField.status = .invalid
                }
            }
        }
        if emailAddressTextField.status == .valid && repeatPasswordTextField.status == .valid {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .skyBlue
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .lightBlueGrey
        }
    }

    // MARK: - Private
    @objc
    func didTapNextButton() {
        if let emailAddress = emailAddressTextField.textField.text, let password = createPasswordTextField.textField.text {
            AWSMobileClient.default().signUp(username: emailAddress, password: password) { (signupResult, error) in
                DispatchQueue.main.async {
                    self.navigationController? .setViewControllers([MainViewController.init()], animated: false)
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
