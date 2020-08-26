//
//  DifficultyViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/18/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import FirebaseAnalytics

protocol DifficultyViewControllerDelegate {
    func didSelectDifficulty(_ difficulty:Difficulty)
}

class DifficultyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    // MARK: - Constants
    let titleLabelFontSize = CGFloat(16)
    let cellReuseIdentifier = "cellReuseIdentifier"
    let tableViewRowHeight = CGFloat(54)
    let purpleViewHorizontalMargin = CGFloat(20)
    let purpleViewVerticalMargin = CGFloat(8)
    let purpleViewHeight = CGFloat(3)
    let viewWidth = CGFloat(270)
    let viewVerticalMargin = CGFloat(16)
    let cellFontSize = CGFloat(15)

    // MARK: - Properties
    var allDifficulties:[Difficulty]
    var currentDifficulty:Difficulty
    let titleLabel = UILabel.init(frame: .zero)
    let purpleView = UIView.init(frame: .zero)
    let tableView = UITableView.init(frame: .zero, style: .plain)
    var delegate:DifficultyViewControllerDelegate?

    // MARK: - Init
    init() {
        fatalError("Use init(allDifficulties: [Difficulty], currentDifficulty: Difficulty)")
    }

    init(allDifficulties: [Difficulty], currentDifficulty: Difficulty) {
        self.allDifficulties = allDifficulties
        self.currentDifficulty = currentDifficulty
        self.titleLabel.text = NSLocalizedString("DifficultyLevelTitle", comment: "")
        super.init(nibName: nil, bundle: nil)
        let titleLabelHeight = self.titleLabel.sizeThatFits(CGSize(width: viewWidth, height: .greatestFiniteMagnitude)).height
        let viewVerticalMargins = viewVerticalMargin * 2
        let titleLabelHeightAndMargins = titleLabelHeight + 2 * purpleViewVerticalMargin
        let tableViewHeight = CGFloat(allDifficulties.count) * tableViewRowHeight
        let viewHeight = viewVerticalMargins + titleLabelHeightAndMargins + tableViewHeight
        self.preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(allDifficulties: [Difficulty], currentDifficulty: Difficulty)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(allDifficulties: [Difficulty], currentDifficulty: Difficulty)")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        titleLabel.textColor = .darkGrayTwo
        titleLabel.font = UIFont.init(name: "SFCompactRounded-Medium", size: titleLabelFontSize)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)

        purpleView.backgroundColor = .wisteriaPurple
        purpleView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(purpleView)

        tableView.separatorColor = .borderGray
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = .zero
        self.view.addSubview(tableView)

        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: viewVerticalMargin).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        purpleView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: purpleViewVerticalMargin).isActive = true
        purpleView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: purpleViewHorizontalMargin).isActive = true
        purpleView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -purpleViewHorizontalMargin).isActive = true
        purpleView.heightAnchor.constraint(equalToConstant: purpleViewHeight).isActive = true
        tableView.topAnchor.constraint(equalTo: purpleView.bottomAnchor, constant: purpleViewVerticalMargin).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: viewVerticalMargin).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let parameters = [
            AnalyticsParameterScreenName: "p_meho_talks_diffculty",
            AnalyticsParameterScreenClass: "p_meho_talks_diffculty",
        ]
        Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil {
            let difficulty = allDifficulties[indexPath.item]
            delegate!.didSelectDifficulty(difficulty)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewRowHeight
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allDifficulties.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let difficulty = allDifficulties[indexPath.item]
        cell.textLabel?.text = difficulty.title
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont.init(name: "SFCompactRounded-Medium", size: cellFontSize)
        if difficulty == currentDifficulty {
            cell.textLabel?.textColor = .black
        } else {
            cell.textLabel?.textColor = .textBlueGray
        }
        return cell
    }
}
