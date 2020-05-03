//
//  SignInViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 2/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

class MehoCoverViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants
    private let buttonLabelFontSize = CGFloat(20)
    private let titleLabelText = "Meho Stories"
    private let buttonCornerRadius = CGFloat(18)

    private let cardInsets = CGFloat(32)
    private let pageControlToSignUpMargin = CGFloat(40)
    private let buttonHorizontalMargin = CGFloat(58)
    private let verticalMarginScreenPct = CGFloat(1.0/40.0)
    private let collectionViewHeightScreenPct = CGFloat(3.2 / 5.0)
    private let buttonHeightScreenPct = CGFloat(1.0/20.0)

    private let introCellReuseIdentifier = "mehoIntroCellId"

    // MARK: - Data models
    private let storyNameList:[String] = ["meho_cover_stories", "meho_cover_expressions" ,"meho_cover_talk"]

    // MARK: - Properties

    private lazy var storiesCollectionViewFlowLayout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = cardInsets
        return layout
    } ()
    private lazy var storyollectionView:UICollectionView = {
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout:storiesCollectionViewFlowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: cardInsets, bottom: 0, right: cardInsets)
        collectionView.isPagingEnabled = true
        // Sets up cell data
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MehoCoverIntroCollectionViewCell.self, forCellWithReuseIdentifier:introCellReuseIdentifier)
        return collectionView
    } ()

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = storyNameList.count
        pc.currentPage = 0
        pc.pageIndicatorTintColor = .paleLilac
        pc.currentPageIndicatorTintColor = .darkGray
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    private lazy var signUpButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .skyBlue
        let fontDescriptor = UIFont.systemFont(ofSize: buttonLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        button.titleLabel?.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = buttonCornerRadius
//        button.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        return button
    } ()

    private lazy var signInButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .skyBlue
        let fontDescriptor = UIFont.systemFont(ofSize: buttonLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        button.titleLabel?.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = buttonCornerRadius
//        button.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        return button
    } ()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .white
        setupStoryCollectionView()
        setupPageControl()
        setupSignUpButton()
        setupSignInButton()
    }

    func setupStoryCollectionView() {
        view.addSubview(storyollectionView)
        let screenHeight = view.bounds.height
        storyollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        storyollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        storyollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: screenHeight * verticalMarginScreenPct).isActive = true
        storyollectionView.heightAnchor.constraint(equalToConstant: screenHeight * collectionViewHeightScreenPct).isActive = true

    }

    func setupPageControl() {
        view.addSubview(pageControl)
        let screenHeight = view.bounds.height
        pageControl.topAnchor.constraint(equalTo: storyollectionView.bottomAnchor, constant: screenHeight * verticalMarginScreenPct).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func setupSignUpButton() {
        view.addSubview(signUpButton)
        let screenHeight = view.bounds.height
        signUpButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: screenHeight * verticalMarginScreenPct).isActive = true
        signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: buttonHorizontalMargin).isActive = true
        signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -buttonHorizontalMargin).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: screenHeight * buttonHeightScreenPct).isActive = true
    }

    func setupSignInButton() {
        view.addSubview(signInButton)
        let screenHeight = view.bounds.height
        signInButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: screenHeight * verticalMarginScreenPct).isActive = true
        signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: buttonHorizontalMargin).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -buttonHorizontalMargin).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: screenHeight * buttonHeightScreenPct).isActive = true
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyNameList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: introCellReuseIdentifier, for: indexPath) as! MehoCoverIntroCollectionViewCell
        let storyName = storyNameList[indexPath.item]
        cell.setStoryCardData(name: storyName)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width - 2 * cardInsets
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }

//    // Scroll to next cell if half of current cell is moved out of screen
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        var indexPaths = storyollectionView.indexPathsForVisibleItems
        indexPaths.sort()
        var index = indexPaths.first!
        let currentCell = storyollectionView.cellForItem(at: index)!
        let position = storyollectionView.contentOffset.x - currentCell.frame.origin.x
        if position > (currentCell.frame.size.width / 2) {
           index.row = index.row + 1
        }
        storyollectionView.scrollToItem(at: index, at: .left, animated: true )
        pageControl.currentPage = Int(index.row)
    }

    // MARK: - Views
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // uncomment next line if you want enforce login every time app launch
            // logout()
//            self.checkSignIn()
        }

    func checkSignIn() {
        if AWSMobileClient.default().isSignedIn {
            // sign in func
            self.navigationController? .setViewControllers([MainViewController.init()], animated: false)
        }
        else {
            let options = SignInUIOptions(canCancel: false)
            AWSMobileClient.default().showSignIn(navigationController: self.navigationController!, signInUIOptions: options) { (userState, error) in
                guard error == nil else { return }
                guard let state =   userState else { return }
                
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
