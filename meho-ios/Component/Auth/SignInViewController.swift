//
//  SignInViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 5/3/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

class SignInViewController: UIViewController {

    // MARK: - Constants
    private let textFieldFontSize = CGFloat(16)
    private let textFieldCornerRadius = CGFloat(2)
    private let textFieldVerticalMargin = CGFloat(34)
    private let textFieldBackgroundColorAlpha = CGFloat(0.1)
    private let textFieldLeadingTrailingMargin = CGFloat(30)
    private let textFieldHeight = CGFloat(58)
    private let signInButtonLeadingTrailingMargin = CGFloat(58)
    private let signInButtonTopMargin = CGFloat(54)
    private let signInButtonCornerRadius = CGFloat(18)
    private let signInButtonHeight = CGFloat(50)
    private let signInButtonFontSize = CGFloat(20)
    private let forgetPasswordButtonFontSize = CGFloat(16)
    private let forgetPasswordButtonTopMargin = CGFloat(46)
    private let textFieldTopMargin = CGFloat(32)

    // MARK: - Properties

    private lazy var emailAddressField: UITextFieldPadding = {
        let textField = UITextFieldPadding.init()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("EmailAddressPlaceholder", comment: "")
        let fontDescriptor = UIFont.systemFont(ofSize: textFieldFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        textField.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        textField.autocapitalizationType = .none
        textField.textColor = .textCharcoalGrey
        textField.layer.cornerRadius = textFieldCornerRadius
        textField.tintColor = .wisteriaPurple
        textField.backgroundColor = UIColor.skyBlue.withAlphaComponent(textFieldBackgroundColorAlpha)
        textField.keyboardType = .emailAddress
        textField.clipsToBounds = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    } ()

    private lazy var passwordField:UITextFieldPadding = {
        let textField = UITextFieldPadding.init()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("PasswordPlaceholder", comment: "")
        let fontDescriptor = UIFont.systemFont(ofSize: textFieldFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        textField.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        textField.autocapitalizationType = .none
        textField.textColor = .textCharcoalGrey
        textField.layer.cornerRadius = textFieldCornerRadius
        textField.isSecureTextEntry = true
        textField.tintColor = .wisteriaPurple
        textField.backgroundColor = UIColor.skyBlue.withAlphaComponent(textFieldBackgroundColorAlpha)
        textField.clipsToBounds = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    } ()

    private lazy var signInButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonTitle = NSLocalizedString("SignInButtonTitle", comment: "")
        button.setTitle(buttonTitle, for: .normal)
        button.backgroundColor = .lightBlueGrey
        let fontDescriptor = UIFont.systemFont(ofSize: signInButtonFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        button.titleLabel?.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = signInButtonCornerRadius
        button.clipsToBounds = true
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
        return button
    } ()

    private lazy var forgetPasswordButton: UIButton = {
        let forgetPasswordButton = UIButton.init(frame: .zero)
        forgetPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        let forgetPasswordButtonTitle = NSLocalizedString("ForgetPasswordButtonTitle", comment: "")
        forgetPasswordButton.setTitle(forgetPasswordButtonTitle, for: .normal)
        let forgetPasswordButtonFontDescriptor = UIFont.systemFont(ofSize: forgetPasswordButtonFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        forgetPasswordButton.titleLabel?.font = UIFont.init(descriptor: forgetPasswordButtonFontDescriptor!, size: 0)
        forgetPasswordButton.setTitleColor(.greenBlue, for: .normal)
        return forgetPasswordButton
    } ()

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("SignInScreenTitle", comment: "")
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.backgroundColor = .white
        setupEmailAddressTextField()
        setupPasswordTextField()
        setupSignInButton()
        setUpForgetPasswordButton()
    }

    // MARK: - Private Methods
    private func setupEmailAddressTextField() {
        view.addSubview(emailAddressField)

        emailAddressField.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: textFieldTopMargin).isActive = true
        emailAddressField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: textFieldLeadingTrailingMargin).isActive = true
        emailAddressField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -textFieldLeadingTrailingMargin).isActive = true
        emailAddressField.heightAnchor.constraint(equalToConstant: textFieldHeight).isActive = true
    }

    private func setupPasswordTextField() {
        view.addSubview(passwordField)

        passwordField.topAnchor.constraint(equalTo: emailAddressField.bottomAnchor, constant: textFieldVerticalMargin).isActive = true
        passwordField.leadingAnchor.constraint(equalTo: emailAddressField.leadingAnchor).isActive = true
        passwordField.trailingAnchor.constraint(equalTo: emailAddressField.trailingAnchor).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: textFieldHeight).isActive = true
    }

    private func setupSignInButton() {
        view.addSubview(signInButton)

        signInButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: signInButtonTopMargin).isActive = true
        signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: signInButtonLeadingTrailingMargin).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -signInButtonLeadingTrailingMargin).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: signInButtonHeight).isActive = true
    }

    private func setUpForgetPasswordButton() {
        view.addSubview(forgetPasswordButton)

        forgetPasswordButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: forgetPasswordButtonTopMargin).isActive = true
        forgetPasswordButton.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor).isActive = true
    }

    @objc
    private func textFieldDidChange() {
        if let password = passwordField.text, let emailAddress = emailAddressField.text, password.count > 0 && emailAddress.count > 0 {
            signInButton.isEnabled = true
            signInButton.backgroundColor = .skyBlue
        } else {
            signInButton.isEnabled = false
            signInButton.backgroundColor = .lightBlueGrey
        }
    }

    @objc
    private func didTapSignInButton() {
        let un = emailAddressField.text
        passwordField.isSecureTextEntry = false
        let pw2 = passwordField.text
        passwordField.isSecureTextEntry = true
        AWSMobileClient.default().signIn(username: un!, password: pw2!) { (result, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    // TODO: show error message.
                    if let mobileClientError = error as? AWSMobileClientError {
                        switch mobileClientError {
                        case .userNotFound(_):
                            let alertTitle = NSLocalizedString("InvalidEmailTitle", comment: "")
                            let alertMessage = NSLocalizedString("InvalidEmailMessage", comment: "")
                            let alertController = UIAlertController.init(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                            let okTitle = NSLocalizedString("OKButtonTitle", comment: "")
                            let okAction = UIAlertAction.init(title:okTitle, style:.default) { (action) in
                                self.dismiss(animated: true, completion: nil)
                            }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                            break
                        case .notAuthorized(_):
                            let alertTitle = NSLocalizedString("IncorrectPasswordTitle", comment: "")
                            let alertMessage = NSLocalizedString("IncorrectPasswordMessage", comment: "")
                            let alertController = UIAlertController.init(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                            let okTitle = NSLocalizedString("OKButtonTitle", comment: "")
                            let okAction = UIAlertAction.init(title:okTitle, style:.default) { (action) in
                                self.dismiss(animated: true, completion: nil)
                            }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                            break
                        default:
                            break
                        }
                    }
                    return
                }
                guard let state = result?.signInState else { return }
                switch state {
                    case .signedIn:
                        self.navigationController? .setViewControllers([MainViewController.init()], animated: false)
                    default:
                        print ("default")
                }
            }
        }
    }

}

