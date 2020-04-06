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

    // MARK: - Properties
    private let conversationDataFetcher = ConversationDataFetcher.init()
    private var chapters: [Chapter] = []
    private let dialogID: String
    private let chaptersCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var chaptersCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: chaptersCollectionViewFlowLayout)
    private var currentChapterIndex = 0

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
        conversationDataFetcher.fetchDetailedDialog(dialogID: dialogID) { (dialog, error) in
            if (dialog != nil && error == nil) {
                self.chapters = dialog!.chapters
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

        // Sets up chapters collection view.
        chaptersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        chaptersCollectionView.backgroundColor = .white
        chaptersCollectionView.register(CollapsedChapterCollectionViewCell.self, forCellWithReuseIdentifier: collapsedChapterCollectionViewCellReuseIdentifier)
        chaptersCollectionView.register(ExpandedChapterCollectionViewCell.self, forCellWithReuseIdentifier: expandedChapterCollectionViewCellReuseIdentifier)
        chaptersCollectionView.delegate = self
        chaptersCollectionView.dataSource = self
        view.addSubview(chaptersCollectionView)

        chaptersCollectionViewFlowLayout.minimumLineSpacing = 0

        // Sets up layout constraints
        chaptersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chaptersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        chaptersCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        chaptersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.item == currentChapterIndex) {
            let expandedChapterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: expandedChapterCollectionViewCellReuseIdentifier, for: indexPath) as! ExpandedChapterCollectionViewCell
            expandedChapterCollectionViewCell.setChapter(chapters[currentChapterIndex])
            return expandedChapterCollectionViewCell
        }
        let collapsedChapterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: collapsedChapterCollectionViewCellReuseIdentifier, for: indexPath) as! CollapsedChapterCollectionViewCell
        collapsedChapterCollectionViewCell.setChapter(chapters[indexPath.item])
        return collapsedChapterCollectionViewCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width;
        let chapter = chapters[indexPath.item]
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
}
