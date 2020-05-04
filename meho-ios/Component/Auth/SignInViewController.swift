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
    private let labelFontSize = CGFloat(20)
    private let cornerRadius = CGFloat(6)
    private let verticalMargin = CGFloat(10)

    private let inputFieldWidth = CGFloat(280)
    private let inputFieldHeight = CGFloat(40)

    // MARK: - Properties
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        let logoImage = UIImage.init(named: "auth_logo")
        imageView.image = logoImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    } ()

    private lazy var usernameField:UITextFieldPadding = {
        let textField = UITextFieldPadding.init()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Email Address"
        let fontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        textField.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        textField.autocapitalizationType = .none
        textField.textColor = .darkGrayTwo
        textField.layer.cornerRadius = cornerRadius
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.wisteriaPurple.cgColor
        textField.tintColor = .wisteriaPurple
        return textField
    } ()

    private lazy var passwordField:UITextFieldPadding = {
        let textField = UITextFieldPadding.init()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        let fontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        textField.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        textField.textColor = .darkGrayTwo
        textField.layer.cornerRadius = cornerRadius
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.wisteriaPurple.cgColor
        textField.isSecureTextEntry = true
        textField.tintColor = .wisteriaPurple
        return textField
    } ()

    private lazy var signInButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .wisteriaPurple
        let fontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        button.titleLabel?.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = cornerRadius
        button.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
        return button
    } ()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "SIGN IN"
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupLogoImage()
        setupUsernameInput()
        setupPasswordInput()
        setupSignInButton()
    }

    private func setupLogoImage() {
        view.addSubview(logoImageView)
        // constraints
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: verticalMargin).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: CGFloat(200)).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: CGFloat(200)).isActive = true
    }

    private func setupUsernameInput() {
        view.addSubview(usernameField)

        usernameField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: verticalMargin).isActive = true
        usernameField.widthAnchor.constraint(equalToConstant: inputFieldWidth).isActive = true
        usernameField.heightAnchor.constraint(equalToConstant: inputFieldHeight).isActive = true
    }

    private func setupPasswordInput() {
        view.addSubview(passwordField)

        passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: verticalMargin).isActive = true
        passwordField.widthAnchor.constraint(equalToConstant: inputFieldWidth).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: inputFieldHeight).isActive = true
    }

    private func setupSignInButton() {
        view.addSubview(signInButton)

        signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signInButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: verticalMargin * 2).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: inputFieldWidth).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: inputFieldHeight).isActive = true
    }


    @objc
    func didTapSignInButton() {
        let un = usernameField.text
        passwordField.isSecureTextEntry = false
        let pw2 = passwordField.text
        passwordField.isSecureTextEntry = true
        AWSMobileClient.default().signIn(username: un!, password: pw2!) { (result, error) in
            guard error == nil else { return }
            guard let state =   result?.signInState else { return }
            switch state {
                case .signedIn:
                    DispatchQueue.main.async {
                        self.navigationController? .setViewControllers([MainViewController.init()], animated: false)
                    }
                default:
                    print ("default")
            }
        }
    }

}

