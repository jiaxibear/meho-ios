//
//  PandaViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 5/13/22.
//  Copyright © 2022 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

class PandaViewController: UIViewController {

    private let bambooButtonWidth = CGFloat(90)
    private let bambooButtonHeight = CGFloat(36)
    private let bambooButtonTitleFontSize = CGFloat(18)
    private let bambooButtonCornerRadius = CGFloat(8)
    private let contentLeadingTrailingMargin = CGFloat(32)
    private let bambooButtonTopMargin = CGFloat(20)
    private let contentViewTopMargin = CGFloat(26)
    private let pandaCircleViewTopMargin = CGFloat(70)
    private let pandaCircleViewHeight = CGFloat(492)
    private let titleLabelFontSize = CGFloat(20)
    private let titleLabelLeadingTrailingMargin = CGFloat(40)
    private let titleLabelTopMargin = CGFloat(40)
    private let pandaImageViewHeight = CGFloat(350)
    private let plusButtonSize = CGFloat(24)
    private let plusButtonBorderWidth = CGFloat(1)
    private let editNameButtonWidth = CGFloat(36)
    private let editNameButtonHeight = CGFloat(36)
    private let editNameButtonLeadingMargin = CGFloat(24)
    private let pandaNameLabelLeadingMargin = CGFloat(12)
    private let pandaNameLabelFontSize = CGFloat(18)

    private lazy var editNameButton: UIButton = {
        let editNameButton = UIButton.init(frame: .zero)
        editNameButton.translatesAutoresizingMaskIntoConstraints = false
        editNameButton.backgroundColor = .skyBlue
        let editNameButtonImage = UIImage.init(named: "profile_edit_penceil")?.withTintColor(.white)
        editNameButton.setImage(editNameButtonImage, for: .normal)
        editNameButton.tintColor = .white
        editNameButton.layer.cornerRadius = editNameButtonWidth / 2
        editNameButton.layer.masksToBounds = true
        return editNameButton
    } ()

    private lazy var pandaNameLabel: UILabel = {
        let pandaNameLabel = UILabel.init(frame: .zero)
        pandaNameLabel.translatesAutoresizingMaskIntoConstraints = false
        pandaNameLabel.text = NSLocalizedString("NameYourPandaText", comment: "")
        pandaNameLabel.textColor = .darkGrayTwo
        var pandaNameLabelFont = UIFont.systemFont(ofSize: pandaNameLabelFontSize, weight: .regular)
        if let pandaNameLabelFontDescriptor = pandaNameLabelFont.fontDescriptor.withDesign(.rounded) {
            pandaNameLabelFont = UIFont.init(descriptor: pandaNameLabelFontDescriptor, size: pandaNameLabelFontSize)
        }
        return pandaNameLabel
    } ()

    private lazy var bambooButton: UIButton = {
        let bambooButton = UIButton.init(frame: .zero)
        bambooButton.translatesAutoresizingMaskIntoConstraints = false
        bambooButton.setTitleColor(.white, for: .normal)
        bambooButton.setTitle("7 🎋", for: .normal)
        var bambooButtonFont = UIFont.systemFont(ofSize: bambooButtonTitleFontSize, weight: .medium)
        if let bambooButtonFontDescriptor = bambooButtonFont.fontDescriptor.withDesign(.rounded) {
            bambooButtonFont = UIFont.init(descriptor: bambooButtonFontDescriptor, size: bambooButtonTitleFontSize)
        }
        bambooButton.titleLabel?.font = bambooButtonFont
        bambooButton.backgroundColor = UIColor.skyBlue.withAlphaComponent(0.8)
        bambooButton.layer.masksToBounds = true
        bambooButton.layer.cornerRadius = bambooButtonCornerRadius
        return bambooButton
    } ()

    private lazy var contentView: UIView = {
        let contentView = UIView.init(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.skyBlue.withAlphaComponent(0.1)
        return contentView
    } ()

    private lazy var pandaCircleView: UIView = {
        let pandaCircleView = UIView.init(frame: .zero)
        pandaCircleView.translatesAutoresizingMaskIntoConstraints = false
        pandaCircleView.layer.masksToBounds = true
        pandaCircleView.layer.cornerRadius = view.bounds.width / 2
        pandaCircleView.backgroundColor = .white
        return pandaCircleView
    } ()

    private lazy var pandaImageView: UIImageView = {
        let pandaImageView = UIImageView.init(frame: .zero)
        pandaImageView.translatesAutoresizingMaskIntoConstraints = false
        return pandaImageView
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .mehoDarkGray
        var titleLabelFont = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .regular)
        if let titleLabelFontDescriptor = titleLabelFont.fontDescriptor.withDesign(.rounded) {
            titleLabelFont = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelFontSize)
        }
        titleLabel.textAlignment = .center
        return titleLabel
    } ()

    private lazy var hasSeenPandaKey: String? = {
        guard let userID = AWSMobileClient.default().userSub else {
            return nil
        }
        return String.init(format: "hasSeenPandaKey-%@", userID)
    } ()

    private lazy var plusButton: UIButton = {
        let plusButton = UIButton.init(frame: .zero)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.layer.cornerRadius = plusButtonSize / 2
        plusButton.layer.borderColor = UIColor.paleLilac.cgColor
        plusButton.layer.borderWidth = plusButtonBorderWidth
        plusButton.layer.masksToBounds = true
        let plusImage = UIImage.init(systemName: "plus")
        plusButton.tintColor = .skyBlue
        plusButton.setImage(plusImage, for: .normal)
        plusButton.backgroundColor = .white
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        return plusButton
    } ()

    private var numberOfBamboos = -9

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(contentView)
        contentView.addSubview(bambooButton)
        contentView.addSubview(pandaNameLabel)
        contentView.addSubview(plusButton)
        contentView.addSubview(editNameButton)
        contentView.addSubview(pandaCircleView)
        contentView.addSubview(titleLabel)
        pandaCircleView.addSubview(pandaImageView)
        view.backgroundColor = .white
        NSLayoutConstraint.activate([
            editNameButton.widthAnchor.constraint(equalToConstant: editNameButtonWidth),
            editNameButton.heightAnchor.constraint(equalToConstant: editNameButtonHeight),
            editNameButton.topAnchor.constraint(equalTo: bambooButton.topAnchor),
            editNameButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: editNameButtonLeadingMargin),

            bambooButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: bambooButtonTopMargin),
            bambooButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentLeadingTrailingMargin),
            bambooButton.widthAnchor.constraint(equalToConstant: bambooButtonWidth),
            bambooButton.heightAnchor.constraint(equalToConstant: bambooButtonHeight),

            plusButton.widthAnchor.constraint(equalToConstant: plusButtonSize),
            plusButton.heightAnchor.constraint(equalToConstant: plusButtonSize),
            plusButton.centerXAnchor.constraint(equalTo: bambooButton.trailingAnchor),
            plusButton.centerYAnchor.constraint(equalTo: bambooButton.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -20),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            pandaCircleView.heightAnchor.constraint(equalToConstant: pandaCircleViewHeight),
            pandaCircleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pandaCircleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pandaCircleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: pandaCircleViewTopMargin),

            pandaImageView.centerXAnchor.constraint(equalTo: pandaCircleView.centerXAnchor),
            pandaImageView.bottomAnchor.constraint(equalTo: pandaCircleView.bottomAnchor),
            pandaImageView.heightAnchor.constraint(equalToConstant: pandaImageViewHeight),
            pandaImageView.widthAnchor.constraint(equalTo: pandaImageView.heightAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: titleLabelLeadingTrailingMargin),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -titleLabelLeadingTrailingMargin),
            titleLabel.topAnchor.constraint(equalTo: pandaCircleView.bottomAnchor, constant: titleLabelTopMargin),

            pandaNameLabel.centerYAnchor.constraint(equalTo: editNameButton.centerYAnchor),
            pandaNameLabel.leadingAnchor.constraint(equalTo: editNameButton.trailingAnchor, constant: pandaNameLabelLeadingMargin),
        ])

        updatePandaImageViewAndText()
        guard let hasSeenPandaKey = hasSeenPandaKey else {
            return
        }

        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: hasSeenPandaKey)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        let newsAudioPlayer = NewsAudioPlayer.shared
        if newsAudioPlayer.status != .notStarted, let newsPlayingNowView = newsAudioPlayer.newsPlayingNowView {
            displayNewsPlayingNowView(newsPlayingNowView)
        }
    }

    // MARK: - NewsPlayingNow
    func displayNewsPlayingNowView(_ newsPlayingNowView: NewsPlayingNowView) {
        if newsPlayingNowView.superview != nil {
            newsPlayingNowView.removeFromSuperview()
        }

        view.addSubview(newsPlayingNowView)
        NSLayoutConstraint.activate([
            newsPlayingNowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsPlayingNowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsPlayingNowView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - Private
    func updatePandaImageViewAndText() {
        guard let hasSeenPandaKey = hasSeenPandaKey else {
            return
        }

        var pandaImageName = "Meho Panda Hi"
        var text = "Practice on Meho\nand get bamboos to feed me plz!"
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: hasSeenPandaKey) {
            if numberOfBamboos > 0 {
                pandaImageName = "Panda Playing Skating V2"
                text = "Having Fun now!\nThanks for keeping learning and feeding me with the yummy bamboo!"
            } else if numberOfBamboos <= 0 && numberOfBamboos >= -5 {
                pandaImageName = "Panda Hungry V2"
                text = "I am so hungry…\nPlease keep learning and getting some bamboo for me… "
            } else {
                pandaImageName = "Panda Sleeping"
                text = "Nothing to eat for so long…\nPlease keep learning and getting some bamboo for me… "
            }
        }
        pandaImageView.loadGifFromLocal(name: pandaImageName)
        titleLabel.text = text
    }

    @objc
    func didTapPlusButton() {
        let earnBambooViewController = EarnBambooViewController.init(nibName: nil, bundle: nil)
        let dialogViewController = DialogViewController.init(contentViewController: earnBambooViewController)
        dialogViewController.modalPresentationStyle = .overFullScreen
        dialogViewController.modalTransitionStyle = .crossDissolve
        present(dialogViewController, animated: true, completion: nil)
    }
}
