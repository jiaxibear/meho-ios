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

    init(scoredChapters: [ScoredChapter]) {
        self.scoredChapters = scoredChapters
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
    }
}
