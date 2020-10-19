//
//  SignInViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 5/3/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient
import Amplify
import AmplifyPlugins

class SignInViewController: UIViewController, OtherSignInViewDelegate, UITextFieldDelegate {

    // MARK: - Constants
    private let textFieldFontSize = CGFloat(16)
    private let textFieldCornerRadius = CGFloat(2)
    private let textFieldVerticalMargin = CGFloat(34)
    private let textFieldBackgroundColorAlpha = CGFloat(0.1)
    private let textFieldLeadingTrailingMargin = CGFloat(30)
    private let textFieldHeight = CGFloat(54)
    private let textFieldCompactHeight = CGFloat(40)
    private let signInButtonLeadingTrailingMargin = CGFloat(58)
    private let signInButtonTopMargin = CGFloat(54)
    private let signInButtonCornerRadius = CGFloat(18)
    private let signInButtonHeight = CGFloat(50)
    private let signInButtonFontSize = CGFloat(20)
    private let forgetPasswordButtonFontSize = CGFloat(16)
    private let forgetPasswordButtonTopMargin = CGFloat(46)
    private let textFieldTopMargin = CGFloat(32)
    private let otherSignInViewLeadingTrailingMargin = CGFloat(20)
    private let otherSignInViewBottomMargin = CGFloat(8)

    // MARK: - Datamodels
    private let userDataFecther = UserDataFetcher.shared

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
        textField.delegate = self
        return textField
    } ()

    private lazy var passwordField: UITextFieldPadding = {
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
        textField.delegate = self
        return textField
    } ()

    private lazy var textFieldsStackView: UIStackView = {
        let textFieldsStackView = UIStackView.init(arrangedSubviews: [emailAddressField, passwordField])
        textFieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        textFieldsStackView.axis = .vertical
        textFieldsStackView.distribution = .fillEqually
        textFieldsStackView.spacing = textFieldVerticalMargin
        return textFieldsStackView
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
        forgetPasswordButton.addTarget(self, action: #selector(didTapForgetPasswordButton), for: .touchUpInside)
        return forgetPasswordButton
    } ()

    private lazy var otherSignInView: OtherSignInView = {
        let otherSignInView = OtherSignInView.init(frame: .zero)
        otherSignInView.translatesAutoresizingMaskIntoConstraints = false
        otherSignInView.delegate = self
        return otherSignInView
    } ()

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.backgroundColor = .white

        view.addSubview(textFieldsStackView)
        let textFieldsStackViewTopConstraint = textFieldsStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: textFieldTopMargin)
        textFieldsStackViewTopConstraint.isActive = true
        textFieldsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: textFieldLeadingTrailingMargin).isActive = true
        textFieldsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -textFieldLeadingTrailingMargin).isActive = true
        let textFieldsStackViewHeight = 2 * textFieldHeight + textFieldVerticalMargin
        let textFieldsStackViewHeightConstraint = textFieldsStackView.heightAnchor.constraint(equalToConstant: textFieldsStackViewHeight)
        textFieldsStackViewHeightConstraint.isActive = true

        view.addSubview(signInButton)
        let signInButtonTopConstraint = signInButton.topAnchor.constraint(equalTo: textFieldsStackView.bottomAnchor, constant: signInButtonTopMargin)
        signInButtonTopConstraint.isActive = true
        signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: signInButtonLeadingTrailingMargin).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -signInButtonLeadingTrailingMargin).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: signInButtonHeight).isActive = true
        setUpOtherSignInView()

        view.addSubview(forgetPasswordButton)
        let forgetPasswordButtonTopConstraint = forgetPasswordButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: forgetPasswordButtonTopMargin)
        forgetPasswordButtonTopConstraint.isActive = true
        forgetPasswordButton.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor).isActive = true
        if textFieldTopMargin + textFieldsStackViewHeight + signInButtonTopMargin + signInButtonHeight + forgetPasswordButtonTopMargin + otherSignInViewBottomMargin + otherSignInView.intrinsicContentSize.height > view.bounds.height {
            textFieldsStackViewTopConstraint.constant = textFieldTopMargin / 2
            textFieldsStackViewHeightConstraint.constant = 2 * textFieldCompactHeight + textFieldVerticalMargin / 2
            textFieldsStackView.spacing = textFieldVerticalMargin / 2
            signInButtonTopConstraint.constant = signInButtonTopMargin / 2
            otherSignInView.isCompact = true
            forgetPasswordButtonTopConstraint.constant = forgetPasswordButtonTopMargin / 2
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = NSLocalizedString("SignInScreenTitle", comment: "")
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    // MARK: - OtherSignInViewDelegate
    func otherSignInViewDidTapURL(_ URL: URL) {
        let title = URL.absoluteString.contains("PrivacyPolicy") ? NSLocalizedString("privacyPolicy", comment: "") : NSLocalizedString("termsOfUse", comment: "")
        let webViewController = WebViewController.init(title: title, contentURL: URL)
        self.title = ""
        navigationController?.pushViewController(webViewController, animated: true)
    }

    func otherSignInViewDidTapFacebookButton() {

    }

    func otherSignInViewDidTapGoogleButton() {

    }

    func otherSignInViewDidTapAppleButton() {

    }

    // MARK: - Private Methods
    private func setUpOtherSignInView() {
        view.addSubview(otherSignInView)

        otherSignInView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -otherSignInViewLeadingTrailingMargin).isActive = true
        otherSignInView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: otherSignInViewLeadingTrailingMargin).isActive = true
        otherSignInView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -otherSignInViewBottomMargin).isActive = true
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
    private func didTapForgetPasswordButton() {
        let resetPasswordViewController = ResetPasswordViewController.init();
        title = ""
        navigationController?.pushViewController(resetPasswordViewController, animated: true)
    }

    @objc
    private func didTapSignInWithFacebook() {
        Amplify.Auth.signInWithWebUI(for: .facebook, presentationAnchor: self.view.window!) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
                let userId = AWSMobileClient.default().userSub!
                self.completeProfileOrNavigateToApp(userId: userId, username: userId)
            case .failure(let error):
                print("Sign in failed \(error)")
            }
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
                        case .userNotConfirmed(_):
                            let alertTitle = NSLocalizedString("EmailUnconfirmedTitle", comment: "")
                            let alertMessage = NSLocalizedString("EmailUnconfirmedMessage", comment: "")
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
                        let userId = AWSMobileClient.default().userSub!
                        self.completeProfileOrNavigateToApp(userId: userId, username: un!)
                    default:
                        print ("default")
                }
            }
        }
    }

    private func completeProfileOrNavigateToApp(userId:String, username: String) {

        self.userDataFecther.getUser(userId: userId) { (maybeUser, error) in
            if (maybeUser == nil) {
                // no user found case, this is new user login, we should create a new user and pop onboarding steps
                self.userDataFecther.createUser(userId: userId, username: username, userEmail: username) { (userCreated, error) in
                    if (error == nil && userCreated != nil && userCreated!.identifier == userId) {
                        self.navigationController?.setViewControllers([CompleteProfileViewStep1Controller.init()], animated: false)
                    }
                }
            } else {
                // user exist case, recurring user, we should pop main screen
                self.navigationController?.setViewControllers([MainViewController.init()], animated: false)
            }
        }
    }

}

