//
//  DuoDetailedDialogViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class DuoDetailedDialogViewController: UIViewController {

    // MARK: - Properties
    // MARK: Model
    private var scoredChapters: [ScoredChapter];

    // MARK: UI
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView.init(progressViewStyle: .bar)
        progressView.progressTintColor = .skyBlue
        return progressView
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
        view.backgroundColor = .white
        navigationItem.titleView = progressView
    }
}
