//
//  SignInViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 2/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient
import FirebaseAnalytics
import Amplify

class MehoCoverViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate, MehoAnalytics {

    // MARK: - Constants
    private let buttonLabelFontSize = CGFloat(20)
    private let titleLabelText = "Meho Stories"

    private let cardInsets = CGFloat(32)
    private let collectionViewTopMargin = CGFloat(40)

    private let buttonDefaultHeight = CGFloat(44)
    private let buttonHorizontalMargin = CGFloat(56)
    private let buttonDefaultSpacing = CGFloat(16)
    private let buttonCornerRadius = CGFloat(6)
    private let buttonBorderWidth = CGFloat(1)
    private let buttonFontSize = CGFloat(18)
    private let buttonImageEdgeInsetLeft = CGFloat(14)
    private let buttonTitleEdgeInsetLeft = CGFloat(26)
    private let switchSignInSignupTextFontSize = CGFloat(16)
    private let pageControlTopMargin = CGFloat(20)
    private let compactRatio = CGFloat(0.85)
    private let minBottomMargin = CGFloat(20)

    private let introCellReuseIdentifier = "mehoIntroCellId"

    // MARK: - Data models
    private let userDataFecther = UserDataFetcher.shared
    
    private lazy var coverIntroList: [CoverIntro] = {
        let stories = CoverIntro.init(title: NSLocalizedString("coverStoriesTitle", comment: ""), image: UIImage.init(named: "login_preview_stories"))
        let expressions = CoverIntro.init(title: NSLocalizedString("coverExpressionsTitle", comment: ""), image: UIImage.init(named: "login_preview_expressions"))
        let talk = CoverIntro.init(title: NSLocalizedString("coverTalkTitle", comment: ""), image: UIImage.init(named: "login_preview_talk"))
        return [stories, expressions, talk]
    } ()

    private var notificationURLString: String?

    // MARK: MehoAnalytics
    var screenName = "p_meho_login_signup_home"
    var screenClass =  "p_meho_login_signup"

    // MARK: - Properties
    private lazy var storiesCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = cardInsets * 2
        return layout
    } ()
    
    private lazy var storyCollectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout:storiesCollectionViewFlowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        // Sets up cell data
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MehoCoverIntroCollectionViewCell.self, forCellWithReuseIdentifier:introCellReuseIdentifier)
        collectionView.isPagingEnabled = true
        return collectionView
    } ()

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = coverIntroList.count
        pc.currentPage = 0
        pc.pageIndicatorTintColor = .paleLilac
        pc.currentPageIndicatorTintColor = .darkGray
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView.init()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.backgroundColor = .white
        return activityIndicatorView
    } ()

    private lazy var emailButton: UIButton = {
        let title = NSLocalizedString("SignUpWithEmailButtonTitle", comment: "")
        let image = UIImage.init(named: "login_email")
        let emailButton = signUpButton(title: title, image: image)
        emailButton.addTarget(self, action: #selector(didTapEmailButton), for: .touchUpInside)
        return emailButton
    } ()

    private lazy var googleButton: UIButton = {
        let title = NSLocalizedString("SignUpWithGoogleButtonTitle", comment: "")
        let image = UIImage.init(named: "login_google")
        let googleButton = signUpButton(title: title, image: image)
        googleButton.addTarget(self, action: #selector(didTapGoogleButton), for: .touchUpInside)
        return googleButton
    } ()

    private lazy var facebookButton: UIButton = {
        let title = NSLocalizedString("SignUpWithFacebookButtonTitle", comment: "")
        let image = UIImage.init(named: "login_facebook")
        let facebookButton = signUpButton(title: title, image: image)
        facebookButton.addTarget(self, action: #selector(didTapFacebookButton), for: .touchUpInside)
        return facebookButton
    } ()

    private lazy var appleButton: UIButton = {
        let title = NSLocalizedString("SignUpWithAppleButtonTitle", comment: "")
        var image = UIImage.init(systemName: "applelogo")
        if image == nil {
            image = UIImage.init(named: "apple_icon")
        }
        let appleButton = signUpButton(title: title, image: image)
        appleButton.addTarget(self, action: #selector(didTapAppleButton), for: .touchUpInside)
        return appleButton
    } ()

    private lazy var switchSignInSignupTextView: UITextView = {
        let switchSignInSignupTextView = UITextView.init(frame: .zero)
        switchSignInSignupTextView.translatesAutoresizingMaskIntoConstraints = false
        switchSignInSignupTextView.isScrollEnabled = false
        switchSignInSignupTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.greenBlue]
        switchSignInSignupTextView.delegate = self
        switchSignInSignupTextView.isEditable = false
        return switchSignInSignupTextView
    } ()

    private lazy var buttonsStackView: UIStackView = {
        let buttonsStackView = UIStackView.init(arrangedSubviews: [emailButton, googleButton, facebookButton, appleButton, switchSignInSignupTextView])
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.spacing = buttonDefaultSpacing
        buttonsStackView.axis = .vertical
        return buttonsStackView
    } ()

    private lazy var buttonsStackViewLayoutGuide: UILayoutGuide = {
        let buttonsStackViewLayoutGuide = UILayoutGuide.init()
        return buttonsStackViewLayoutGuide
    } ()

    private lazy var storiesCollectionViewHeight: CGFloat = {
        let width = view.frame.width - 2 * cardInsets
        return MehoCoverIntroCollectionViewCell.cellHeight(width: width)
    } ()

    private var isSignUp = true {
        didSet {
            if isSignUp {
                let switchSignInSignupTextFormat = NSLocalizedString("SignInText", comment: "")
                let signInText = NSLocalizedString("SignInButtonTitle", comment: "")
                setUpTextView(switchSignInSignupTextFormat: switchSignInSignupTextFormat, linkTitle: signInText)
                emailButton.setTitle(NSLocalizedString("SignUpWithEmailButtonTitle", comment: ""), for: .normal)
                googleButton.setTitle(NSLocalizedString("SignUpWithGoogleButtonTitle", comment: ""), for: .normal)
                facebookButton.setTitle(NSLocalizedString("SignUpWithFacebookButtonTitle", comment: ""), for: .normal)
                appleButton.setTitle(NSLocalizedString("SignUpWithAppleButtonTitle", comment: ""), for: .normal)
                screenName = "p_meho_login_signup_home"
                screenClass = "p_meho_login_signup"
            } else {
                let switchSignInSignupTextFormat = NSLocalizedString("SignUpText", comment: "")
                let signUpText = NSLocalizedString("SignUpButtonTitle", comment: "")
                setUpTextView(switchSignInSignupTextFormat: switchSignInSignupTextFormat, linkTitle: signUpText)
                emailButton.setTitle(NSLocalizedString("SignInWithEmailButtonTitle", comment: ""), for: .normal)
                googleButton.setTitle(NSLocalizedString("SignInWithGoogleButtonTitle", comment: ""), for: .normal)
                facebookButton.setTitle(NSLocalizedString("SignInWithFacebookButtonTitle", comment: ""), for: .normal)
                appleButton.setTitle(NSLocalizedString("SignInWithAppleButtonTitle", comment: ""), for: .normal)
                screenName = "p_meho_login_signin_home"
                screenClass = "p_meho_login_signin"
            }
            Analytics.logScreenViewEvent(viewController: self)
        }
    }

    // MARK: - Initializers
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(type: NotificationSoftAskType)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(type: NotificationSoftAskType)")
    }

    init(notificationURLString: String?) {
        self.notificationURLString = notificationURLString
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let mobileClient = AWSMobileClient.default()
        if mobileClient.isSignedIn {
            activityIndicatorView.startAnimating()
            // sign in func
            mobileClient.getTokens { (tokens, error) in
                if tokens != nil && error == nil {
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        self.navigationController?.setViewControllers([MainViewController.init(notificationURLString: self.notificationURLString)], animated: false)
                    }
                } else {
                    mobileClient.signOut()
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                    }
                }
            }
        }
        title = ""
        view.backgroundColor = .white
        view.addSubview(storyCollectionView)
        view.addSubview(pageControl)
        view.addLayoutGuide(buttonsStackViewLayoutGuide)
        view.addSubview(buttonsStackView)
        view.addSubview(activityIndicatorView)

        adjustButtonTitleEdgeInsets()
        isSignUp = true

        let availableHeight = view.layoutMarginsGuide.layoutFrame.height
        let buttonsStackViewWidth = view.bounds.width - 2 * buttonHorizontalMargin
        let switchSignInSignupTextViewHeight = switchSignInSignupTextView.sizeThatFits(CGSize.init(width: buttonsStackViewWidth, height: .greatestFiniteMagnitude)).height
        var buttonHeight = buttonDefaultHeight
        var buttonSpacing = buttonDefaultSpacing
        var buttonsStackViewHeight = 4 * buttonHeight + 4 * buttonSpacing + switchSignInSignupTextViewHeight
        let buttonsStackViewMaxHeight = availableHeight - (collectionViewTopMargin + storiesCollectionViewHeight + pageControlTopMargin + pageControl.intrinsicContentSize.height)
        if (buttonsStackViewHeight + minBottomMargin) > buttonsStackViewMaxHeight {
            buttonHeight = buttonDefaultHeight * compactRatio
            buttonSpacing = buttonDefaultSpacing * compactRatio
            buttonsStackViewHeight = 4 * buttonHeight + 4 * buttonSpacing + switchSignInSignupTextViewHeight
            buttonsStackView.spacing = buttonSpacing
        }

        NSLayoutConstraint.activate([
            activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicatorView.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            storyCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            storyCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            storyCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: collectionViewTopMargin),
            storyCollectionView.heightAnchor.constraint(equalToConstant: storiesCollectionViewHeight),

            pageControl.topAnchor.constraint(equalTo: storyCollectionView.bottomAnchor, constant: pageControlTopMargin),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            buttonsStackViewLayoutGuide.topAnchor.constraint(equalTo: pageControl.bottomAnchor),
            buttonsStackViewLayoutGuide.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            buttonsStackViewLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsStackViewLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            buttonsStackView.centerYAnchor.constraint(equalTo: buttonsStackViewLayoutGuide.centerYAnchor),
            buttonsStackView.centerXAnchor.constraint(equalTo: buttonsStackViewLayoutGuide.centerXAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: buttonsStackViewHeight),
            buttonsStackView.widthAnchor.constraint(equalToConstant: buttonsStackViewWidth),

            emailButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            googleButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            facebookButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            appleButton.heightAnchor.constraint(equalToConstant: buttonHeight),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coverIntroList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: introCellReuseIdentifier, for: indexPath) as! MehoCoverIntroCollectionViewCell
        let coverIntro = coverIntroList[indexPath.item]
        cell.coverIntro = coverIntro
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: cardInsets, bottom: 0, right: cardInsets)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width - 2 * cardInsets
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        if width == 0 {
            return
        }
        let offSet = scrollView.contentOffset.x
        let horizontalCenter = width / 2

        pageControl.currentPage = Int(offSet + horizontalCenter) / Int(width)
    }

    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        isSignUp = !isSignUp
        var parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        if isSignUp {
            parameters[MehoAnalyticsUtils.MehoAnalyticsParameterControlName] = "switch_signup"
            parameters[MehoAnalyticsUtils.MehoAnalyticsParameterControlID] = "p_meho_login_signup_home-switch_signup"
        } else {
            parameters[MehoAnalyticsUtils.MehoAnalyticsParameterControlName] = "switch_signin"
            parameters[MehoAnalyticsUtils.MehoAnalyticsParameterControlID] = "p_meho_login_signup_home-switch_signin"
        }
        return false
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }

    @objc
    func didTapSignInButton() {
        let signInController = SignInViewController.init()
        navigationController?.pushViewController(signInController, animated: true)
    }

    @objc
    func didTapSignUpButton() {
        let signUpController = SignUpViewController.init()
        navigationController?.pushViewController(signUpController, animated: true)
    }

    private func signUpButton(title: String, image: UIImage?) -> UIButton {
        let signUpButton = UIButton.init(frame: .zero)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.layer.cornerRadius = buttonCornerRadius
        signUpButton.layer.masksToBounds = true
        signUpButton.layer.borderColor = UIColor.black.cgColor
        signUpButton.layer.borderWidth = buttonBorderWidth
        signUpButton.setTitle(title, for: .normal)
        signUpButton.setImage(image, for: .normal)
        signUpButton.setTitleColor(.black, for: .normal)
        signUpButton.tintColor = .black
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize, weight: .medium)
        signUpButton.contentHorizontalAlignment = .leading
        signUpButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: buttonImageEdgeInsetLeft, bottom: 0, right: 0)
        signUpButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: buttonTitleEdgeInsetLeft, bottom: 0, right: 0)
        signUpButton.imageView?.contentMode = .scaleAspectFit
        return signUpButton
    }

    private func adjustButtonTitleEdgeInsets() {
        guard let emailButtonImageWidth = emailButton.imageView?.image?.size.width, let googleButtonImageWidth = googleButton.imageView?.image?.size.width, let facebookButtonImageWidth = facebookButton.imageView?.image?.size.width, let appleButtonImageWidth = appleButton.imageView?.image?.size.width else {
            return
        }
        let emailContentEdgeInsetsLeft = emailButton.contentEdgeInsets.left
        let googleDiff = googleButtonImageWidth - emailButtonImageWidth
        googleButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: emailContentEdgeInsetsLeft - googleDiff / 2, bottom: 0, right: 0)
        googleButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: buttonTitleEdgeInsetLeft - googleDiff / 2, bottom: 0, right: 0)
        let facebookDiff = facebookButtonImageWidth - emailButtonImageWidth
        facebookButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: emailContentEdgeInsetsLeft - facebookDiff / 2, bottom: 0, right: 0)
        facebookButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: buttonTitleEdgeInsetLeft - facebookDiff / 2, bottom: 0, right: 0)
        let appleDiff = appleButtonImageWidth - emailButtonImageWidth
        appleButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: emailContentEdgeInsetsLeft - appleDiff / 2, bottom: 0, right: 0)
        appleButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: buttonTitleEdgeInsetLeft - appleDiff / 2, bottom: 0, right: 0)
    }

    private func setUpTextView(switchSignInSignupTextFormat: String, linkTitle: String) {
        let switchSignInSignupText = String.init(format: switchSignInSignupTextFormat, linkTitle)
        let switchSignInSignupAttributedText = NSMutableAttributedString.init(string: switchSignInSignupText)
        switchSignInSignupAttributedText.addAttributes([.font : UIFont.systemFont(ofSize: switchSignInSignupTextFontSize)], range: NSRange.init(location: 0, length: switchSignInSignupText.count))
        switchSignInSignupAttributedText.addAttributes([.foregroundColor : UIColor.black], range: NSRange.init(location: 0, length: switchSignInSignupText.count))
        if let mehoURL = NSURL.init(string: "www.wearemeho.com") {
            switchSignInSignupAttributedText.addAttributes([.link : mehoURL], range: switchSignInSignupAttributedText.mutableString.range(of: linkTitle))
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        switchSignInSignupAttributedText.addAttributes([.paragraphStyle : paragraphStyle], range: NSRange.init(location: 0, length: switchSignInSignupText.count))
        switchSignInSignupTextView.attributedText = switchSignInSignupAttributedText
    }

    @objc
    private func didTapEmailButton() {
        var parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]

        if isSignUp {
            let signUpController = SignUpViewController.init()
            navigationController?.pushViewController(signUpController, animated: true)
            parameters[MehoAnalyticsUtils.MehoAnalyticsParameterControlName] = "signup_email"
            parameters[MehoAnalyticsUtils.MehoAnalyticsParameterControlID] = "p_meho_login_signup_home-signup_email"
        } else {
            let signInController = SignInViewController.init()
            navigationController?.pushViewController(signInController, animated: true)
            parameters[MehoAnalyticsUtils.MehoAnalyticsParameterControlName] = "signin_email"
            parameters[MehoAnalyticsUtils.MehoAnalyticsParameterControlID] = "p_meho_login_signin_home-signin_email"
        }
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
    }

    @objc
    private func didTapGoogleButton() {
        otherSignIn(for: .google)
    }

    @objc
    private func didTapFacebookButton() {
        otherSignIn(for: .facebook)
    }

    @objc
    private func didTapAppleButton() {
        otherSignIn(for: .apple)
    }

    private func otherSignIn(for authProvider: AuthProvider) {
        var parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        var controlName: String?
        var controlID: String?
        switch authProvider {
        case .amazon:
            return
        case .apple:
            if isSignUp {
                controlName = "signup_apple"
                controlID = "p_meho_login_signup_home-signup_apple"
            } else {
                controlName = "signin_apple"
                controlID = "p_meho_login_signin_home-signin_apple"
            }
        case .facebook:
            if isSignUp {
                controlName = "signup_facebook"
                controlID = "p_meho_login_signup_home-signup_facebook"
            } else {
                controlName = "signin_facebook"
                controlID = "p_meho_login_signin_home-signin_facebook"
            }
        case .google:
            if isSignUp {
                controlName = "signup_google"
                controlID = "p_meho_login_signup_home-signup_google"
            } else {
                controlName = "signin_google"
                controlID = "p_meho_login_signin_home-signin_google"
            }
        case .oidc:
            return
        case .saml:
            return
        case .custom(_):
            return
        }
        if let controlName = controlName {
            parameters[MehoAnalyticsUtils.MehoAnalyticsParameterControlName] = controlName
        }
        if let controlID = controlID {
            parameters[MehoAnalyticsUtils.MehoAnalyticsParameterControlID] = controlID
        }
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
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
                    self.navigationController?.setViewControllers([MainViewController.init(notificationURLString: nil)], animated: false)
                }
            }
        }
    }
}
