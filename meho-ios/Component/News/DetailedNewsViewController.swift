//
//  DetailedNewsViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/4/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class DetailedNewsViewController: UIViewController {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(22)
    private let titleLabelFontSize = CGFloat(24)
    private let languageToggleLabelFontSize = CGFloat(14)
    private let bottomBarHeight = CGFloat(66)

    private let likeHeartMargin = CGFloat(10)
    private let likeHeartSideLength = CGFloat(50)

    private let newsTabBarItemImageName = "tabbar_news_25pt"
    private let newsLikeHeartUnfilledImageName = "stories_heart_unfilled"
    private let newsLikeHeartFilledImageName = "stories_heart_filled"

    private let languageToggleEnText = "ENG"
    private let languageToggleZhText = "中"

    // MARK: - Properties
    private let newsID: String
    private let title_en: String
    private let title_zh: String

    // MARK: - UI
    private var singleNewsView: UIView!
    private let likeButton = UIButton.init(frame: .zero)
    private let languageToggleButton = UISwitch.init(frame: .zero)
    private let languageToggleEnLabel = UILabel.init(frame: .zero)
    private let languageToggleZhLabel = UILabel.init(frame: .zero)
    private let bottomBarView = UIView.init(frame: .zero)

    // MARK: - TEMP TESTING
    private let singleEnNewsViewController:SingleEnglishNewsViewController
    private let singleZhNewsViewController:SingleChineseNewsViewController

    // MARK: - Init
    init() {
        fatalError("Use init")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    init(newsID: String, title_en: String, title_zh: String) {
        self.newsID = newsID
        self.title_en = title_en
        self.title_zh = title_zh
        singleEnNewsViewController = SingleEnglishNewsViewController.init(title_en: title_en)
        singleZhNewsViewController = SingleChineseNewsViewController.init(title_zh: title_zh, title_en: title_en)
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "MEHO"
        view.backgroundColor = .white

        // Sets up SingleNewsView
        addChild(singleEnNewsViewController)
        singleEnNewsViewController.didMove(toParent: self)
        singleNewsView = singleEnNewsViewController.view
        singleNewsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(singleNewsView)

        // Sets up the bottom bar
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.layer.shadowColor = UIColor.barShadow.cgColor
        bottomBarView.layer.shadowOpacity = 1
        bottomBarView.layer.shadowOffset = .zero
        bottomBarView.layer.shadowRadius = 4
        bottomBarView.layer.masksToBounds = false
        bottomBarView.backgroundColor = .white
        view.addSubview(bottomBarView)

        // Set up the heart
        let newsLikeHeartUnfilledImage = UIImage.init(named: newsLikeHeartUnfilledImageName)
        let newsLikeHeartFilledImag = UIImage.init(named: newsLikeHeartFilledImageName)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setImage(newsLikeHeartUnfilledImage, for: UIControl.State.normal)
        likeButton.setImage(newsLikeHeartFilledImag, for: UIControl.State.selected)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        bottomBarView.addSubview(likeButton)

        // Set up the lanuguage switch
        languageToggleButton.translatesAutoresizingMaskIntoConstraints = false
        languageToggleButton.isOn = false
        languageToggleButton.onTintColor = .wisteriaPurple
        languageToggleButton.tintColor = .wisteriaPurple
        languageToggleButton.thumbTintColor = .white
        languageToggleButton.backgroundColor = .wisteriaPurple
        languageToggleButton.layer.cornerRadius = 16
        languageToggleButton.addTarget(self, action: #selector(didTapLanguageToggleButton), for: .touchUpInside)
        bottomBarView.addSubview(languageToggleButton)

        // Set up the language toggle text
        languageToggleEnLabel.translatesAutoresizingMaskIntoConstraints = false
        languageToggleEnLabel.text = languageToggleEnText
        languageToggleEnLabel.textColor = .wisteriaPurple
        let languageToggleEnfontDescriptor = UIFont.systemFont(ofSize: languageToggleLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        languageToggleEnLabel.font = UIFont.init(descriptor: languageToggleEnfontDescriptor!, size: 0)
        bottomBarView.addSubview(languageToggleEnLabel)
        languageToggleZhLabel.translatesAutoresizingMaskIntoConstraints = false
        languageToggleZhLabel.text = languageToggleZhText
        languageToggleZhLabel.textColor = .wisteriaPurple
        languageToggleZhLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: languageToggleLabelFontSize)
        bottomBarView.addSubview(languageToggleZhLabel)

        // Sets up layout constrainsts.
        singleNewsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        singleNewsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        singleNewsView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        singleNewsView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor).isActive = true

        bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomBarView.heightAnchor.constraint(equalToConstant: bottomBarHeight).isActive = true

        likeButton.leadingAnchor.constraint(equalTo: bottomBarView.leadingAnchor, constant: likeHeartMargin).isActive = true
        likeButton.bottomAnchor.constraint(equalTo: bottomBarView.bottomAnchor, constant: -likeHeartMargin).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: likeHeartSideLength).isActive = true
        likeButton.widthAnchor.constraint(equalToConstant: likeHeartSideLength).isActive = true


        languageToggleZhLabel.trailingAnchor.constraint(equalTo: bottomBarView.trailingAnchor, constant: -CGFloat(23)).isActive = true
        languageToggleZhLabel.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor, constant: -CGFloat(2)).isActive = true

        languageToggleButton.trailingAnchor.constraint(equalTo: languageToggleZhLabel.leadingAnchor, constant: -CGFloat(3)).isActive = true
        languageToggleButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor).isActive = true

        languageToggleEnLabel.trailingAnchor.constraint(equalTo: languageToggleButton.leadingAnchor, constant: -CGFloat(3)).isActive = true
        languageToggleEnLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor).isActive = true
    }
    
    // MARK: - Private
    @objc
    func didTapLikeButton() {
        likeButton.isSelected = !likeButton.isSelected
    }

    @objc
    func didTapLanguageToggleButton() {
//        let aaa = languageToggleButton.isOn
        if languageToggleButton.isOn {
            singleNewsView.removeFromSuperview()
            singleEnNewsViewController.removeFromParent()
            singleEnNewsViewController.didMove(toParent: nil)
            addChild(singleZhNewsViewController)
            singleZhNewsViewController.didMove(toParent: self)
            singleNewsView = singleZhNewsViewController.view
            view.addSubview(singleNewsView)
        } else {
            singleNewsView.removeFromSuperview()
            singleZhNewsViewController.removeFromParent()
            singleZhNewsViewController.didMove(toParent: nil)
            addChild(singleEnNewsViewController)
            singleEnNewsViewController.didMove(toParent: self)
            singleNewsView = singleEnNewsViewController.view
            view.addSubview(singleNewsView)
        }
        singleNewsView.translatesAutoresizingMaskIntoConstraints = false
        singleNewsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        singleNewsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        singleNewsView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        singleNewsView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor).isActive = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
