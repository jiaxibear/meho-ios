//
//  DialogModeSelectionViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 6/21/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import AWSMobileClient

protocol DialogModeSelectionViewControllerDelegate: AnyObject {
    func dialogModeSelectionViewControllerDidTapSoloPracticeButton(dialog: Dialog)
    func dialogModeSelectionViewControllerDidTapDuoRolePlayButton(dialog: Dialog)
    func dialogModeSelectionViewControllerDidTapSaveButton(isSaved: Bool)
}

class DialogModeSelectionViewController: UIViewController, MehoAnalytics {

    // MARK: - Constants
    // MARK: Shared
    private let hasSeenDialogModeSelectionKey = "hasSeenDialogModeSelectionKey"
    private let difficultyLabelCornerRadius = CGFloat(2)
    private let difficultyLabelWidth = CGFloat(66)
    private let difficultyLabelHeight = CGFloat(20)
    private let difficultyLabelTopMargin = CGFloat(16)
    private let difficultyLabelFontSize = CGFloat(10)
    private let titleLabelFontSize = CGFloat(20)
    private let titleLabelTopMargin = CGFloat(24)
    private let titleInLocalLanguageLabelFontSize = CGFloat(16)
    private let titleInLocalLanguageLabelTopMargin = CGFloat(12)
    private let introductionLabelFontSize = CGFloat(16)
    private let introductionLabelTopMargin = CGFloat(20)
    private let viewWidth: CGFloat = {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth * 0.8
    } ()
    private lazy var buttonFontSize: CGFloat = {
        if self.isFirstTime {
            return 16;
        } else {
            return 14;
        }
    } ()
    private let saveButtonWidth = CGFloat(30)
    private let saveButtonHeight = CGFloat(30)
    private let saveButtonTrailingMargin = CGFloat(16)

    // MARK: Not First Time
    private let contentStackViewLeadingTrailingMargin = CGFloat(16)
    private let contentStackViewBackgroundColorAlpha = CGFloat(0.1)
    private let buttonsStackViewTopMargin = CGFloat(44)
    private let buttonsStackViewBottomMargin = CGFloat(40)
    private let buttonsStackViewHeight = CGFloat(36)
    private let buttonsStackViewSpacing = CGFloat(20)
    private let buttonCornerRadius = CGFloat(8)
    // MARK: First Time
    private let bulletPointsStackViewLeadingTrailingMargin = CGFloat(40)
    private let bulletPointsStackViewTopMargin = CGFloat(24)
    private let bulletPointsStackViewBottomMargin = CGFloat(30)
    private let bulletPointViewSpacing = CGFloat(10)
    private let soloPracticeButtonTopMargin = CGFloat(24)
    private let soloPracticeButtonLeadingTrailingMargin = CGFloat(64)
    private let buttonHeight = CGFloat(40)
    private let introductionLabelBottomMargin = CGFloat(24)

    // MARK: - Property
    // MARK: Data Models
    private let userDataFetcher = UserDataFetcher.shared
    let dialog: Dialog
    // TODO: Change the value based on NSUserDefaults
    let isFirstTime: Bool
    var isSaved: Bool?

    // MARK: UI
    private lazy var difficultyLabel: UILabel = {
        let difficultyLabel = UILabel.init(frame: .zero)
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        difficultyLabel.clipsToBounds = true
        difficultyLabel.layer.cornerRadius = difficultyLabelCornerRadius
        difficultyLabel.textColor = .white
        difficultyLabel.textAlignment = .center
        let difficultyLabelFontDescriptor = UIFont.systemFont(ofSize: difficultyLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        difficultyLabel.font = UIFont.init(descriptor: difficultyLabelFontDescriptor!, size: difficultyLabelFontSize)
        difficultyLabel.text = dialog.difficulty.title.uppercased()
        switch dialog.difficulty.identifier {
        case .advanced:
            difficultyLabel.backgroundColor = .skyBlue
            break
        case .intermediate:
            difficultyLabel.backgroundColor = .periwinkle
            break
        case .beginner:
            difficultyLabel.backgroundColor = .wisteriaPurple
            break
        }
        return difficultyLabel
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        titleLabel.font = UIFont.init(name: "PingFangSC-Medium", size: titleLabelFontSize)
        titleLabel.text = dialog.title
        titleLabel.numberOfLines = 0
        return titleLabel
    } ()

    private lazy var titleInLocalLanguageLabel: UILabel = {
        let titleInLocalLanguageLabel = UILabel.init(frame: .zero)
        titleInLocalLanguageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInLocalLanguageLabel.textColor = .textBlueGray
        let titleInLocalLanguageLabelFontDescriptor = UIFont.systemFont(ofSize: titleInLocalLanguageLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleInLocalLanguageLabel.font = UIFont.init(descriptor: titleInLocalLanguageLabelFontDescriptor!, size: titleLabelFontSize)
        titleInLocalLanguageLabel.text = dialog.titleInLocalLanguage
        titleInLocalLanguageLabel.numberOfLines = 0
        return titleInLocalLanguageLabel
    } ()

    private lazy var introductionLabel: UILabel = {
        let introductionLabel = UILabel.init(frame: .zero)
        introductionLabel.translatesAutoresizingMaskIntoConstraints = false
        introductionLabel.textColor = .darkGrayTwo
        introductionLabel.font = UIFont.systemFont(ofSize: introductionLabelFontSize)
        introductionLabel.text = dialog.whyYouShouldLearn
        introductionLabel.numberOfLines = 0
        // TODO: Use real text.
        return introductionLabel
    } ()

    private lazy var contentStackViewBackgroundView: UIView = {
        let contentStackViewBackgroundView = UIView.init(frame: .zero)
        contentStackViewBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentStackViewBackgroundView.backgroundColor = UIColor.skyBlue.withAlphaComponent(contentStackViewBackgroundColorAlpha)
        return contentStackViewBackgroundView
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [difficultyLabel, titleLabel, titleInLocalLanguageLabel, introductionLabel])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.alignment = .leading
        contentStackView.setCustomSpacing(titleLabelTopMargin, after: difficultyLabel)
        contentStackView.setCustomSpacing(titleInLocalLanguageLabelTopMargin, after: titleLabel)
        contentStackView.setCustomSpacing(introductionLabelTopMargin, after: titleInLocalLanguageLabel)
        return contentStackView
    } ()

    private lazy var soloPracticeButton: UIButton = {
        let soloPracticeButton = UIButton.init(frame: .zero)
        soloPracticeButton.translatesAutoresizingMaskIntoConstraints = false
        soloPracticeButton.setTitleColor(.white, for: .normal)
        soloPracticeButton.setTitle(NSLocalizedString("soloPracticeButtonTitle", comment: ""), for: .normal)
        soloPracticeButton.backgroundColor = .wisteriaPurple
        soloPracticeButton.clipsToBounds = true
        soloPracticeButton.layer.cornerRadius = buttonCornerRadius
        let soloPracticeButtonFontDescriptor = UIFont.systemFont(ofSize: buttonFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        soloPracticeButton.titleLabel?.font = UIFont.init(descriptor: soloPracticeButtonFontDescriptor!, size: buttonFontSize)
        soloPracticeButton.addTarget(self, action: #selector(didTapSoloPracticeButton), for: .touchUpInside)
        return soloPracticeButton
    } ()

    private lazy var duoRolePlayButton: UIButton = {
        let duoRolePlayButton = UIButton.init(frame: .zero)
        duoRolePlayButton.translatesAutoresizingMaskIntoConstraints = false
        duoRolePlayButton.setTitleColor(.white, for: .normal)
        duoRolePlayButton.setTitle(NSLocalizedString("duoRolePlayButtonTitle", comment: ""), for: .normal)
        duoRolePlayButton.backgroundColor = .skyBlue
        duoRolePlayButton.clipsToBounds = true
        duoRolePlayButton.layer.cornerRadius = buttonCornerRadius
        let duoRolePlayButtonFontDescriptor = UIFont.systemFont(ofSize: buttonFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        duoRolePlayButton.titleLabel?.font = UIFont.init(descriptor: duoRolePlayButtonFontDescriptor!, size: buttonFontSize)
        duoRolePlayButton.addTarget(self, action: #selector(didTapDuoRolePlayButton), for: .touchUpInside)
        return duoRolePlayButton
    } ()

    private lazy var buttonsStackView: UIStackView = {
        let buttonsStackView = UIStackView.init(arrangedSubviews: [soloPracticeButton, duoRolePlayButton])
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = buttonsStackViewSpacing
        buttonsStackView.distribution = .fillEqually
        return buttonsStackView
    } ()

    private lazy var firstSoloBulletPointView: BulletPointView = {
        let firstSoloBulletPointView = BulletPointView.init(frame: .zero)
        firstSoloBulletPointView.translatesAutoresizingMaskIntoConstraints = false
        firstSoloBulletPointView.bulletColor = .wisteriaPurple
        firstSoloBulletPointView.pointText = NSLocalizedString("soloBulletPoint1", comment: "")
        return firstSoloBulletPointView
    } ()

    private lazy var secondSoloBulletPointView: BulletPointView = {
        let secondSoloBulletPointView = BulletPointView.init(frame: .zero)
        secondSoloBulletPointView.translatesAutoresizingMaskIntoConstraints = false
        secondSoloBulletPointView.bulletColor = .wisteriaPurple
        secondSoloBulletPointView.pointText = NSLocalizedString("soloBulletPoint2", comment: "")
        return secondSoloBulletPointView
    } ()

    private lazy var thirdSoloBulletPointView: BulletPointView = {
        let thirdSoloBulletPointView = BulletPointView.init(frame: .zero)
        thirdSoloBulletPointView.translatesAutoresizingMaskIntoConstraints = false
        thirdSoloBulletPointView.bulletColor = .wisteriaPurple
        thirdSoloBulletPointView.pointText = NSLocalizedString("soloBulletPoint3", comment: "")
        return thirdSoloBulletPointView
    } ()

    private lazy var soloBulletPointsStackView: UIStackView = {
        let soloBulletPointsStackView = UIStackView.init(arrangedSubviews: [firstSoloBulletPointView, secondSoloBulletPointView, thirdSoloBulletPointView])
        soloBulletPointsStackView.translatesAutoresizingMaskIntoConstraints = false
        soloBulletPointsStackView.axis = .vertical
        soloBulletPointsStackView.distribution = .equalSpacing
        soloBulletPointsStackView.spacing = bulletPointViewSpacing
        return soloBulletPointsStackView
    } ()

    private lazy var firstDuoBulletPointView: BulletPointView = {
        let firstDuoBulletPointView = BulletPointView.init(frame: .zero)
        firstDuoBulletPointView.translatesAutoresizingMaskIntoConstraints = false
        firstDuoBulletPointView.bulletColor = .skyBlue
        firstDuoBulletPointView.pointText = NSLocalizedString("duoBulletPoint1", comment: "")
        return firstDuoBulletPointView
    } ()

    private lazy var secondDuoBulletPointView: BulletPointView = {
        let secondDuoBulletPointView = BulletPointView.init(frame: .zero)
        secondDuoBulletPointView.translatesAutoresizingMaskIntoConstraints = false
        secondDuoBulletPointView.bulletColor = .skyBlue
        secondDuoBulletPointView.pointText = NSLocalizedString("duoBulletPoint2", comment: "")
        return secondDuoBulletPointView
    } ()

    private lazy var thirdDuoBulletPointView: BulletPointView = {
        let thirdDuoBulletPointView = BulletPointView.init(frame: .zero)
        thirdDuoBulletPointView.translatesAutoresizingMaskIntoConstraints = false
        thirdDuoBulletPointView.bulletColor = .skyBlue
        thirdDuoBulletPointView.pointText = NSLocalizedString("duoBulletPoint3", comment: "")
        return thirdDuoBulletPointView
    } ()

    private lazy var duoBulletPointsStackView: UIStackView = {
        let duoBulletPointsStackView = UIStackView.init(arrangedSubviews: [firstDuoBulletPointView, secondDuoBulletPointView, thirdDuoBulletPointView])
        duoBulletPointsStackView.translatesAutoresizingMaskIntoConstraints = false
        duoBulletPointsStackView.axis = .vertical
        duoBulletPointsStackView.distribution = .equalSpacing
        duoBulletPointsStackView.spacing = bulletPointViewSpacing
        return duoBulletPointsStackView
    } ()

    private lazy var saveButton: UIButton = {
        let saveButton = UIButton.init(frame: .zero)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        let saveButtonNormalImage = UIImage.init(named: "purple_saved_unfilled")
        let saveButtonSelectedImage = UIImage.init(named: "purple_saved_filled")
        saveButton.setImage(saveButtonNormalImage, for: .normal)
        saveButton.setImage(saveButtonSelectedImage, for: .selected)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        saveButton.isHidden = true
        return saveButton
    } ()

    var delegate: DialogModeSelectionViewControllerDelegate?

    // MARK: MehoAnalytics
    let screenName = "p_meho_talks_preview"
    let screenClass = "p_meho_talks_preview"

    // MARK: - Init
    init() {
        fatalError("init(dialog: Dialog)")
    }

    init(dialog: Dialog, maybeIsSaved: Bool? = nil) {
        self.dialog = dialog
        if let isSaved = maybeIsSaved {
            self.isSaved = isSaved
        }
        let defaults = UserDefaults.standard
        self.isFirstTime = !defaults.bool(forKey: hasSeenDialogModeSelectionKey)
        super.init(nibName: nil, bundle: nil)
        defaults.set(true, forKey: hasSeenDialogModeSelectionKey)
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(dialog: Dialog)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(dialog: Dialog)")
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFirstTime {
            view.addSubview(soloPracticeButton)
            view.addSubview(soloBulletPointsStackView)
            view.addSubview(duoRolePlayButton)
            view.addSubview(duoBulletPointsStackView)
            view.addSubview(contentStackViewBackgroundView)
            contentStackViewBackgroundView.addSubview(contentStackView)
        } else {
            view.addSubview(contentStackView)
            view.addSubview(buttonsStackView)
        }
        view.addSubview(saveButton)
        view.backgroundColor = .white

        difficultyLabel.widthAnchor.constraint(equalToConstant: difficultyLabelWidth).isActive = true
        difficultyLabel.heightAnchor.constraint(equalToConstant: difficultyLabelHeight).isActive = true

        var viewHeight = difficultyLabelTopMargin
        var contentStackViewHeight = difficultyLabelHeight
        let contentStackViewWidth = viewWidth - 2 * contentStackViewLeadingTrailingMargin
        let labelFittingSize = CGSize.init(width: contentStackViewWidth, height: .greatestFiniteMagnitude)
        contentStackViewHeight = contentStackViewHeight + titleLabel.sizeThatFits(labelFittingSize).height + titleLabelTopMargin
        contentStackViewHeight = contentStackViewHeight + titleInLocalLanguageLabel.sizeThatFits(labelFittingSize).height + titleInLocalLanguageLabelTopMargin
        contentStackViewHeight = contentStackViewHeight + introductionLabel.sizeThatFits(labelFittingSize).height + introductionLabelTopMargin
        viewHeight = viewHeight + contentStackViewHeight

        saveButton.widthAnchor.constraint(equalToConstant: saveButtonWidth).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: saveButtonHeight).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -saveButtonTrailingMargin).isActive = true
        if let isSaveButtonSelected = self.isSaved {
            saveButton.isHidden = false
            saveButton.isSelected = isSaveButtonSelected
        }
        if isFirstTime {
            viewHeight = viewHeight + introductionLabelBottomMargin
            contentStackViewBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            contentStackViewBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            contentStackViewBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            let contentStackViewBackgroundViewHeightConstraint = contentStackViewBackgroundView.heightAnchor.constraint(equalToConstant: viewHeight)
            contentStackViewBackgroundViewHeightConstraint.isActive = true

            contentStackView.topAnchor.constraint(equalTo: contentStackViewBackgroundView.topAnchor, constant: difficultyLabelTopMargin).isActive = true
            contentStackView.leadingAnchor.constraint(equalTo: contentStackViewBackgroundView.leadingAnchor, constant: contentStackViewLeadingTrailingMargin).isActive = true
            contentStackView.trailingAnchor.constraint(equalTo: contentStackViewBackgroundView.trailingAnchor, constant: -contentStackViewLeadingTrailingMargin).isActive = true
            let contentStackViewHeightConstraint = contentStackView.heightAnchor.constraint(equalToConstant: contentStackViewHeight)
            contentStackViewHeightConstraint.isActive = true
            saveButton.topAnchor.constraint(equalTo: contentStackView.topAnchor).isActive = true

            viewHeight = viewHeight + buttonHeight + soloPracticeButtonTopMargin
            soloPracticeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: soloPracticeButtonLeadingTrailingMargin).isActive = true
            soloPracticeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -soloPracticeButtonLeadingTrailingMargin).isActive = true
            soloPracticeButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
            let soloPracticeButtonTopConstraint = soloPracticeButton.topAnchor.constraint(equalTo: contentStackViewBackgroundView.bottomAnchor, constant: soloPracticeButtonTopMargin)
            soloPracticeButtonTopConstraint.isActive = true

            let bulletPointsStackViewWidth = viewWidth - 2 * bulletPointsStackViewLeadingTrailingMargin
            let bulletPointFittingSize = CGSize.init(width: bulletPointsStackViewWidth, height: .greatestFiniteMagnitude)
            let firstSoloBulletPointViewHeight = firstSoloBulletPointView.sizeThatFits(bulletPointFittingSize).height
            let secondSoloBulletPointViewHeight = secondSoloBulletPointView.sizeThatFits(bulletPointFittingSize).height
            let thirdSoloBulletPointViewHeight = thirdSoloBulletPointView.sizeThatFits(bulletPointFittingSize).height
            let soloBulletPointsStackViewHeight = firstSoloBulletPointViewHeight + secondSoloBulletPointViewHeight + thirdSoloBulletPointViewHeight + 2 * bulletPointViewSpacing
            viewHeight = viewHeight + bulletPointsStackViewTopMargin + soloBulletPointsStackViewHeight + bulletPointsStackViewBottomMargin

            soloBulletPointsStackView.heightAnchor.constraint(equalToConstant: soloBulletPointsStackViewHeight).isActive = true
            let soloBulletPointsStackViewTopConstraint = soloBulletPointsStackView.topAnchor.constraint(equalTo: soloPracticeButton.bottomAnchor, constant: bulletPointsStackViewTopMargin)
            soloBulletPointsStackViewTopConstraint.isActive = true
            soloBulletPointsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: bulletPointsStackViewLeadingTrailingMargin).isActive = true
            soloBulletPointsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -bulletPointsStackViewLeadingTrailingMargin).isActive = true
            let soloBulletPointsStackViewBottomConstraint = soloBulletPointsStackView.bottomAnchor.constraint(equalTo: duoRolePlayButton.topAnchor, constant: -bulletPointsStackViewBottomMargin)
            soloBulletPointsStackViewBottomConstraint.isActive = true

            viewHeight = viewHeight + buttonHeight

            duoRolePlayButton.leadingAnchor.constraint(equalTo: soloPracticeButton.leadingAnchor).isActive = true
            duoRolePlayButton.trailingAnchor.constraint(equalTo: soloPracticeButton.trailingAnchor).isActive = true
            duoRolePlayButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true

            let firstDuoBulletPointViewHeight = firstDuoBulletPointView.sizeThatFits(bulletPointFittingSize).height
            let secondDuoBulletPointViewHeight = secondDuoBulletPointView.sizeThatFits(bulletPointFittingSize).height
            let thirdDuoBulletPointViewHeight = thirdDuoBulletPointView.sizeThatFits(bulletPointFittingSize).height
            let duoBulletPointsStackViewHeight = firstDuoBulletPointViewHeight + secondDuoBulletPointViewHeight + thirdDuoBulletPointViewHeight + 2 * bulletPointViewSpacing
            viewHeight = viewHeight + bulletPointsStackViewTopMargin + duoBulletPointsStackViewHeight + bulletPointsStackViewBottomMargin

            duoBulletPointsStackView.heightAnchor.constraint(equalToConstant: duoBulletPointsStackViewHeight).isActive = true
            let duoBulletPointsStackViewTopConstraint = duoBulletPointsStackView.topAnchor.constraint(equalTo: duoRolePlayButton.bottomAnchor, constant: bulletPointsStackViewTopMargin)
            duoBulletPointsStackViewTopConstraint.isActive = true
            duoBulletPointsStackView.leadingAnchor.constraint(equalTo: soloBulletPointsStackView.leadingAnchor).isActive = true
            duoBulletPointsStackView.trailingAnchor.constraint(equalTo: soloBulletPointsStackView.trailingAnchor).isActive = true
            if viewHeight > UIScreen.main.bounds.height * 0.9 {
                duoBulletPointsStackViewTopConstraint.constant = bulletPointsStackViewTopMargin / 2
                soloBulletPointsStackViewTopConstraint.constant = bulletPointsStackViewTopMargin / 2
                soloPracticeButtonTopConstraint.constant = soloPracticeButtonTopMargin / 2
                soloBulletPointsStackViewBottomConstraint.constant = -bulletPointsStackViewBottomMargin / 2
                contentStackView.setCustomSpacing(titleLabelTopMargin / 2, after: difficultyLabel)
                contentStackView.setCustomSpacing(titleInLocalLanguageLabelTopMargin / 2, after: titleLabel)
                contentStackView.setCustomSpacing(introductionLabelTopMargin / 2, after: titleInLocalLanguageLabel)
                let contentStackViewHeightDiff = titleLabelTopMargin / 2 + titleInLocalLanguageLabelTopMargin / 2 + introductionLabelTopMargin / 2
                contentStackViewBackgroundViewHeightConstraint.constant = contentStackViewBackgroundViewHeightConstraint.constant - contentStackViewHeightDiff
                contentStackViewHeightConstraint.constant = contentStackViewHeightConstraint.constant - contentStackViewHeightDiff
                viewHeight = viewHeight - bulletPointsStackViewTopMargin - soloPracticeButtonTopMargin / 2 - bulletPointsStackViewBottomMargin - contentStackViewHeightDiff
            }
        } else {
            contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: difficultyLabelTopMargin).isActive = true
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentStackViewLeadingTrailingMargin).isActive = true
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentStackViewLeadingTrailingMargin).isActive = true
            contentStackView.heightAnchor.constraint(equalToConstant: contentStackViewHeight).isActive = true
            saveButton.topAnchor.constraint(equalTo: contentStackView.topAnchor).isActive = true

            viewHeight = viewHeight + buttonsStackViewTopMargin + buttonsStackViewHeight + buttonsStackViewBottomMargin
            buttonsStackView.topAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: buttonsStackViewTopMargin).isActive = true
            buttonsStackView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor).isActive = true
            buttonsStackView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor).isActive = true
            buttonsStackView.heightAnchor.constraint(equalToConstant: buttonsStackViewHeight).isActive = true
        }

        preferredContentSize = CGSize.init(width: viewWidth, height: viewHeight)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }

    // MARK: - Private
    @objc
    func didTapSoloPracticeButton() {
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_talks_preview-view_solo",
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "view_solo",
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        delegate?.dialogModeSelectionViewControllerDidTapSoloPracticeButton(dialog: dialog)
    }

    @objc
    func didTapDuoRolePlayButton()  {
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_talks_preview-view_duo",
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "view_duo",
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        delegate?.dialogModeSelectionViewControllerDidTapDuoRolePlayButton(dialog: dialog)
    }

    @objc
    func didTapSaveButton() {
        // we can cast isSaved value because if isSaved value was not successfully fetched initially, isSaved value won't be set and this button is hidden. thus if the user can tap on it, it means we have a valid isSaved value.
        guard let userId = AWSMobileClient.default().userSub else { return }
        if self.isSaved! {
            userDataFetcher.deleteUserItemSave(userId: userId, itemId: dialog.identifier) { (unsaveSuccess, error) in
                if (error == nil && unsaveSuccess) {
                    self.isSaved = false
                    self.saveButton.isSelected = false
                    self.delegate?.dialogModeSelectionViewControllerDidTapSaveButton(isSaved: false)
                }
            }
        } else {
            userDataFetcher.createUserItemSave(userId: userId, itemId: dialog.identifier, itemType: "DIALOGUE") { (saveSuccess, error) in
                if (error == nil && saveSuccess) {
                    self.isSaved = true
                    self.saveButton.isSelected = true
                    self.delegate?.dialogModeSelectionViewControllerDidTapSaveButton(isSaved: true)
                }
            }
        }
        saveButton.isSelected = !saveButton.isSelected
    }
}
