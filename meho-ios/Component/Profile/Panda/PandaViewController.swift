//
//  PandaViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 5/13/22.
//  Copyright © 2022 Meho. All rights reserved.
//

import UIKit

class PandaViewController: UIViewController {

    private let bambooButtonWidth = CGFloat(90)
    private let bambooButtonHeight = CGFloat(36)
    private let bambooButtonTitleFontSize = CGFloat(18)
    private let bambooButtonCornerRadius = CGFloat(8)
    private let contentLeadingTrailingMargin = CGFloat(32)
    private let bambooButtonTopMargin = CGFloat(26)
    private let contentViewTopMargin = CGFloat(26)
    private let pandaCircleViewTopMargin = CGFloat(70)
    private let pandaCircleViewHeight = CGFloat(492)
    private let titleLabelFontSize = CGFloat(20)
    private let titleLabelLeadingTrailingMargin = CGFloat(40)
    private let titleLabelTopMargin = CGFloat(40)

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
        pandaImageView.loadGifFromLocal(name: "Meho Panda Hi")
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
        titleLabel.text = "Practice on Meho\nand get bamboos to feed me plz!"
        titleLabel.textAlignment = .center
        return titleLabel
    } ()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(bambooButton)
        view.addSubview(contentView)
        contentView.addSubview(pandaCircleView)
        contentView.addSubview(titleLabel)
        pandaCircleView.addSubview(pandaImageView)
        view.backgroundColor = .white
        NSLayoutConstraint.activate([
            bambooButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: bambooButtonTopMargin),
            bambooButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentLeadingTrailingMargin),
            bambooButton.widthAnchor.constraint(equalToConstant: bambooButtonWidth),
            bambooButton.heightAnchor.constraint(equalToConstant: bambooButtonHeight),

            contentView.topAnchor.constraint(equalTo: bambooButton.bottomAnchor, constant: contentViewTopMargin),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -20),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            pandaCircleView.heightAnchor.constraint(equalToConstant: pandaCircleViewHeight),
            pandaCircleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pandaCircleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pandaCircleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: pandaCircleViewTopMargin),

            pandaImageView.leadingAnchor.constraint(equalTo: pandaCircleView.leadingAnchor),
            pandaImageView.trailingAnchor.constraint(equalTo: pandaCircleView.trailingAnchor),
            pandaImageView.bottomAnchor.constraint(equalTo: pandaCircleView.bottomAnchor),
            pandaImageView.widthAnchor.constraint(equalTo: pandaImageView.heightAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: titleLabelLeadingTrailingMargin),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -titleLabelLeadingTrailingMargin),
            titleLabel.topAnchor.constraint(equalTo: pandaCircleView.bottomAnchor, constant: titleLabelTopMargin),
        ])
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
}
