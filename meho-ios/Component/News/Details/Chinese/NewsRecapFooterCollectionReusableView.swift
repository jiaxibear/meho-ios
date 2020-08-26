//
//  NewsRecapFooterCollectionReusableView.swift
//  meho-ios
//  Holds logic for showing the taking quiz / mark as complete button
//
//  Created by Jiaxi Xiong on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

protocol NewsRecapFooterCollectionReusableViewDelegate : AnyObject {
    func NewsRecapFooterCollectionReusableViewDidTapMarkComplete()
}

class NewsRecapFooterCollectionReusableView: UICollectionReusableView {
    // MARK: - Constants
    private let buttonHeight = CGFloat(50)
    private let buttonInset = CGFloat(20)
    private let bottomMargin = CGFloat(50)
    private let buttonLabelFontSize = CGFloat(21)
    private let buttonCornerRadius = CGFloat(25.5)

    private let quizButtonTitle = "Would you like to take a quiz?"
    private let markCompleteButtonTitle = "Mark as complete"


    // MARK: - Properties
    private let quizButton = UIButton.init(frame: .zero)
    private let markCompleteButton = UIButton.init(frame: .zero)
    private static var sizingView = NewsRecapFooterCollectionReusableView.init(frame: .zero)
    private weak var delegate: NewsRecapFooterCollectionReusableViewDelegate?

    // MARK: - Init
    @available(*, unavailable)
        init() {
        fatalError("Use init(frame: CGRect)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

//        setupQuizButton()
        setupMarkCompleteButton()
    }

    func setupQuizButton() {
        quizButton.translatesAutoresizingMaskIntoConstraints = false
        quizButton.backgroundColor = .wisteriaPurple
        let fontDescriptor = UIFont.systemFont(ofSize: buttonLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        quizButton.titleLabel?.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        quizButton.titleLabel?.textColor = .white
        quizButton.layer.cornerRadius = buttonCornerRadius
        quizButton.setTitle(quizButtonTitle, for: .normal)
        addSubview(quizButton)

        quizButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        quizButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        quizButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        quizButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    }

    func setupMarkCompleteButton() {
        markCompleteButton.translatesAutoresizingMaskIntoConstraints = false
        markCompleteButton.backgroundColor = .skyBlue
        let fontDescriptor = UIFont.systemFont(ofSize: buttonLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        markCompleteButton.titleLabel?.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        markCompleteButton.titleLabel?.textColor = .white
        markCompleteButton.layer.cornerRadius = buttonCornerRadius
        markCompleteButton.setTitle(markCompleteButtonTitle, for: .normal)
        markCompleteButton.addTarget(self, action: #selector(didTapMarkCompleteButton), for: .touchUpInside)
        addSubview(markCompleteButton)

        // change to the following line when resuming quiz function
//        markCompleteButton.topAnchor.constraint(equalTo: quizButton.bottomAnchor, constant: buttonInset).isActive = true
        markCompleteButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        markCompleteButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        markCompleteButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        markCompleteButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    }

    // MARK: - Public
    func setDelegate(delegate: NewsRecapFooterCollectionReusableViewDelegate) {
        self.delegate = delegate
    }

    public func setCompleted() {
        self.markCompleteButton.isHidden = true
    }

    public class func cellHeight(with width: CGFloat) -> CGFloat {
        // when resuming quiz option, exchange with this
//        return 2*sizingView.buttonHeight + sizingView.buttonInset + sizingView.bottomMargin
        return sizingView.buttonHeight + sizingView.buttonInset

    }

    @objc
    func didTapMarkCompleteButton() {
        delegate?.NewsRecapFooterCollectionReusableViewDidTapMarkComplete()
        self.markCompleteButton.isHidden = true
    }

}
