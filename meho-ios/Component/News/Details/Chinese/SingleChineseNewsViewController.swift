//
//  SingleChineseNewsViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/6/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

enum ChineseNewsSection: Int {
    case newsChapters
    case vocabularyList
}

class SingleChineseNewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NewsChapterCollectionViewCellDelegate {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(22)
    private let titleLableTopMargin = CGFloat(8) // marked as 18 to source subtitle, adjust as no navigationbar border
    private let titleLabelFontSize = CGFloat(24)
    private let chaptersToTitleMargin = CGFloat(18)
    private let recapListTitle = "Recap key vocabulary"
    private let sectionVerticalInsets = CGFloat(30)


    // MARK: - Properties
    private let news: News
    private var hasFetchedNewsDetail = false
    private var hasFetchedVocabularies = false

    // MARK: - UI
    private var chaptersCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var chaptersCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:chaptersCollectionViewFlowLayout)

    private let newsTitleHeaderCellReuseIdentifier = "zhNewsTitleHeader"
    private let newsChapterCellReuseIdentifier = "zhNewsChapterCell"
    private let vocabularyRecapHeaderCellReuseIdentifier = "newVocabularyRecapHeader"
    private let newsRecapVocabularyCellReuseIdentifier = "newsVocabularyCell"
    private let newsRecapFooterCellReuseIdentifier = "newsRecapFooter"

    // MARK: - Datamodels
    private let dataFetcher = NewsDataFetcher.init()
    private var newsChapters:[NewsChapter] = []
    private var vocabularyList:[Vocabulary] = []
    private var sections:[ChineseNewsSection] = []

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

    init(news: News) {
        self.news = news
        super.init(nibName: nil, bundle: nil)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpChapters()

        // Do any additional setup after loading the view.
        dataFetcher.fetchNewsDetail(newsID: news.identifier, completionHandler: {
            (englishChapters, chineseChapters, error) in
            if (error == nil && chineseChapters != nil && englishChapters != nil) {
                DispatchQueue.main.async {
                    self.newsChapters = chineseChapters!
                    self.hasFetchedNewsDetail = true
                    self.tryReloadCollectionView()
                }
            }
        })

        dataFetcher.fetchRecapVocabularies(completionHandler: {
            (recapVocabularies, error) in
            if (error == nil && recapVocabularies != nil) {
                DispatchQueue.main.async {
                    self.vocabularyList = recapVocabularies!
                    self.hasFetchedVocabularies = true
                    self.tryReloadCollectionView()
                }
            }
        })

    }

    func setUpChapters() {
        chaptersCollectionView.dataSource = self
        chaptersCollectionView.delegate = self
        chaptersCollectionView.backgroundColor = .clear
        chaptersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        chaptersCollectionView.showsVerticalScrollIndicator = false
        chaptersCollectionView.contentInset = .zero

        // collection layout
        chaptersCollectionViewFlowLayout.scrollDirection = .vertical
        chaptersCollectionViewFlowLayout.minimumLineSpacing = 18
        chaptersCollectionViewFlowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: sectionVerticalInsets, right: 0)

        chaptersCollectionView.register(TwoLineTitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: newsTitleHeaderCellReuseIdentifier)
        chaptersCollectionView.register(NewsChapterCollectionViewCell.self, forCellWithReuseIdentifier:newsChapterCellReuseIdentifier)

        chaptersCollectionView.register(OneLineTitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: vocabularyRecapHeaderCellReuseIdentifier)
        chaptersCollectionView.register(NewsRecapVocabularyCollectionViewCell.self, forCellWithReuseIdentifier: newsRecapVocabularyCellReuseIdentifier)

        chaptersCollectionView.register(NewsRecapFooterCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: newsRecapFooterCellReuseIdentifier)


        view.addSubview(chaptersCollectionView)


        // view constraints
        chaptersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: trailingLeadingMargin).isActive = true
        chaptersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailingLeadingMargin).isActive = true
        chaptersCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        chaptersCollectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section == 0 {
                if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: newsTitleHeaderCellReuseIdentifier, for: indexPath) as? TwoLineTitleHeaderCollectionReusableView {
                    headerView.setTitle(titleEn: news.title_en, titleZh: news.title_zh)
                    return headerView
                }
            } else if indexPath.section == 1 {
                if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: vocabularyRecapHeaderCellReuseIdentifier, for: indexPath) as? OneLineTitleHeaderCollectionReusableView {
                    headerView.setTitle(title: recapListTitle)
                    return headerView
                }
            }
        } else if kind == UICollectionView.elementKindSectionFooter {
            if indexPath.section == 1 {
                if let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: newsRecapFooterCellReuseIdentifier, for: indexPath) as? NewsRecapFooterCollectionReusableView {
                    return footerView
                }
            }
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize.init(width: 0, height: TwoLineTitleHeaderCollectionReusableView.heightForTitle(with :collectionView.contentSize.width, titleEn: news.title_en, titleZh: news.title_zh))
        } else { // assuming only two sections!
            return CGSize.init(width: 0, height: OneLineTitleHeaderCollectionReusableView.heightForTitle(with :collectionView.contentSize.width, title: news.title_en))
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 1 {
            return CGSize.init(width: 0, height: NewsRecapFooterCollectionReusableView.cellHeight(with :collectionView.contentSize.width))
        } else { // assuming only two sections!
            return CGSize.init(width: 0, height: 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let detailedNewsSections = sections[section]
        switch detailedNewsSections {
        case .newsChapters:
            return newsChapters.count
        case .vocabularyList:
            return vocabularyList.count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let detailedNewsSections = sections[indexPath.section]
        switch detailedNewsSections {
        case .newsChapters:
            let width = collectionView.bounds.width
            let chapter = newsChapters[indexPath.item]
            return CGSize(width: width, height: NewsChapterCollectionViewCell.cellHeight(with: width, newsChapter: chapter))
        case .vocabularyList:
            let width = collectionView.bounds.width
            let vocabulary = vocabularyList[indexPath.item]
            return CGSize(width: width, height: NewsRecapVocabularyCollectionViewCell.cellHeight(with: width, vocabulary: vocabulary))
        }

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let detailedNewsSections = sections[indexPath.section]
        switch detailedNewsSections {
        case .newsChapters:
            let chapter = newsChapters[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsChapterCellReuseIdentifier, for: indexPath) as! NewsChapterCollectionViewCell
            cell.setNewsChapter(chapter)
            cell.setDelegate(delegate: self)
            return cell
        case .vocabularyList:
            let vocabulary = vocabularyList[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsRecapVocabularyCellReuseIdentifier, for: indexPath) as! NewsRecapVocabularyCollectionViewCell
            cell.setVocabulary(vocabulary)
            return cell
        }
    }

    // MARK: - NewsChapterCollectionViewCellDelegate
    func NewsChapterCollectionViewCellDidTapVocabulary(vocabularyId: String) {

        dataFetcher.fetchVocabulary (vocabularyId: vocabularyId, completionHandler: { (vocabulary, error) in
            DispatchQueue.main.async {
                if (error == nil && vocabulary != nil) {
                    let vocabularyViewController = VocabularyViewController.init(vocabulary: vocabulary!)
                    vocabularyViewController.modalPresentationStyle = .overFullScreen
                    vocabularyViewController.modalTransitionStyle = .crossDissolve
                    self.navigationController?.present(vocabularyViewController, animated: true, completion: nil)
                }
            }
        })
    }


    func tryReloadCollectionView() {
        if !(hasFetchedVocabularies && hasFetchedNewsDetail) {
            return;
        }
        sections.insert(.newsChapters, at: 0)
        sections.insert(.vocabularyList, at: 1)
        chaptersCollectionView.reloadData()
    }
}
