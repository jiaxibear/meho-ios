//
//  DuoDetailedDialogViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class DuoDetailedDialogViewController: UIViewController {

    // MARK: - Constants
    private static let replayButtonNormalImageName = "conversation_play_inactive"
    private static let recordButtonNormalImageName = "conversation_microphone_inactive"
    private static let nextButtonNormalImageName = "conversation_next"
    private static let recordButtonSelectedImageName = "conversation_microphone_active"
    private static let nextButtonDisabledImageName = "conversation_next_inactive"
    private static let replayButtonSelectedImageName = "conversation_play_active"
    private static let replayButtonDisabledImageName = "conversation_play_disabled"
    private static let recordButtonSize = CGFloat(70)
    private static let replayButtonSize = CGFloat(50)
    private static let nextButtonSize = CGFloat(50)
    private static let actionLabelFontSize = CGFloat(14)
    private static let recordButtonBottomMargin = CGFloat(40)
    private static let actionButtonsMargin = CGFloat(48)
    private static let actionButtonsTopMargin = CGFloat(24)

    // MARK: - Properties
    // MARK: Model
    private var scoredChapters: [ScoredChapter];

    // MARK: UI
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView.init(progressViewStyle: .bar)
        progressView.progressTintColor = .skyBlue
        return progressView
    }()

    private lazy var actionlabel: UILabel = {
        let actionLabel = UILabel.init(frame: .zero)
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.textColor = .textBlueGray
        let actionLabelFontDescriptor = UIFont.systemFont(ofSize: DuoDetailedDialogViewController.actionLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        actionLabel.font = UIFont.init(descriptor: actionLabelFontDescriptor!, size: DuoDetailedDialogViewController.actionLabelFontSize)
        actionLabel.numberOfLines = 1
        actionLabel.textAlignment = .center
        return actionLabel
    }()

   private let replayButton: UIButton = {
       let replayButton = UIButton.init(frame: .zero)
       replayButton.translatesAutoresizingMaskIntoConstraints = false
       let replayButtonNormalImage = UIImage.init(named: replayButtonNormalImageName)
       replayButton.setImage(replayButtonNormalImage, for: .normal)
       let replayButtonEnabledImage = UIImage.init(named: replayButtonSelectedImageName)
       replayButton.setImage(replayButtonEnabledImage, for: .selected)
       let replayButtonDisabledImage = UIImage.init(named: replayButtonDisabledImageName)
       replayButton.setImage(replayButtonDisabledImage, for: .disabled)
       replayButton.clipsToBounds = true
       replayButton.layer.cornerRadius = replayButtonSize / 2
       replayButton.addTarget(self, action: #selector(didTapReplayButton), for: .touchUpInside)
       return replayButton
   }()

    private let recordButton: UIButton = {
        let recordButton = UIButton.init(frame: .zero)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        let recordButtonNormalImage = UIImage.init(named: recordButtonNormalImageName)
        recordButton.setImage(recordButtonNormalImage, for: .normal)
        let recordButtonSelectedImage = UIImage.init(named: recordButtonSelectedImageName)
        recordButton.setImage(recordButtonSelectedImage, for: .selected)
        recordButton.clipsToBounds = true
        recordButton.layer.cornerRadius = recordButtonSize / 2
        recordButton.addTarget(self, action: #selector(didTapRecordButton), for: .touchUpInside)
        return recordButton
    }()

    private let nextButton: UIButton = {
        let nextButton = UIButton.init(frame: .zero)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        let nextButtonNormalImage = UIImage.init(named: nextButtonNormalImageName)
        nextButton.setImage(nextButtonNormalImage, for: .normal)
        let nextButtonDisabledImage = UIImage.init(named: nextButtonDisabledImageName)
        nextButton.setImage(nextButtonDisabledImage, for: .selected)
        nextButton.clipsToBounds = true
        nextButton.layer.cornerRadius = nextButtonSize / 2
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return nextButton
    }()

    // MARK: - Init
    init() {
        fatalError("Use init(scoredChapters: [ScoredChapter])")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(scoredChapters: [ScoredChapter])")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(scoredChapters: [ScoredChapter])")
    }

    init(scoredChapters: [ScoredChapter]) {
        self.scoredChapters = scoredChapters
        super.init(nibName: nil, bundle: nil)
        navigationItem.titleView = progressView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(actionlabel)
        view.addSubview(replayButton)
        view.addSubview(recordButton)
        view.addSubview(nextButton)

        recordButton.widthAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.recordButtonSize).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.recordButtonSize).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -DuoDetailedDialogViewController.recordButtonBottomMargin).isActive = true
        recordButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true

        replayButton.widthAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.replayButtonSize).isActive = true
        replayButton.heightAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.replayButtonSize).isActive = true
        replayButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        replayButton.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -DuoDetailedDialogViewController.actionButtonsMargin).isActive = true

        nextButton.widthAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.nextButtonSize).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.nextButtonSize).isActive = true
        nextButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: recordButton.trailingAnchor, constant: DuoDetailedDialogViewController.actionButtonsMargin).isActive = true

        actionlabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        actionlabel.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -DuoDetailedDialogViewController.actionButtonsTopMargin).isActive = true
    }

    // MARK: - Private
    @objc func didTapReplayButton() {

    }

    @objc func didTapRecordButton() {

    }

    @objc func didTapNextButton() {

    }
}
