//
//  VocabularyViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/20/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class VocabularyViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Constants
    let dimmingViewAlpha = CGFloat(CGFloat(99)/256)
    let contentViewCornerRadius = CGFloat(10)
    let contentViewRatio = CGFloat(0.25)
    let zhLabelFontSize = CGFloat(22)

    // MARK: - Properties
    let dimmingView = UIView.init(frame: .zero)
    let contentView = UIView.init(frame: .zero)
    let vocabularyZhLabel = UILabel.init(frame: .zero)
//    let vocabularyPinyinLabel = UILabel.init(frame: .zero)
//    let vocabularyEnLabel = UILabel.init(frame: .zero)
//    let likeButton = UIButton.init(frame: .zero)
//    let prounceButton = UIButton.init(frame: .zero)

    // MARK: - Data
    private var vocabulary: Vocabulary

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
        vocabularyZhLabel.textColor = .black
        vocabularyZhLabel.font = UIFont.init(name: "PingFangSC-Medium", size: zhLabelFontSize)
        vocabularyZhLabel.numberOfLines = 1
        vocabularyZhLabel.sizeToFit()
        contentView.addSubview(vocabularyZhLabel)

        let containerWidth = view.bounds.width
        let containerHeight = view.bounds.height * contentViewRatio
        vocabularyZhLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerWidth/12).isActive = true
        vocabularyZhLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -containerWidth/7).isActive = true
        vocabularyZhLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: containerHeight/5).isActive = true
        vocabularyZhLabel.heightAnchor.constraint(equalToConstant: CGFloat(21)).isActive = true
    }

    // MARK: - Private
    @objc func didTapBackgroundView() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
