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
import FirebaseAnalytics
import SkyFloatingLabelTextField

class SignInViewController: UIViewController, OtherSignInViewDelegate, UITextFieldDelegate, MehoAnalytics {

    // MARK: - Constants
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

    // MARK: MehoAnalytics
    let screenName = "p_meho_login_signin_email"
    let screenClass =  "p_meho_login_signin"

    // MARK: - Properties
    private lazy var emailAddressField: SignUpTextField = {
        let emailAddressField = SignUpTextField.init(frame:.zero, allowsErrorMessage: false)
        emailAddressField.textField.placeholder = NSLocalizedString("EmailAddressPlaceholder", comment: "")
        emailAddressField.textField.autocapitalizationType = .none
        emailAddressField.textField.keyboardType = .emailAddress
        emailAddressField.textField.title = NSLocalizedString("EmailAddressPlaceholder", comment: "")
        emailAddressField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        emailAddressField.textField.delegate = self
        return emailAddressField
    } ()

    private lazy var passwordField: SignUpTextField = {
        let passwordField = SignUpTextField.init(frame:.zero, allowsErrorMessage: false)
        passwordField.textField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.textField.placeholder = NSLocalizedString("PasswordPlaceholder", comment: "")
        passwordField.textField.autocapitalizationType = .none
        passwordField.textField.isSecureTextEntry = true
        passwordField.textField.title = NSLocalizedString("PasswordPlaceholder", comment: "")
        passwordField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordField.textField.delegate = self
        return passwordField
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
        otherSignInView.isHidden = true
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
        textField.placeholder = ""
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.isDescendant(of: emailAddressField) {
            emailAddressField.status = .valid
            textField.placeholder = NSLocalizedString("EmailAddressPlaceholder", comment: "")
        } else if textField.isDescendant(of: passwordField) {
            passwordField.status = .valid
            textField.placeholder = NSLocalizedString("PasswordPlaceholder", comment: "")
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
        otherSignIn(for: .facebook)
    }

    func otherSignInViewDidTapGoogleButton() {
        otherSignIn(for: .google)
    }

    func otherSignInViewDidTapAppleButton() {
        otherSignIn(for: .apple)
    }

    private func otherSignIn(for authProvider: AuthProvider) {
        Amplify.Auth.signInWithWebUI(for: authProvider, presentationAnchor: self.view.window!) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
                let userId = AWSMobileClient.default().userSub!
                AWSMobileClient.default().getUserAttributes { (maybeAttributes, maybeError) in
                    if maybeError == nil, let attributes = maybeAttributes {
                        if let userEmail = attributes["email"] {
                            self.completeProfileOrNavigateToApp(userId: userId, username: userId, userEmail: userEmail)
                        }
                    } else {
                        self.completeProfileOrNavigateToApp(userId: userId, username: userId, userEmail: userId)
                    }
                }
            case .failure(let error):
                print("Sign in failed \(error)")
            }
        }
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
        if let password = passwordField.textField.text, let emailAddress = emailAddressField.textField.text, password.count > 0 && emailAddress.count > 0 {
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
    private func didTapSignInButton() {
        let un = emailAddressField.textField.text
        passwordField.textField.isSecureTextEntry = false
        let pw2 = passwordField.textField.text
        passwordField.textField.isSecureTextEntry = true
        AWSMobileClient.default().signIn(username: un!, password: pw2!) { (result, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    // TODO: show error message.
                    if let mobileClientError = error as? AWSMobileClientError {
                        var alertTitle = ""
                        var alertMessage = ""
                        var alertScreenName = ""
                        switch mobileClientError {
                        case .userNotFound(_):
                            alertTitle = NSLocalizedString("InvalidEmailTitle", comment: "")
                            alertMessage = NSLocalizedString("InvalidEmailMessage", comment: "")
                            alertScreenName = "p_meho_login_signin_isnvalid_email"
                        case .notAuthorized(_):
                            alertTitle = NSLocalizedString("IncorrectPasswordTitle", comment: "")
                            alertMessage = NSLocalizedString("IncorrectPasswordMessage", comment: "")
                            alertScreenName = "p_meho_login_signin_incorrect_password"
                        case .userNotConfirmed(_):
                            alertTitle = NSLocalizedString("EmailUnconfirmedTitle", comment: "")
                            alertMessage = NSLocalizedString("EmailUnconfirmedMessage", comment: "")
                            alertScreenName = "p_meho_login_signin_unconfirmed_email"
                        default:
                            alertTitle = NSLocalizedString("signInErrorTitle", comment: "")
                            alertMessage = NSLocalizedString("genericSignInErrorMessage", comment: "")
                            alertScreenName = "p_meho_login_signin_general_error"
                        }
                        let alertController = UIAlertController.init(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                        let okTitle = NSLocalizedString("OKButtonTitle", comment: "")
                        let okAction = UIAlertAction.init(title:okTitle, style:.default) { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        let parameters = [
                            AnalyticsParameterScreenName: alertScreenName,
                            AnalyticsParameterScreenClass: self.screenClass
                        ]
                        Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
                    }
                    return
                }
                guard let state = result?.signInState else { return }
                switch state {
                    case .signedIn:
                        let userId = AWSMobileClient.default().userSub!
                        self.completeProfileOrNavigateToApp(userId: userId, username: un!, userEmail: un!)
                    default:
                        print ("default")
                }
            }
        }
    }

    private func completeProfileOrNavigateToApp(userId:String, username: String, userEmail: String) {

        self.userDataFecther.getUser(userId: userId) { (maybeUser, error) in
            if (maybeUser == nil) {
                // no user found case, this is new user login, we should create a new user and pop onboarding steps
                self.userDataFecther.createUser(userId: userId, username: username, userEmail: userEmail) { (userCreated, error) in
                    if (error == nil && userCreated != nil && userCreated!.identifier == userId) {
                        self.navigationController?.setViewControllers([CompleteProfileViewStep1Controller.init()], animated: false)
                    }
                }
            } else {
                // user exist case, recurring user, we should pop main screen
                DispatchQueue.main.async {
                    self.navigationController?.setViewControllers([MainViewController.init()], animated: false)
                }
            }
        }
    }
}

