//
//  DialogViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/22/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class DialogViewController: UIViewController, UIGestureRecognizerDelegate {

    let backgroundView = UIView.init(frame: .zero)
    let backgroundViewAlpha = CGFloat(CGFloat(99)/256)
    let contentView: UIView
    let contentViewCornerRadius = CGFloat(10)
    let contentViewController: UIViewController

    // MARK: - Init
    init() {
        fatalError("Use init(allDifficulties: [Difficulty], currentDifficulty: Difficulty)")
    }

    init(contentViewController: UIViewController) {
        self.contentView = contentViewController.view
        self.contentViewController = contentViewController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(allDifficulties: [Difficulty], currentDifficulty: Difficulty)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(allDifficulties: [Difficulty], currentDifficulty: Difficulty)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Sets up background view.
        backgroundView.backgroundColor = UIColor.init(white: 0, alpha: backgroundViewAlpha)
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackgroundView))
        tapGestureRecognizer.delegate = self
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundView)

        // Sets up content view.
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = contentViewCornerRadius
        self.addChild(contentViewController)
        backgroundView.addSubview(contentView)
        contentViewController.didMove(toParent: self)

        // Sets up layout constraints
        backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

        let contentViewSize = contentViewController.preferredContentSize
        contentView.centerXAnchor.constraint(equalTo: self.backgroundView.centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: self.backgroundView.centerYAnchor).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: contentViewSize.width).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: contentViewSize.height).isActive = true
    }

    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, touchView.isDescendant(of: contentView) {
            return false
        }
        return true
    }

    // MARK: - Private
    @objc func didTapBackgroundView() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
