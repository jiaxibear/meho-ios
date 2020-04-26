//
//  DuoDetailedDialogViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class DuoDetailedDialogViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
    private static let duoOtherRoleCollectionViewCellReuseIdentifier = "duoOtherRoleCollectionViewCellReuseIdentifier"

    // MARK: - Properties
    // MARK: Model
    private var scoredChapters: [ScoredChapter];
    private var currentScoredChapters: [ScoredChapter] = []

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

    private lazy var replayButton: UIButton = {
        let replayButton = UIButton.init(frame: .zero)
        replayButton.translatesAutoresizingMaskIntoConstraints = false
        let replayButtonNormalImage = UIImage.init(named: DuoDetailedDialogViewController.replayButtonNormalImageName)
        replayButton.setImage(replayButtonNormalImage, for: .normal)
        let replayButtonEnabledImage = UIImage.init(named: DuoDetailedDialogViewController.replayButtonSelectedImageName)
        replayButton.setImage(replayButtonEnabledImage, for: .selected)
        let replayButtonDisabledImage = UIImage.init(named: DuoDetailedDialogViewController.replayButtonDisabledImageName)
        replayButton.setImage(replayButtonDisabledImage, for: .disabled)
        replayButton.clipsToBounds = true
        replayButton.layer.cornerRadius = DuoDetailedDialogViewController.replayButtonSize / 2
        replayButton.addTarget(self, action: #selector(didTapReplayButton), for: .touchUpInside)
        return replayButton
    }()

    private lazy var recordButton: UIButton = {
        let recordButton = UIButton.init(frame: .zero)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        let recordButtonNormalImage = UIImage.init(named: DuoDetailedDialogViewController.recordButtonNormalImageName)
        recordButton.setImage(recordButtonNormalImage, for: .normal)
        let recordButtonSelectedImage = UIImage.init(named: DuoDetailedDialogViewController.recordButtonSelectedImageName)
        recordButton.setImage(recordButtonSelectedImage, for: .selected)
        recordButton.clipsToBounds = true
        recordButton.layer.cornerRadius = DuoDetailedDialogViewController.recordButtonSize / 2
        recordButton.addTarget(self, action: #selector(didTapRecordButton), for: .touchUpInside)
        return recordButton
    }()

    private lazy var nextButton: UIButton = {
        let nextButton = UIButton.init(frame: .zero)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        let nextButtonNormalImage = UIImage.init(named: DuoDetailedDialogViewController.nextButtonNormalImageName)
        nextButton.setImage(nextButtonNormalImage, for: .normal)
        let nextButtonDisabledImage = UIImage.init(named: DuoDetailedDialogViewController.nextButtonDisabledImageName)
        nextButton.setImage(nextButtonDisabledImage, for: .selected)
        nextButton.clipsToBounds = true
        nextButton.layer.cornerRadius = DuoDetailedDialogViewController.nextButtonSize / 2
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return nextButton
    }()

    private lazy var chaptersCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let chaptersCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        return chaptersCollectionViewFlowLayout
    } ()

    private lazy var chaptersCollectionView: UICollectionView = {
        let chaptersCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: chaptersCollectionViewFlowLayout)
        chaptersCollectionView.backgroundColor = .white
        chaptersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        chaptersCollectionView.register(DuoOtherRoleCollectionViewCell.self, forCellWithReuseIdentifier: DuoDetailedDialogViewController.duoOtherRoleCollectionViewCellReuseIdentifier)
        chaptersCollectionView.dataSource = self
        chaptersCollectionView.delegate = self
        return chaptersCollectionView
    } ()

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
        if let firstChapter = scoredChapters.first {
            currentScoredChapters.append(firstChapter)
            let progress = Float(currentScoredChapters.count) / Float(scoredChapters.count)
            progressView.setProgress(progress, animated: false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(actionlabel)
        view.addSubview(replayButton)
        view.addSubview(recordButton)
        view.addSubview(nextButton)
        view.addSubview(chaptersCollectionView)

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

        chaptersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chaptersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        chaptersCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        chaptersCollectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentScoredChapters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let duoOtherRoleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: DuoDetailedDialogViewController.duoOtherRoleCollectionViewCellReuseIdentifier, for: indexPath) as? DuoOtherRoleCollectionViewCell {
            duoOtherRoleCollectionViewCell.setScoredChapter(currentScoredChapters[indexPath.item])
            return duoOtherRoleCollectionViewCell
        }

        return UICollectionViewCell.init()
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height = DuoOtherRoleCollectionViewCell.cellHeight(with: width, scoredChapter: currentScoredChapters[indexPath.item])
        return CGSize.init(width: width, height: height)
    }

    // MARK: - Private
    @objc func didTapReplayButton() {

    }

    @objc func didTapRecordButton() {

    }

    @objc func didTapNextButton() {

    }
}
