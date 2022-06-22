//
//  DuoFinalScoreViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 5/17/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient
import FirebaseAnalytics

protocol DuoFinalScoreViewControllerDelegate: AnyObject {
    func duoFinalScoreViewControllerDidFinish()
    func duoFinalScoreViewControllerDidContinueWithRole(role: String)
}

class DuoFinalScoreViewController: UIViewController, MehoAnalytics {
    // MARK: - Constants
    private let congratulationsLabelFontSize = CGFloat(24)
    private let finishRoleLabelFontSize = CGFloat(14)
    private let scoreBackgroundContainerViewCornerRadius = CGFloat(5)
    private let avatarImageViewSideLength = CGFloat(40)
    private let nameLabelFontSize = CGFloat(12)
    private let roleALabelFontSize = CGFloat(12)
    private let roleBLabelFontSize = CGFloat(12)
    private let scoreLabelFontSize = CGFloat(14)
    private let roleAScoreLabelFontSize = CGFloat(14)
    private let roleBScoreLabelFontSize = CGFloat(14)
    private let reviewLabelFontSize = CGFloat(14)
    private let buttonHeight = CGFloat(36)
    private let secondaryActionButtonBorderWidth = CGFloat(2)
    private let congratulationsLabelHeight = CGFloat(100)
    private let finishRoleLabelTopMargin = CGFloat(26)
    private let scoreBackgroundContainerViewTopMargin = CGFloat(26)
    private let scoreBackgroundContainerViewLeadingTrailingMargin = CGFloat(10)
    private let scoreBackgroundContainerViewHeight = CGFloat(60)
    private let avatarImageViewLeadingMargin = CGFloat(20)
    private let nameLabelLeadingMargin = CGFloat(20)
    private let roleBLabelTrailingMargin = CGFloat(30)
    private let rolesMargin = CGFloat(30)
    private let reviewLabelTopMargin = CGFloat(20)
    private let mainActionButtonTopMargin = CGFloat(30)
    private let buttonLeadingTrailingMargin = CGFloat(34)
    private let secondaryActionButtonTopMargin = CGFloat(24)
    private let secondaryActionButtonBottomMargin = CGFloat(50)
    private let buttonFontSize = CGFloat(14)

    // MARK: - Properties
    // MARK: Models
    private let userDataFetcher = UserDataFetcher.shared
    private let dialog: Dialog
    private var scoredChapters: [ScoredChapter];
    private let scoreA: Int?
    private let scoreB: Int?
    var delegate: DuoFinalScoreViewControllerDelegate?

    // MARK: Views
    lazy var congratulationsLabel: UILabel = {
        let congratulationsLabel = UILabel.init(frame: .zero)
        congratulationsLabel.textAlignment = .center
        congratulationsLabel.translatesAutoresizingMaskIntoConstraints = false
        congratulationsLabel.backgroundColor = .skyBlue
        congratulationsLabel.textColor = .white
        let congratulationsLabelFontDescriptor = UIFont.systemFont(ofSize: congratulationsLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        congratulationsLabel.font = UIFont.init(descriptor: congratulationsLabelFontDescriptor!, size: 0)
        congratulationsLabel.text = NSLocalizedString("CongratulationsTitle", comment: "")
        return congratulationsLabel
    } ()

    lazy var finishRoleLabel: UILabel = {
        let finishRoleLabel = UILabel.init(frame: .zero)
        finishRoleLabel.translatesAutoresizingMaskIntoConstraints = false
        finishRoleLabel.textColor = .darkGrayTwo
        let finishRoleLabelFontDescriptor = UIFont.systemFont(ofSize: finishRoleLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        finishRoleLabel.font = UIFont.init(descriptor: finishRoleLabelFontDescriptor!, size: 0)
        if self.scoreA != nil && self.scoreB != nil {
            let totalScoreTextFormat = NSLocalizedString("TotalScoreText", comment: "")
            let score = String((self.scoreA! + self.scoreB!) / 2)
            finishRoleLabel.text = String.init(format: totalScoreTextFormat, score)
        } else if self.scoreA != nil {
            let finsihRoleTextFormat = NSLocalizedString("FinishRoleText", comment: "")
            let roleAText = NSLocalizedString("RoleAText", comment: "")
            let finishRoleText = String.init(format: finsihRoleTextFormat, roleAText)
            finishRoleLabel.text = finishRoleText
        } else {
            let finsihRoleTextFormat = NSLocalizedString("FinishRoleText", comment: "")
            let roleBText = NSLocalizedString("RoleBText", comment: "")
            let finishRoleText = String.init(format: finsihRoleTextFormat, roleBText)
            finishRoleLabel.text = finishRoleText
        }
        return finishRoleLabel
    } ()

    lazy var scoreBackgroundContainerView: UIView = {
        let scoreBackgroundContainerView = UIView.init(frame: .zero)
        scoreBackgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
        scoreBackgroundContainerView.backgroundColor = .paleGray
        scoreBackgroundContainerView.clipsToBounds = true
        scoreBackgroundContainerView.layer.cornerRadius = scoreBackgroundContainerViewCornerRadius
        return scoreBackgroundContainerView
    } ()

    lazy var avatarImageView: UIImageView = {
        let avatarImage = UIImage.init(named: "no_profile_pic")
        let avatarImageView = UIImageView.init(image: avatarImage)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageViewSideLength / 2
        return avatarImageView
    } ()

    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel.init(frame: .zero)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .slateGrey
        let nameLabelFontDescriptor = UIFont.systemFont(ofSize: nameLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        nameLabel.font = UIFont.init(descriptor: nameLabelFontDescriptor!, size: 0)
        nameLabel.text = "You"
        return nameLabel
    } ()

    lazy var scoreLabel: UILabel = {
        let scoreLabel = UILabel.init(frame: .zero)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textColor = .slateGrey
        let scoreLabelFontDescriptor = UIFont.systemFont(ofSize: scoreLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        scoreLabel.font = UIFont.init(descriptor: scoreLabelFontDescriptor!, size: 0)
        scoreLabel.text = NSLocalizedString("ScoreText", comment: "")
        return scoreLabel
    } ()

    lazy var roleALabel: UILabel = {
        let roleALabel = UILabel.init(frame: .zero)
        roleALabel.translatesAutoresizingMaskIntoConstraints = false
        roleALabel.textColor = .slateGrey
        let roleALabelFontDescriptor = UIFont.systemFont(ofSize: roleALabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        roleALabel.font = UIFont.init(descriptor: roleALabelFontDescriptor!, size: 0)
        roleALabel.text = NSLocalizedString("RoleAText", comment: "")
        return roleALabel
    } ()

    lazy var roleBLabel: UILabel = {
        let roleBLabel = UILabel.init(frame: .zero)
        roleBLabel.translatesAutoresizingMaskIntoConstraints = false
        roleBLabel.textColor = .slateGrey
        let roleBLabelFontDescriptor = UIFont.systemFont(ofSize: roleBLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        roleBLabel.font = UIFont.init(descriptor: roleBLabelFontDescriptor!, size: 0)
        roleBLabel.text = NSLocalizedString("RoleBText", comment: "")
        return roleBLabel
    } ()

    lazy var roleAScoreLabel: UILabel = {
        let roleAScoreLabel = UILabel.init(frame: .zero)
        roleAScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        roleAScoreLabel.textColor = .wisteriaPurple
        let roleAScoreLabelFontDescriptor = UIFont.systemFont(ofSize: roleAScoreLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        roleAScoreLabel.font = UIFont.init(descriptor: roleAScoreLabelFontDescriptor!, size: 0)
        roleAScoreLabel.text = self.scoreA != nil ? String(self.scoreA!) : "-"
        return roleAScoreLabel
    } ()

    lazy var roleBScoreLabel: UILabel = {
        let roleBScoreLabel = UILabel.init(frame: .zero)
        roleBScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        roleBScoreLabel.textColor = .wisteriaPurple
        let roleBScoreLabelFontDescriptor = UIFont.systemFont(ofSize: roleBScoreLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        roleBScoreLabel.font = UIFont.init(descriptor: roleBScoreLabelFontDescriptor!, size: 0)
        roleBScoreLabel.text = self.scoreB != nil ? String(self.scoreB!) : "-"
        return roleBScoreLabel
    } ()

    lazy var reviewLabel: UILabel = {
        let reviewLabel = UILabel.init(frame: .zero)
        reviewLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewLabel.textColor = .black
        let reviewLabelFontDescriptor = UIFont.systemFont(ofSize: reviewLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        reviewLabel.font = UIFont.init(descriptor: reviewLabelFontDescriptor!, size: 0)
        if self.scoreA != nil && self.scoreB != nil {
            let averageScore = (self.scoreA! + self.scoreB!) / 2
            if averageScore >= 60 {
                reviewLabel.text =  NSLocalizedString("HighScoreText", comment: "")
            } else {
                reviewLabel.text =  NSLocalizedString("LowScoreText", comment: "")
            }
        } else {
            reviewLabel.text = NSLocalizedString("MoreToGoText", comment: "")
        }
        return reviewLabel
    } ()

    lazy var mainActionButton: UIButton = {
        let mainActionButton = UIButton.init(frame: .zero)
        mainActionButton.translatesAutoresizingMaskIntoConstraints = false
        mainActionButton.backgroundColor = .skyBlue
        mainActionButton.setTitleColor(.white, for: .normal)
        let buttonFontDescriptor = UIFont.systemFont(ofSize: buttonFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        mainActionButton.titleLabel?.font = UIFont.init(descriptor: buttonFontDescriptor!, size: 0)
        var mainActionButtonTitle = ""
        if self.scoreA != nil && self.scoreB != nil {
            mainActionButtonTitle = NSLocalizedString("FinishButtonTitle", comment: "")
            mainActionButton.addTarget(self, action: #selector(didTapFinishButton), for: .touchUpInside)
        } else {
            let mainActionButtonTitleFormat = NSLocalizedString("ContinueRoleButtonTitle", comment: "")
            if self.scoreA == nil {
                let roleAText = NSLocalizedString("RoleAText", comment: "")
                mainActionButtonTitle = String.init(format: mainActionButtonTitleFormat, roleAText)
            } else {
                let roleBText = NSLocalizedString("RoleBText", comment: "")
                mainActionButtonTitle = String.init(format: mainActionButtonTitleFormat, roleBText)
            }
            mainActionButton.addTarget(self, action: #selector(didTapContinueRoleButton), for: .touchUpInside)
        }
        mainActionButton.setTitle(mainActionButtonTitle, for: .normal)
        mainActionButton.clipsToBounds = true
        mainActionButton.layer.cornerRadius = buttonHeight / 2;
        return mainActionButton
    } ()

    lazy var secondaryActionButton: UIButton = {
        let secondaryActionButton = UIButton.init(frame: .zero)
        secondaryActionButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonFontDescriptor = UIFont.systemFont(ofSize: buttonFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        secondaryActionButton.titleLabel?.font = UIFont.init(descriptor: buttonFontDescriptor!, size: 0)
        secondaryActionButton.setTitleColor(.skyBlue, for: .normal)
        secondaryActionButton.layer.borderColor = UIColor.skyBlue.cgColor
        let secondaryActionButtonTitle = NSLocalizedString("FinishButtonTitle", comment: "")
        secondaryActionButton.setTitle(secondaryActionButtonTitle, for: .normal)
        secondaryActionButton.clipsToBounds = true
        secondaryActionButton.layer.cornerRadius = buttonHeight / 2;
        secondaryActionButton.layer.borderWidth = secondaryActionButtonBorderWidth
        secondaryActionButton.addTarget(self, action: #selector(didTapFinishButton), for: .touchUpInside)
        return secondaryActionButton
    } ()

    // MARK: MehoAnalytics
    let screenName = "p_meho_talks_report"
    let screenClass = "p_meho_talks_report"

    // MARK: - Init
    init() {
        fatalError("Use init(scoreA: Int?, scoreB: Int?)")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(scoreA: Int?, scoreB: Int?)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(scoreA: Int?, scoreB: Int?)")
    }

    init(dialog: Dialog, scoredChapters: [ScoredChapter], scoreA: Int?, scoreB: Int?) {
        self.dialog = dialog
        self.scoredChapters = scoredChapters
        self.scoreA = scoreA
        self.scoreB = scoreB
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateDialogCompletionIfNeeded()
        view.backgroundColor = .white
        view.addSubview(congratulationsLabel)
        view.addSubview(finishRoleLabel)
        view.addSubview(scoreBackgroundContainerView)
        scoreBackgroundContainerView.addSubview(avatarImageView)
        scoreBackgroundContainerView.addSubview(nameLabel)
        scoreBackgroundContainerView.addSubview(scoreLabel)
        scoreBackgroundContainerView.addSubview(roleALabel)
        scoreBackgroundContainerView.addSubview(roleAScoreLabel)
        scoreBackgroundContainerView.addSubview(roleBLabel)
        scoreBackgroundContainerView.addSubview(roleBScoreLabel)
        view.addSubview(reviewLabel)
        view.addSubview(mainActionButton)
        if self.scoreA == nil || self.scoreB == nil {
            view.addSubview(secondaryActionButton)
        }

        congratulationsLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        congratulationsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        congratulationsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        congratulationsLabel.heightAnchor.constraint(equalToConstant: congratulationsLabelHeight).isActive = true

        finishRoleLabel.topAnchor.constraint(equalTo: congratulationsLabel.bottomAnchor, constant: finishRoleLabelTopMargin).isActive = true
        finishRoleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        scoreBackgroundContainerView.topAnchor.constraint(equalTo: finishRoleLabel.bottomAnchor, constant: scoreBackgroundContainerViewTopMargin).isActive = true
        scoreBackgroundContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: scoreBackgroundContainerViewLeadingTrailingMargin).isActive = true
        scoreBackgroundContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -scoreBackgroundContainerViewLeadingTrailingMargin).isActive = true
        scoreBackgroundContainerView.heightAnchor.constraint(equalToConstant: scoreBackgroundContainerViewHeight).isActive = true

        avatarImageView.leadingAnchor.constraint(equalTo: scoreBackgroundContainerView.leadingAnchor, constant: avatarImageViewLeadingMargin).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: avatarImageViewSideLength).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: avatarImageViewSideLength).isActive = true
        avatarImageView.centerYAnchor.constraint(equalTo: scoreBackgroundContainerView.centerYAnchor).isActive = true

        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: nameLabelLeadingMargin).isActive = true
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor).isActive = true

        scoreLabel.centerXAnchor.constraint(equalTo: nameLabel.centerXAnchor).isActive = true
        scoreLabel.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor).isActive = true

        roleBLabel.trailingAnchor.constraint(equalTo: scoreBackgroundContainerView.trailingAnchor, constant: -roleBLabelTrailingMargin).isActive = true
        roleBLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true

        roleBScoreLabel.centerXAnchor.constraint(equalTo: roleBLabel.centerXAnchor).isActive = true
        roleBScoreLabel.centerYAnchor.constraint(equalTo: scoreLabel.centerYAnchor).isActive = true

        roleALabel.trailingAnchor.constraint(equalTo: roleBLabel.leadingAnchor, constant: -rolesMargin).isActive = true
        roleALabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true

        roleAScoreLabel.centerXAnchor.constraint(equalTo: roleALabel.centerXAnchor).isActive = true
        roleAScoreLabel.centerYAnchor.constraint(equalTo: scoreLabel.centerYAnchor).isActive = true

        reviewLabel.topAnchor.constraint(equalTo: scoreBackgroundContainerView.bottomAnchor, constant: reviewLabelTopMargin).isActive = true
        reviewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        mainActionButton.topAnchor.constraint(equalTo: reviewLabel.bottomAnchor, constant: mainActionButtonTopMargin).isActive = true
        mainActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: buttonLeadingTrailingMargin).isActive = true
        mainActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -buttonLeadingTrailingMargin).isActive = true
        mainActionButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true

        if self.scoreA == nil || self.scoreB == nil {
            secondaryActionButton.topAnchor.constraint(equalTo: mainActionButton.bottomAnchor, constant: secondaryActionButtonTopMargin).isActive = true
            secondaryActionButton.leadingAnchor.constraint(equalTo: mainActionButton.leadingAnchor).isActive = true
            secondaryActionButton.trailingAnchor.constraint(equalTo: mainActionButton.trailingAnchor).isActive = true
            secondaryActionButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }

    // MARK: - Async Processing of dialog completion state
    func updateDialogCompletionIfNeeded() {
        guard let userID = AWSMobileClient.default().userSub else {
            return
        }
        let dialogID = dialog.identifier
        userDataFetcher.getUserItemCompleted(userId: userID, itemId: dialogID) { isCompleted, error in
            if (error == nil && !isCompleted) {
                self.userDataFetcher.fetchLatestDuoScoresOfDialogRest(dialogID: dialogID, userID: userID) { (maybeDuoScoresMap, maybeError) in
                    if maybeError == nil, let duoScoreMap = maybeDuoScoresMap, self.isDialogCompleted(duoScoreMap: duoScoreMap) {
                        self.userDataFetcher.deleteUserItemInProgress(userId: userID, itemId: dialogID) { (removeInProgressSuccess, error) in
                            if (error == nil && removeInProgressSuccess) {
                                // do nothing
                                print("user:" + userID + ", dialog:" + self.dialog.identifier + " - remove inprogress successful")
                            } else {
                                print("user:" + userID + ", dialog:" + self.dialog.identifier + " - remove inprogress failed")
                            }
                        }
                        self.userDataFetcher.createUserItemCompleted(userId: userID, itemId: self.dialog.identifier, itemType: "DIALOGUE") { (createCompletedSuccess, error) in
                            if (error == nil && createCompletedSuccess) {
                                // do nothing
                                print("user:" + userID + ", dialog:" + self.dialog.identifier + " - added completed successful")
                            } else {
                                print("user:" + userID + ", dialog:" + self.dialog.identifier + " - added completed failed")
                            }
                        }
        //
        //                let messageFormat = NSLocalizedString("EarnBambooMessage", comment: "");
        //                let message = String.init(format: messageFormat, String(2), NSLocalizedString("EarnBambooReasonPracticing", comment: "")) + "\n"
                    }
                }
            }
        }
    }

    func isDialogCompleted(duoScoreMap:[String:Double]) -> Bool {
        for scoredChapter in scoredChapters {
            if duoScoreMap[scoredChapter.chapter.identifier] == nil {
                return false
            }
        }
        return true
    }

    // MARK: - Internal
    func viewHeight(width: CGFloat) -> CGFloat {
        let fittingSize = CGSize.init(width: width, height: .greatestFiniteMagnitude)
        var height = congratulationsLabelHeight + finishRoleLabel.sizeThatFits(fittingSize).height + scoreBackgroundContainerViewTopMargin + scoreBackgroundContainerViewHeight + reviewLabelTopMargin + reviewLabel.sizeThatFits(fittingSize).height + mainActionButtonTopMargin + buttonHeight + secondaryActionButtonBottomMargin
        if self.scoreA == nil || self.scoreB == nil {
            height = height + buttonHeight + secondaryActionButtonTopMargin
        }
        return height
    }

    // MARK: - Private
    @objc
    private func didTapFinishButton() {
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_talk_reports-finish",
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "finish",
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        delegate?.duoFinalScoreViewControllerDidFinish()
    }

    @objc
    private func didTapContinueRoleButton() {
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_talk_reports-continue_next_role",
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "continue_next_role",
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        delegate?.duoFinalScoreViewControllerDidContinueWithRole(role: "")
    }
}
