//
//  DetailedDialogViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 3/21/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation

class DetailedDialogViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants
    private let collapsedChapterCollectionViewCellReuseIdentifier = "collapsedChapterCollectionViewCellReuseIdentifier"
    private let expandedChapterCollectionViewCellReuseIdentifier = "expandedChapterCollectionViewCellReuseIdentifier"
    private let duoModeFooterCollectionResuableViewReuseIdentifier = "duoModeFooterCollectionResuableViewReuseIdentifier"

    // MARK: - Properties
    // MARK: Model
    private let conversationDataFetcher = ConversationDataFetcher.init()
    private var scoredChapters: [ScoredChapter] = []
    private let dialogID: String
    private var currentChapterIndex = 0
    private var hasAutoPlayedAudio = false

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
        chaptersCollectionView.register(DuoModeFooterCollectionResuableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: duoModeFooterCollectionResuableViewReuseIdentifier)
        chaptersCollectionView.delegate = self
        chaptersCollectionView.dataSource = self
        return chaptersCollectionView
    }()

    // MARK: - Init
    init() {
        fatalError("Use init")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    init(dialogID: String) {
        self.dialogID = dialogID
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.topItem?.title = ""
        conversationDataFetcher.fetchDetailedDialog(dialogID: dialogID) { (dialog, error) in
            if (dialog != nil && error == nil) {
                self.scoredChapters = dialog!.chapters.map({ (chapter) -> ScoredChapter in
                    return ScoredChapter.init(chapter: chapter)
                })
                DispatchQueue.main.async {
                    self.chaptersCollectionView.reloadData()
                    let audioSession = AVAudioSession.sharedInstance()
                    do {
                        try audioSession.setCategory(.playAndRecord, mode: .default)
                        try audioSession.setActive(true)
                        audioSession.requestRecordPermission { (allowed) in
                            // TODO: Add UI if not allowed.
                        }
                    } catch {
                        // TODO: Add UI if not allowed.
                    }
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
            expandedChapterCollectionViewCell.setScoredChapter(scoredChapters[currentChapterIndex])
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
        collectionView.reloadItems(at: [IndexPath.init(item: previousCurrentChapterIndex, section: 0), IndexPath.init(item: currentChapterIndex, section: 0)])
        collectionView.scrollToItem(at: IndexPath.init(item: currentChapterIndex, section: 0), at: .top, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !hasAutoPlayedAudio && indexPath.item == 0, let expandedCell = cell as? ExpandedChapterCollectionViewCell {
            expandedCell.playAudio()
            hasAutoPlayedAudio = true;
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if scoredChapters.count == 0 {
            return CGSize.zero
        }
        let height = DuoModeFooterCollectionResuableView.viewHeight
        return CGSize.init(width: 0, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            if let duoModeFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: duoModeFooterCollectionResuableViewReuseIdentifier, for: indexPath) as? DuoModeFooterCollectionResuableView {
                return duoModeFooterView
            }
        }
        return UICollectionReusableView.init(frame: .zero)
    }
}
