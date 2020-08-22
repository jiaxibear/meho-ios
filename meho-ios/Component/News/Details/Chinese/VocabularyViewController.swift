//
//  VocabularyViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/20/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation

class VocabularyViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Constants
    let dimmingViewAlpha = CGFloat(CGFloat(99)/256)
    let contentViewCornerRadius = CGFloat(10)
    let contentViewRatio = CGFloat(0.3)
    let zhLabelFontSize = CGFloat(22)
    let pinyinLabelFontSize = CGFloat(20)
    let enLabelFontSize = CGFloat(20)


    let horizontalMarginToWidthRaitio = CGFloat(1.0/12.0)
    let labelTopMarginToHeightRaitio = CGFloat(1.0/5.0)

    private let saveUnfilledImageName = "purple_saved_unfilled"
    private let saveFilledImageName = "purple_saved_filled"
    private let pronounceButtonImageName = "stories_speaker"

    // MARK: - Properties
    let dimmingView = UIView.init(frame: .zero)
    let contentView = UIView.init(frame: .zero)
    let vocabularyZhLabel = UILabel.init(frame: .zero)
    let vocabularyPinyinLabel = UILabel.init(frame: .zero)
    let vocabularyEnLabel = UILabel.init(frame: .zero)
    let vocabularyOptionalLabel = UILabel.init(frame: .zero)
    let likeButton = UIButton.init(frame: .zero)
    let prounceButton = UIButton.init(frame: .zero)

    // MARK: - Data
    private var vocabulary: Vocabulary
    private var player: AVPlayer?

    // MARK: - Initializer
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(allDifficulties: [Difficulty], currentDifficulty: Difficulty)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(allDifficulties: [Difficulty], currentDifficulty: Difficulty)")
    }

    init(vocabulary: Vocabulary) {
        self.vocabulary = vocabulary
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupZhLabel()
        setupLikeButton()
        setupPinyinLabel()
        setupeEnLabel()
        setupeOptionalLabel()
        setupPronounceButton()
        // Do any additional setup after loading the view.
    }
    
    func setupBackground() {
        // Sets up background view.
        dimmingView.backgroundColor = UIColor.init(white: 0, alpha: dimmingViewAlpha)
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackgroundView))
        tapGestureRecognizer.delegate = self
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmingView)

        // Sets up content view.
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = contentViewCornerRadius
        contentView.backgroundColor = .white
        view.addSubview(contentView)

        // Sets up layout constraints
        dimmingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: view.bounds.height * contentViewRatio).isActive = true
    }

    func setupZhLabel() {
        vocabularyZhLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyZhLabel.text = vocabulary.content_zh
        vocabularyZhLabel.textColor = .darkGrayTwo
        vocabularyZhLabel.font = UIFont.init(name: "PingFangSC-Medium", size: zhLabelFontSize)
        vocabularyZhLabel.numberOfLines = 1
        vocabularyZhLabel.sizeToFit()
        contentView.addSubview(vocabularyZhLabel)

        let containerWidth = view.bounds.width
        let containerHeight = view.bounds.height * contentViewRatio
        vocabularyZhLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerWidth * horizontalMarginToWidthRaitio).isActive = true
        vocabularyZhLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: containerHeight * labelTopMarginToHeightRaitio).isActive = true
    }

    func setupLikeButton() {
        let newsLikeHeartUnfilledImage = UIImage.init(named: saveUnfilledImageName)
        let newsLikeHeartFilledImag = UIImage.init(named: saveFilledImageName)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setImage(newsLikeHeartUnfilledImage, for: UIControl.State.normal)
        likeButton.setImage(newsLikeHeartFilledImag, for: UIControl.State.selected)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        contentView.addSubview(likeButton)

        let containerWidth = view.bounds.width
        let containerHeight = view.bounds.height * contentViewRatio
        likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -containerWidth * horizontalMarginToWidthRaitio).isActive = true
        likeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: containerHeight * labelTopMarginToHeightRaitio).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: vocabularyZhLabel.bounds.height).isActive = true
        likeButton.widthAnchor.constraint(equalToConstant: vocabularyZhLabel.bounds.height).isActive = true
    }

    func setupPinyinLabel() {
        vocabularyPinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyPinyinLabel.text = "/" + vocabulary.content_pinyin + "/  "
        vocabularyPinyinLabel.textColor = .darkGrayTwo
        let pinyinfontDescriptor = UIFont.systemFont(ofSize: pinyinLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        vocabularyPinyinLabel.font = UIFont.init(descriptor: pinyinfontDescriptor!, size: 0)
        vocabularyPinyinLabel.numberOfLines = 1
        vocabularyPinyinLabel.sizeToFit()
        contentView.addSubview(vocabularyPinyinLabel)

        let containerWidth = view.bounds.width
        vocabularyPinyinLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerWidth * horizontalMarginToWidthRaitio).isActive = true
        vocabularyPinyinLabel.topAnchor.constraint(equalTo: vocabularyZhLabel.bottomAnchor, constant: CGFloat(18)).isActive = true
    }

    func setupeEnLabel() {
        vocabularyEnLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyEnLabel.text = vocabulary.content_en
        vocabularyEnLabel.textColor = .textBlueGray
        let enfontDescriptor = UIFont.systemFont(ofSize: enLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        vocabularyEnLabel.font = UIFont.init(descriptor: enfontDescriptor!, size: 0)
        vocabularyEnLabel.numberOfLines = 0
        vocabularyEnLabel.sizeToFit()
        contentView.addSubview(vocabularyEnLabel)

        let containerWidth = view.bounds.width
        vocabularyEnLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerWidth * horizontalMarginToWidthRaitio).isActive = true
        vocabularyEnLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -containerWidth * horizontalMarginToWidthRaitio).isActive = true
        vocabularyEnLabel.topAnchor.constraint(equalTo: vocabularyPinyinLabel.bottomAnchor, constant: CGFloat(13)).isActive = true
    }

    func setupeOptionalLabel() {
        vocabularyOptionalLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyOptionalLabel.text = vocabulary.content_optional
        vocabularyOptionalLabel.textColor = .textBlueGray
        let optionalfontDescriptor = UIFont.systemFont(ofSize: enLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        vocabularyEnLabel.font = UIFont.init(descriptor: optionalfontDescriptor!, size: 0)
        vocabularyOptionalLabel.numberOfLines = 0
        vocabularyOptionalLabel.sizeToFit()
        contentView.addSubview(vocabularyOptionalLabel)

        let containerWidth = view.bounds.width
        vocabularyOptionalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerWidth * horizontalMarginToWidthRaitio).isActive = true
        vocabularyOptionalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -containerWidth * horizontalMarginToWidthRaitio).isActive = true
        vocabularyOptionalLabel.topAnchor.constraint(equalTo: vocabularyEnLabel.bottomAnchor, constant: CGFloat(10)).isActive = true
    }

    func setupPronounceButton() {
        let pronounceSpeakerImage = UIImage.init(named: pronounceButtonImageName)
        prounceButton.translatesAutoresizingMaskIntoConstraints = false
        prounceButton.setImage(pronounceSpeakerImage, for: UIControl.State.normal)
        prounceButton.setImage(pronounceSpeakerImage, for: UIControl.State.selected)
        prounceButton.addTarget(self, action: #selector(didTapPronounceButton), for: .touchUpInside)
        contentView.addSubview(prounceButton)

        prounceButton.leadingAnchor.constraint(equalTo: vocabularyPinyinLabel.trailingAnchor).isActive = true
        prounceButton.centerYAnchor.constraint(equalTo: vocabularyPinyinLabel.centerYAnchor).isActive = true
        prounceButton.widthAnchor.constraint(equalToConstant: vocabularyPinyinLabel.bounds.height).isActive = true
        prounceButton.heightAnchor.constraint(equalToConstant: vocabularyPinyinLabel.bounds.height).isActive = true

        if vocabulary.audioURL != nil || (vocabulary.audio_bucket != nil && vocabulary.audio_key != nil) {
            prounceButton.isHidden = false
        } else {
            prounceButton.isHidden = true
        }
    }

    // MARK: - Private
    @objc func didTapBackgroundView() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc
    func didTapLikeButton() {
        likeButton.isSelected = !likeButton.isSelected
    }

    @objc func didTapPronounceButton() {
        if let pronounceURL = vocabulary.audioURL {
            let playerItem = AVPlayerItem.init(url: pronounceURL)
            player = AVPlayer.init(playerItem: playerItem)
            player?.rate = AudioPlaySpeed.normal.rawValue
            player?.play()
        }
        if let audioKey = vocabulary.audio_key, let audioBucket = vocabulary.audio_bucket {
            let hackedUrlString = ("https://" + audioBucket + ".s3-us-west-2.amazonaws.com/public/" + audioKey).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let someURLComponent = URLComponents.init(string: hackedUrlString!) {
                if let fetchNewsDetailURL = someURLComponent.url {
                    let playerItem = AVPlayerItem.init(url: fetchNewsDetailURL)
                    player = AVPlayer.init(playerItem: playerItem)
                    player?.rate = AudioPlaySpeed.normal.rawValue
                    player?.play()
                }
            }
        }
    }
}
