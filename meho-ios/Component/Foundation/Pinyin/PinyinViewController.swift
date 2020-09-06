//
//  PinyinViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/15/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import FirebaseAnalytics

enum PinyinSection: Int {
    case initials
    case finals
}

class PinyinViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MehoAnalytics {

    // MARK: - Constants
    private let navigationHeaderText = "拼音基础 Pinyin"
    private let pinyinDetailReminderOneMore = "Please select one Final and one Initial"
    private let pinyinDetailReminderNotFound = "Ops...\n this combo of Final and Initial is invalid, please try again"
    private let initialsDelimiterTitle = "声母 Initials"
    private let finalsDelimiterTitle = "韵母 Finals"
    private let originalInitialText = "Initial"
    private let originalFinalText = "Final"
    private let plusImageName = "purple_plus_sign"
    private let navTitleLabelFontSize = CGFloat(18)
    private let pillCornerRadius = CGFloat(10)
    private let pillBorderWidth = CGFloat(2)
    private let topLabelFontSize = CGFloat(15)
    private let pinyinPartialsCollectionViewTopMargin = CGFloat(150)
    private let topSectionHeight = CGFloat(30)
    private let sectionVerticalInsets = CGFloat(5)
    private let pinyinSectionDelimiterHeight = CGFloat(20)

    private let pinyinHeaderCellReuseIdentifier = "ReusableDelimiterHeaderCell"
    private let initialCellReuseIdentifier = "ReusableInitialCell"
    private let finalCellReuseIdentifier = "ReusablefinalCell"

    // MARK: - Properties
    // MARK: UI
    private let featureName: String
    private let navTitleLabel = UILabel.init(frame: .zero)

    // Top section
    private let initialLabel = UILabel.init(frame: .zero)
    private let finalLabel = UILabel.init(frame: .zero)
    private let plusImageView = UIImageView.init(frame: .zero)

    // Pinyin result section
    private let pinyinDetailView = PinyinDetailView.init(frame: .zero)

    // Pinyin partial section
    private let pinyinCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var pinyinCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:pinyinCollectionViewFlowLayout)

    // MARK: - Data
    private let dataFetcher = FoundationDataFetcher.init()
    private var initials:[String] = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n",
                                     "p", "q", "r", "s", "t", "w", "x", "y", "z", "zh", "ch", "sh"]
    private var finals:[String] = ["a", "ai", "ao", "an", "ang", "e", "ei", "en", "eng", "er",
                                   "i", "ia", "ian", "iang", "iao", "ie", "iong", "iu", "in", "ing",
                                   "o", "ou", "ong", "u", "ua", "uai", "uan", "uang", "uo", "un", "ui"]
    private var sections:[PinyinSection] = []
    private let noneSelectedIdx:Int = -1
    private var selectedInitialIdx:Int
    private var selectedFinalIdx:Int

    // MARK: MehoAnalytics
    var screenName: String {
        return "p_meho_foundations_pinyin"
    }

    var screenClass: String {
        return "p_meho_foundations_pinyin"
    }


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

    init(featureName: String) {
        self.featureName = featureName
        selectedInitialIdx = noneSelectedIdx
        selectedFinalIdx = noneSelectedIdx
        super.init(nibName: nil, bundle: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setUpNavigationBar()
        setupTopSection()
        setupDetailedPinyinView()
        setupPinyinCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }

    // MARK: - UI elements setup
    func setUpNavigationBar() {
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navTitleLabel.text = navigationHeaderText
        navTitleLabel.textColor = .wisteriaPurple
        let navTitlefontDescriptor = UIFont.systemFont(ofSize: navTitleLabelFontSize, weight: .bold).fontDescriptor.withDesign(.rounded)
        navTitleLabel.font = UIFont.init(descriptor: navTitlefontDescriptor!, size: 0)

        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.titleView = navTitleLabel
    }

    func setupTopSection() {
        let topLabelFontDescriptor = UIFont.systemFont(ofSize: topLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        let topLabelFont = UIFont.init(descriptor: topLabelFontDescriptor!, size: 0)

        initialLabel.layer.cornerRadius = pillCornerRadius
        initialLabel.clipsToBounds = true
        initialLabel.layer.borderColor = UIColor.skyBlue.cgColor
        initialLabel.layer.borderWidth = pillBorderWidth
        initialLabel.font = topLabelFont
        initialLabel.text = originalInitialText
        initialLabel.textAlignment = .center
        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(initialLabel)

        finalLabel.layer.cornerRadius = pillCornerRadius
        finalLabel.clipsToBounds = true
        finalLabel.layer.borderColor = UIColor.skyBlue.cgColor
        finalLabel.layer.borderWidth = pillBorderWidth
        finalLabel.font = topLabelFont
        finalLabel.text = originalFinalText
        finalLabel.textAlignment = .center
        finalLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(finalLabel)

        plusImageView.image = UIImage.init(named: plusImageName)
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusImageView)

        plusImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        plusImageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: CGFloat(20)).isActive = true
        plusImageView.heightAnchor.constraint(equalToConstant: topSectionHeight).isActive = true
        plusImageView.widthAnchor.constraint(equalToConstant: CGFloat(33)).isActive = true

        initialLabel.centerYAnchor.constraint(equalTo: plusImageView.centerYAnchor).isActive = true
        initialLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.bounds.width * 0.25).isActive = true
        initialLabel.heightAnchor.constraint(equalToConstant: topSectionHeight).isActive = true
        initialLabel.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.25).isActive = true

        finalLabel.centerYAnchor.constraint(equalTo: plusImageView.centerYAnchor).isActive = true
        finalLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.bounds.width * 0.25).isActive = true
        finalLabel.heightAnchor.constraint(equalToConstant: topSectionHeight).isActive = true
        finalLabel.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.25).isActive = true
    }

    func setupDetailedPinyinView() {
        pinyinDetailView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pinyinDetailView)

        let viewHorizontalMargin = view.bounds.width * 0.05
        pinyinDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: viewHorizontalMargin).isActive = true
        pinyinDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -viewHorizontalMargin).isActive = true
        pinyinDetailView.topAnchor.constraint(equalTo: plusImageView.bottomAnchor, constant: CGFloat(20)).isActive = true
        pinyinDetailView.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.15).isActive = true

    }

    func setupPinyinCollectionView() {
        pinyinCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pinyinCollectionView.backgroundColor = .white
        view.addSubview(pinyinCollectionView)

        // view constraints
        let viewHorizontalMargin = view.bounds.width * 0.05
        pinyinCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: viewHorizontalMargin).isActive = true
        pinyinCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -viewHorizontalMargin).isActive = true
        pinyinCollectionView.topAnchor.constraint(equalTo: pinyinDetailView.bottomAnchor).isActive = true
        pinyinCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        // collection layout
        pinyinCollectionViewFlowLayout.scrollDirection = .vertical
        pinyinCollectionViewFlowLayout.minimumLineSpacing = 10
        pinyinCollectionViewFlowLayout.minimumInteritemSpacing = 5
        pinyinCollectionViewFlowLayout.sectionInset = UIEdgeInsets.init(top: sectionVerticalInsets, left: 0, bottom: sectionVerticalInsets, right: 0)

        // Sets up cell data
        pinyinCollectionView.dataSource = self
        pinyinCollectionView.delegate = self
        pinyinCollectionView.showsVerticalScrollIndicator = false
        pinyinCollectionView.register(PinyinSectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: pinyinHeaderCellReuseIdentifier)
        pinyinCollectionView.register(PinyinInitialCollectionViewCell.self, forCellWithReuseIdentifier:initialCellReuseIdentifier)
        pinyinCollectionView.register(PinyinFinalCollectionViewCell.self, forCellWithReuseIdentifier:finalCellReuseIdentifier)

        sections.insert(.initials, at: 0)
        sections.insert(.finals, at: 1)
    }


    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let pinyinSection = sections[section]
        switch pinyinSection {
        case .initials:
            return initials.count
        case .finals:
            return finals.count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pinyinSection = sections[indexPath.section]
        switch pinyinSection {
        case .initials:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: initialCellReuseIdentifier, for: indexPath) as! PinyinInitialCollectionViewCell
            let initial = initials[indexPath.item]
            cell.setCell(initial: initial)
            return cell
        case .finals:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: finalCellReuseIdentifier, for: indexPath) as! PinyinFinalCollectionViewCell
            let final = finals[indexPath.item]
            cell.setCell(final: final)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: 0, height: pinyinSectionDelimiterHeight)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: pinyinHeaderCellReuseIdentifier, for: indexPath) as? PinyinSectionHeaderCollectionReusableView {
                let pinyinPartialSection = sections[indexPath.section]
                headerView.setTitle(self.titleForPinyinSection(pinyinPartialSection))
                return headerView
            }
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    func titleForPinyinSection(_ pinyinSection : PinyinSection) -> String {
        switch pinyinSection {
        case .initials:
            return initialsDelimiterTitle
        case .finals:
            return finalsDelimiterTitle
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let pinyinSection = sections[indexPath.section]
        let idealCollectionViewWidth = collectionView.bounds.width
        let idealCollectionViewHeight = idealCollectionViewWidth * 1.2
        switch pinyinSection {
        case .initials:
            let cellWidth = idealCollectionViewWidth / 8 * 0.9
            let cellHeight = idealCollectionViewHeight / 10 * 0.8
            return CGSize(width: cellWidth, height: cellHeight)
        case .finals:
            let cellWidth = idealCollectionViewWidth / 6 * 0.9
            let cellHeight = idealCollectionViewHeight / 10 * 0.8
            return CGSize(width: cellWidth, height: cellHeight)
        }

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pinyinSection = sections[indexPath.section]
        switch pinyinSection {
        case .initials:
            if (selectedInitialIdx != noneSelectedIdx) {
                let currentSelectedInitialCell = collectionView.cellForItem(at: IndexPath.init(item: selectedInitialIdx, section: 0)) as! PinyinInitialCollectionViewCell
                currentSelectedInitialCell.unSelectCell()
            }

            if (indexPath.item != selectedInitialIdx) { //  if selected another cell, set it selected
                let tappedCell = collectionView.cellForItem(at: indexPath) as! PinyinInitialCollectionViewCell
                tappedCell.selectCell()
                initialLabel.text = tappedCell.getCellLabel()
                selectedInitialIdx = indexPath.item
            } else { // otherwise selected the original cell, remain unselected and toggle the detail label back
                initialLabel.text = originalInitialText
                selectedInitialIdx = noneSelectedIdx
            }

        case .finals:
            // unselected the previous selected cell anyway
            if (selectedFinalIdx != noneSelectedIdx) {
                let currentSelectedFinalCell = collectionView.cellForItem(at: IndexPath.init(item: selectedFinalIdx, section: 1)) as! PinyinFinalCollectionViewCell
                currentSelectedFinalCell.unSelectCell()
            }

            if (indexPath.item != selectedFinalIdx) { //  if selected another cell, set it selected
                let tappedCell = collectionView.cellForItem(at: indexPath) as! PinyinFinalCollectionViewCell
                tappedCell.selectCell()
                finalLabel.text = tappedCell.getCellLabel()
                selectedFinalIdx = indexPath.item
            } else { // otherwise selected the original cell, remain unselected and toggle the detail label back
                finalLabel.text = originalFinalText
                selectedFinalIdx = noneSelectedIdx
            }

        }
        checkPinyinResult()
    }

    func checkPinyinResult() {
        if (selectedFinalIdx == noneSelectedIdx) { // if user does not even select final, no need to call to search
            self.pinyinDetailView.setNotFound(message: self.pinyinDetailReminderOneMore)
        } else { // user select a initial, can call to search
            let final = finals[selectedFinalIdx]
            let pinyinToSearch = (selectedInitialIdx == noneSelectedIdx)
                ? final : initials[selectedInitialIdx] + final
            dataFetcher.fetchDetailedPinyin(pinyin: pinyinToSearch, completionHandler: { (detailedPinyin, error) in
                DispatchQueue.main.async {
                    if (error == nil && detailedPinyin != nil && detailedPinyin!.identifier != -1) {
                        // found a pinyin, show it
                        self.pinyinDetailView.setFoundDetail(pinyin: detailedPinyin!)
                    } else { // cannot found a pinyin
                        if (self.selectedInitialIdx == self.noneSelectedIdx) {
                            // if initial is not selected, suggest user to select one more
                            self.pinyinDetailView.setNotFound(message: self.pinyinDetailReminderOneMore)
                        } else {
                            // if initial is selected, suggest user to change a group
                            self.pinyinDetailView.setNotFound(message: self.pinyinDetailReminderNotFound)
                        }
                    }
                }
            })
        }
    }
}
