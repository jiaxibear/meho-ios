//
//  DetailedDialogViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 3/21/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation

class DetailedDialogViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DuoModeFooterCollectionResuableViewDelegate {

    // MARK: - Constants
    private let collapsedChapterCollectionViewCellReuseIdentifier = "collapsedChapterCollectionViewCellReuseIdentifier"
    private let expandedChapterCollectionViewCellReuseIdentifier = "expandedChapterCollectionViewCellReuseIdentifier"
    private let duoModeFooterCollectionResuableViewReuseIdentifier = "duoModeFooterCollectionResuableViewReuseIdentifier"

    // MARK: - Properties
    // MARK: Model
    private let conversationDataFetcher = ConversationDataFetcher.init()
    private let expressionDataFetcher = ExpressionDataFetcher.init()
    private var scoredChapters: [ScoredChapter] = []
    private let dialogID: String!
    private let survivalPhraseCategoryIdentifier: String!
    private var currentChapterIndex = 0
    private var hasAutoPlayedAudio = false
    private let displayScoreSwitch: DisplayScoreSwitch?

    // MARK: UI
    private lazy var chaptersCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let chaptersCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        chaptersCollectionViewFlowLayout.minimumLineSpacing = 0
        return chaptersCollectionViewFlowLayout
    }()

    private lazy var chaptersCollectionView: UICollectionView = {
        let chaptersCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: chaptersCollectionViewFlowLayout)
        chaptersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        chaptersCollectionView.backgroundColor = .white
        chaptersCollectionView.register(CollapsedChapterCollectionViewCell.self, forCellWithReuseIdentifier: collapsedChapterCollectionViewCellReuseIdentifier)
        chaptersCollectionView.register(ExpandedChapterCollectionViewCell.self, forCellWithReuseIdentifier: expandedChapterCollectionViewCellReuseIdentifier)
        if self.dialogID != nil {
            chaptersCollectionView.register(DuoModeFooterCollectionResuableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: duoModeFooterCollectionResuableViewReuseIdentifier)
        }
        chaptersCollectionView.delegate = self
        chaptersCollectionView.dataSource = self
        return chaptersCollectionView
    }()

    // MARK: - Init
    init() {
        fatalError("Use init(dialogID: String)")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(dialogID: String)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(dialogID: String)")
    }

    init(dialogID: String) {
        self.dialogID = dialogID
        survivalPhraseCategoryIdentifier = nil
        displayScoreSwitch = nil
        super.init(nibName: nil, bundle: nil)
    }

    init(survivalPhraseCategoryIdentifier: String, title: String) {
        self.survivalPhraseCategoryIdentifier = survivalPhraseCategoryIdentifier
        dialogID = nil
        displayScoreSwitch = DisplayScoreSwitch.init(frame: .zero)
        super.init(nibName: nil, bundle: nil)
        self.title = title
        displayScoreSwitch!.toggleSwitch.addTarget(self, action: #selector(displayScoreSwitchValueChanged), for: .valueChanged)
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        if title == nil {
            navigationController?.navigationBar.topItem?.title = ""
        }
        if displayScoreSwitch != nil {
            let displayScoreBarButtonItem = UIBarButtonItem.init(customView: displayScoreSwitch!)
            navigationItem.rightBarButtonItem = displayScoreBarButtonItem
        }
        if dialogID != nil {
            conversationDataFetcher.fetchDetailedDialog(dialogID: dialogID) { (dialog, error) in
                if (dialog != nil && error == nil) {
                    self.scoredChapters = dialog!.chapters.map({ (chapter) -> ScoredChapter in
                        return ScoredChapter.init(chapter: chapter)
                    })
                    DispatchQueue.main.async {
                        self.chaptersCollectionView.reloadData()
                        let audioSession = AVAudioSession.sharedInstance()
                        audioSession.requestRecordPermission { (allowed) in
                            // TODO: Add UI if not allowed.
                        }
                    }
                }
            }
        } else if survivalPhraseCategoryIdentifier != nil {
            expressionDataFetcher.fetchSurvivalPhrases(category: survivalPhraseCategoryIdentifier) { (result) in
                switch result {
                case .success(let chapters):
                self.scoredChapters = chapters.map({ (chapter) -> ScoredChapter in
                    return ScoredChapter.init(chapter: chapter)
                })
                DispatchQueue.main.async {
                    self.hasAutoPlayedAudio = true
                    self.chaptersCollectionView.reloadData()
                    let audioSession = AVAudioSession.sharedInstance()
                    audioSession.requestRecordPermission { (allowed) in
                        // TODO: Add UI if not allowed.
                    }
                }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            }
        }


        view.addSubview(chaptersCollectionView)

        // Sets up layout constraints
        chaptersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chaptersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        chaptersCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        chaptersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scoredChapters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.item == currentChapterIndex) {
            let expandedChapterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: expandedChapterCollectionViewCellReuseIdentifier, for: indexPath) as! ExpandedChapterCollectionViewCell
            expandedChapterCollectionViewCell.setScoredChapter(scoredChapters[currentChapterIndex], isSaveButtonHidden: dialogID != nil)
            return expandedChapterCollectionViewCell
        }
        let collapsedChapterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: collapsedChapterCollectionViewCellReuseIdentifier, for: indexPath) as! CollapsedChapterCollectionViewCell
        collapsedChapterCollectionViewCell.setScoredChapter(scoredChapters[indexPath.item])
        return collapsedChapterCollectionViewCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width;
        let chapter = scoredChapters[indexPath.item].chapter
        if (indexPath.item == currentChapterIndex) {
            let height = ExpandedChapterCollectionViewCell.cellHeight(with: width, chapter: chapter)
            return CGSize.init(width: width, height: height)
        }
        let height = CollapsedChapterCollectionViewCell.cellHeight(with: width, chapter: chapter)
        return CGSize.init(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chapterIndex = indexPath.item
        if chapterIndex == currentChapterIndex {
            return
        }
        let previousCurrentChapterIndex = currentChapterIndex
        currentChapterIndex = indexPath.item
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [IndexPath.init(item: previousCurrentChapterIndex, section: 0), IndexPath.init(item: currentChapterIndex, section: 0)])
        }
        collectionView.scrollToItem(at: IndexPath.init(item: currentChapterIndex, section: 0), at: .top, animated: true)
        if let expandedChapterCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ExpandedChapterCollectionViewCell {
            expandedChapterCollectionViewCell.playAudio()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !hasAutoPlayedAudio && indexPath.item == 0, let expandedCell = cell as? ExpandedChapterCollectionViewCell {
            expandedCell.playAudio()
            hasAutoPlayedAudio = true;
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if scoredChapters.count == 0 || dialogID == nil {
            return CGSize.zero
        }
        let height = DuoModeFooterCollectionResuableView.viewHeight
        return CGSize.init(width: 0, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            if let duoModeFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: duoModeFooterCollectionResuableViewReuseIdentifier, for: indexPath) as? DuoModeFooterCollectionResuableView {
                duoModeFooterView.delegate = self
                return duoModeFooterView
            }
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    // MARK: - DuoModeFooterCollectionResuableViewDelegate
    func duoModeFooterCollectionResuableViewDidTapButton(_ view: DuoModeFooterCollectionResuableView) {
        let duoDetailerDialogViewController = DuoDetailedDialogViewController.init(scoredChapters: scoredChapters)
        navigationController?.pushViewController(duoDetailerDialogViewController, animated: true)
    }

    // MARK: - Private
    @objc
    func displayScoreSwitchValueChanged() {
        let shouldDisplayScore = displayScoreSwitch?.toggleSwitch.isOn
        if shouldDisplayScore != nil {
            for scoredChapter in scoredChapters {
                scoredChapter.shouldDisplayScore = shouldDisplayScore!
                chaptersCollectionView.reloadData()
            }
        }
    }
}
