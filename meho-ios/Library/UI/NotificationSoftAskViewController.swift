//
//  NotificationSoftAskViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 7/11/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

enum NotificationSoftAskType: Int {
    case stories
    case talks
    case trendingPhrases
}

class NotificationSoftAskViewController: UIViewController {

    // MARK: - Constants
    private let logoImageViewWidth = CGFloat(20)
    private let logoImageViewHeight = CGFloat(20)
    private let titleLabelFontSize = CGFloat(13)
    private let contentLabelFontSize = CGFloat(15)
    private let contentImageViewWidth = CGFloat(240)
    private let contentImageViewHeight = CGFloat(200)
    private let contentImageViewTopMagrin = CGFloat(10)
    private let contentLabelTopMagrin = CGFloat(24)
    private let contentWidth = CGFloat(320)
    private let preferredContentWidth = CGFloat(360)
    private let preferredContentHeight = CGFloat(444)
    private let cornerRadius = CGFloat(12)
    private let contentStackViewTopMargin = CGFloat(18)
    private let buttonFontSize = CGFloat(20)
    private let buttonHeight = CGFloat(60)
    private let buttonLineHeight = CGFloat(1)

    // MARK: - Properties
    private lazy var logoImageView: UIImageView = {
        let logoImage = UIImage.init(named: "AppIcon")
        let logoImageView = UIImageView.init(image: logoImage)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: titleLabelFontSize)
        titleLabel.textColor = .textBlueGray
        titleLabel.text = NSLocalizedString("MehoTitle", comment: "")
        return titleLabel
    } ()

    private lazy var titleStackView: UIStackView = {
        let titleStackView = UIStackView.init(arrangedSubviews: [logoImageView, titleLabel])
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        return titleStackView
    } ()

    private lazy var contentImageView: UIImageView = {
        var image: UIImage?
        switch type {
        case .stories:
            image = UIImage.init(named: "login_preview_stories")
        case .talks:
            image = UIImage.init(named: "login_preview_talk")
        case .trendingPhrases:
            image = UIImage.init(named: "login_preview_expressions")
        }
        let contentImageView = UIImageView.init(image: image)
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        return contentImageView
    } ()

    private lazy var contentLabel: UILabel = {
        var content: String?
        switch type {
        case .stories:
            content = NSLocalizedString("StoriesNotificationSoftAsk", comment: "")
        case .talks:
            content = NSLocalizedString("TalksNotificationSoftAsk", comment: "")
        case .trendingPhrases:
            content = NSLocalizedString("TrendingPhrasesNotificationSoftAsk", comment: "")
        }
        let contentLabel = UILabel.init(frame: .zero)
        contentLabel.text = content
        contentLabel.textColor = .textCharcoalGrey
        contentLabel.font = UIFont.systemFont(ofSize: contentLabelFontSize)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.numberOfLines = 0
        return contentLabel
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [titleStackView, contentImageView, contentLabel])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.setCustomSpacing(contentImageViewTopMagrin, after: titleStackView)
        contentStackView.setCustomSpacing(contentLabelTopMagrin, after: contentImageView)
        return contentStackView
    } ()

    private lazy var yesButton: UIButton = {
        let yesButton = UIButton.init(frame: .zero)
        yesButton.translatesAutoresizingMaskIntoConstraints = false
        yesButton.setTitle(NSLocalizedString("YesButtonTitle", comment: ""), for: .normal)
        yesButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize)
        yesButton.setTitleColor(.darkGrayTwo, for: .normal)
        yesButton.backgroundColor = .paleGray.withAlphaComponent(0.6)
        yesButton.addTarget(self, action: #selector(didTapYesButton), for: .touchUpInside)
        return yesButton
    } ()

    private lazy var noButton: UIButton = {
        let noButton = UIButton.init(frame: .zero)
        noButton.translatesAutoresizingMaskIntoConstraints = false
        noButton.setTitle(NSLocalizedString("NoButtonTitle", comment: ""), for: .normal)
        noButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize)
        noButton.setTitleColor(.darkGrayTwo, for: .normal)
        noButton.backgroundColor = .paleGray.withAlphaComponent(0.6)
        noButton.addTarget(self, action: #selector(didTapNoButton), for: .touchUpInside)
        return noButton
    } ()

    private lazy var buttonLineView: UIView = {
        let buttonLineView = UIView.init(frame: .zero)
        buttonLineView.translatesAutoresizingMaskIntoConstraints = false
        buttonLineView.backgroundColor = .textBlueGray.withAlphaComponent(0.5)
        return buttonLineView
    } ()

    private lazy var buttonsStackView: UIStackView = {
        let buttonsStackView = UIStackView.init(arrangedSubviews: [yesButton, buttonLineView, noButton])
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .vertical
        buttonsStackView.alignment = .fill
        return buttonsStackView
    } ()

    private let type: NotificationSoftAskType

    // MARK: - Initializers
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(type: NotificationSoftAskType)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(type: NotificationSoftAskType)")
    }

    init(type: NotificationSoftAskType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        preferredContentSize = CGSize.init(width: preferredContentWidth, height: preferredContentHeight)
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = false
        view.backgroundColor = .white
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(contentStackView)
        view.addSubview(buttonsStackView)

        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: logoImageViewWidth),
            logoImageView.heightAnchor.constraint(equalToConstant: logoImageViewHeight),

            titleStackView.widthAnchor.constraint(equalToConstant: contentWidth),

            contentImageView.widthAnchor.constraint(equalToConstant: contentImageViewWidth),
            contentImageView.heightAnchor.constraint(equalToConstant: contentImageViewHeight),

            contentLabel.widthAnchor.constraint(equalToConstant: contentWidth),

            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: contentStackViewTopMargin),

            yesButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            noButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            buttonLineView.heightAnchor.constraint(equalToConstant: buttonLineHeight),

            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc
    private func didTapYesButton() {
        NotificationManager.recordUserEnablementState(enabled: true, type: type)
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc
    private func didTapNoButton() {
        NotificationManager.recordUserEnablementState(enabled: false, type: type)
        dismiss(animated: true, completion: nil)
    }
}
