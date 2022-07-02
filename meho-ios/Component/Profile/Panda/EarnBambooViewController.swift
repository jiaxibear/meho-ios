//
//  EarnBambooViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 5/27/22.
//  Copyright © 2022 Meho. All rights reserved.
//

import UIKit

protocol EarnBambooViewControllerDelegate: AnyObject {
    func didAwakePanda()
}

class EarnBambooViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let titleFontSize = CGFloat(22)
    private let subtitleLabelFontSize = CGFloat(14)
    private let titleLabelTopMargin = CGFloat(40)
    private let subtitleLabelTopMargin = CGFloat(16)
    private let earnBambooCollectionViewLayoutMinimumLineSpacing = CGFloat(12)
    private let earnBambooCollectionViewInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 20, right: 0)
    private let earnBambooCollectionViewCellIdentifier = "earnBambooCollectionViewCellIdentifier"
    private let earnBambooCollectionViewCellHorizontalMargin = CGFloat(10)
    private let earnBambooCollectionViewCellHeight = CGFloat(50)
    private let earnBambooCollectionViewCellWithSubActionsHeight = CGFloat(130)
    private let earnBambooCollectionViewTopMargin = CGFloat(20)
    private let viewWidth = CGFloat(340)

    private let earnBambooStoryEnglish = EarnBamboo.init(numberOfBamboo: "X3", action: "Complete 1 Story in EN")
    private let earnBambooStoryChinese = EarnBamboo.init(numberOfBamboo: "X3", action: "Complete 1 Story in CN")
    private let earnBambooExpression = EarnBamboo.init(numberOfBamboo: "X3", action: "Practice 1 Expression")
    private let earnBambooTalk = EarnBamboo.init(numberOfBamboo: "X2-8", action: "Finish 1 Talk", subActions: ["Finish Single Mode: earn 4 - 8 bamboos based on the difficulty level",
         "Finish Duo Mode: earn 2-4 bamboos each role based on the difficulty level"])
    private var wakeUpPanda = EarnBamboo.init(numberOfBamboo: "=30🎋", action: "Wake up your hibernating panda", subActions: [], isWakingUp: true)
    private lazy var earnBamboos: [EarnBamboo] = {
        return [earnBambooStoryEnglish, earnBambooStoryChinese, earnBambooExpression, earnBambooTalk, wakeUpPanda]
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        var titleFont = UIFont.systemFont(ofSize: titleFontSize, weight: .medium)
        if let titleFontDescriptor = titleFont.fontDescriptor.withDesign(.rounded) {
            titleFont = UIFont.init(descriptor: titleFontDescriptor, size: titleFontSize)
        }
        titleLabel.font = titleFont
        titleLabel.text = NSLocalizedString("EarnBambooTitle", comment: "")
        return titleLabel
    } ()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel.init(frame: .zero)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = .textBlueGray
        var subtitleLabelFont = UIFont.systemFont(ofSize: subtitleLabelFontSize, weight: .medium)
        if let subtitleLabelFontDescriptor = subtitleLabelFont.fontDescriptor.withDesign(.rounded) {
            subtitleLabelFont = UIFont.init(descriptor: subtitleLabelFontDescriptor, size: subtitleLabelFontSize)
        }
        subtitleLabel.font = subtitleLabelFont
        subtitleLabel.text = NSLocalizedString("EarnBambooSubtitle", comment: "")
        return subtitleLabel
    } ()

    private lazy var earnBambooCollectionView: UICollectionView = {
        let earnBambooCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: earnBambooCollectionViewLayout)
        earnBambooCollectionView.translatesAutoresizingMaskIntoConstraints = false
        earnBambooCollectionView.delegate = self
        earnBambooCollectionView.dataSource = self
        earnBambooCollectionView.backgroundColor = .white
        earnBambooCollectionView.contentInset = earnBambooCollectionViewInset
        earnBambooCollectionView.register(EarnBambooCollectionViewCell.self, forCellWithReuseIdentifier: earnBambooCollectionViewCellIdentifier)
        return earnBambooCollectionView
    } ()

    private lazy var earnBambooCollectionViewLayout: UICollectionViewLayout = {
        let earnBambooCollectionViewLayout = UICollectionViewFlowLayout.init()
        earnBambooCollectionViewLayout.minimumLineSpacing = earnBambooCollectionViewLayoutMinimumLineSpacing
        return earnBambooCollectionViewLayout
    } ()

    var delegate: EarnBambooViewControllerDelegate?

    // MARK: - Init
    @available(*, unavailable)
        init() {
        fatalError("Use init(isPandaAsleep: Bool)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(isPandaAsleep: Bool)")
    }

    init(isPandaAsleep: Bool) {
        super.init(nibName: nil, bundle: nil)
        wakeUpPanda.isActive = isPandaAsleep
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .paleGray
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(earnBambooCollectionView)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: titleLabelTopMargin),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: subtitleLabelTopMargin),

            earnBambooCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            earnBambooCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            earnBambooCollectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: earnBambooCollectionViewTopMargin),
            earnBambooCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        var viewHeight = titleLabelTopMargin
        viewHeight += titleLabel.sizeThatFits(CGSize.init(width: viewWidth, height: .greatestFiniteMagnitude)).height
        viewHeight += subtitleLabelTopMargin
        viewHeight += subtitleLabel.sizeThatFits(CGSize.init(width: viewWidth, height: .greatestFiniteMagnitude)).height
        viewHeight += earnBambooCollectionViewTopMargin
        let count = earnBamboos.count
        viewHeight += (CGFloat(count - 1) * earnBambooCollectionViewCellHeight)
        viewHeight += earnBambooCollectionViewCellWithSubActionsHeight
        viewHeight += (CGFloat(count + 1) * earnBambooCollectionViewLayoutMinimumLineSpacing)
        viewHeight += earnBambooCollectionViewInset.top
        viewHeight += earnBambooCollectionViewInset.bottom
        self.preferredContentSize = CGSize.init(width: viewWidth, height: viewHeight)
    }

    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return earnBamboos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: earnBambooCollectionViewCellIdentifier, for: indexPath) as? EarnBambooCollectionViewCell {
            let earnBamboo = earnBamboos[item]
            cell.setEarnBamboo(earnBamboo)
            return cell
        }
        return UICollectionViewCell.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 2 * earnBambooCollectionViewCellHorizontalMargin
        let height = earnBamboos[indexPath.item].subActions.count > 0 ? earnBambooCollectionViewCellWithSubActionsHeight : earnBambooCollectionViewCellHeight
        return CGSize.init(width: width, height: height)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == earnBamboos.endIndex - 1 {
            delegate?.didAwakePanda()
        }
    }
}
