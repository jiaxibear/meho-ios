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

class MehoCoverViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants
    private let buttonLabelFontSize = CGFloat(20)
    private let titleLabelText = "Meho Stories"
    private let buttonCornerRadius = CGFloat(18)

    private let cardInsets = CGFloat(32)
    private let pageControlToSignUpMargin = CGFloat(40)
    private let buttonHorizontalMargin = CGFloat(58)
    private let verticalMarginScreenPct = CGFloat(1.0/40.0)
    private let collectionViewTopMargin = CGFloat(40)
    private let collectionViewHeightScreenPct = CGFloat(3.2 / 5.0)
    private let buttonHeightScreenPct = CGFloat(1.0/20.0)

    private let introCellReuseIdentifier = "mehoIntroCellId"

    // MARK: - Data models
    private lazy var coverIntroList: [CoverIntro] = {
        let stories = CoverIntro.init(title: NSLocalizedString("coverStoriesTitle", comment: ""), subtitle: NSLocalizedString("coverStoriesSubtitle", comment: ""), backgroundColor: .lighterPurple)
        let expressions = CoverIntro.init(title: NSLocalizedString("coverExpressionsTitle", comment: ""), subtitle: NSLocalizedString("coverExpressionsSubtitle", comment: ""), backgroundColor: .periwinkle)
        let talk = CoverIntro.init(title: NSLocalizedString("coverTalkTitle", comment: ""), subtitle: NSLocalizedString("coverTalkSubtitle", comment: ""), backgroundColor: .periwinkleBlue)
        return [stories, expressions, talk]
    } ()

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

    private lazy var signUpButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonTitle = NSLocalizedString("SignUpButtonTitle", comment: "")
        button.setTitle(buttonTitle, for: .normal)
        button.backgroundColor = .wisteriaPurple
        let fontDescriptor = UIFont.systemFont(ofSize: buttonLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        button.titleLabel?.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = buttonCornerRadius
        button.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        return button
    } ()

    private lazy var signInButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonTitle = NSLocalizedString("SignInButtonTitle", comment: "")
        button.setTitle(buttonTitle, for: .normal)
        button.backgroundColor = .skyBlue
        let fontDescriptor = UIFont.systemFont(ofSize: buttonLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        button.titleLabel?.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = buttonCornerRadius
        button.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
        return button
    } ()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView.init()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.backgroundColor = .white
        return activityIndicatorView
    } ()

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
                        self.navigationController?.setViewControllers([MainViewController.init()], animated: false)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                    }
                }
            }
        }
        title = ""
        view.backgroundColor = .white
        setupStoryCollectionView()
        setupPageControl()
        setupSignUpButton()
        setupSignInButton()
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicatorView.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func setupStoryCollectionView() {
        view.addSubview(storyCollectionView)
        let screenHeight = view.bounds.height - collectionViewTopMargin
        storyCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        storyCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        storyCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: collectionViewTopMargin).isActive = true
        storyCollectionView.heightAnchor.constraint(equalToConstant: screenHeight * collectionViewHeightScreenPct).isActive = true
    }

    func setupPageControl() {
        view.addSubview(pageControl)
        let screenHeight = view.bounds.height - collectionViewTopMargin
        pageControl.topAnchor.constraint(equalTo: storyCollectionView.bottomAnchor, constant: screenHeight * verticalMarginScreenPct).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func setupSignUpButton() {
        view.addSubview(signUpButton)
        let screenHeight = view.bounds.height - collectionViewTopMargin
        signUpButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: screenHeight * verticalMarginScreenPct).isActive = true
        signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: buttonHorizontalMargin).isActive = true
        signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -buttonHorizontalMargin).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: screenHeight * buttonHeightScreenPct).isActive = true
    }

    func setupSignInButton() {
        view.addSubview(signInButton)
        let screenHeight = view.bounds.height - collectionViewTopMargin
        signInButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: screenHeight * verticalMarginScreenPct).isActive = true
        signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: buttonHorizontalMargin).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -buttonHorizontalMargin).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: screenHeight * buttonHeightScreenPct).isActive = true
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coverIntroList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: introCellReuseIdentifier, for: indexPath) as! MehoCoverIntroCollectionViewCell
        let coverIntro = coverIntroList[indexPath.item]
        cell.setCoverIntro(coverIntro)
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
}
