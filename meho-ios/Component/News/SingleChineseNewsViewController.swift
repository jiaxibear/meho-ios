//
//  SingleChineseNewsViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/6/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class SingleChineseNewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NewsChapterCollectionViewCellDelegate {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(22)
    private let titleLableTopMargin = CGFloat(8) // marked as 18 to source subtitle, adjust as no navigationbar border
    private let titleLabelFontSize = CGFloat(24)
    private let chaptersToTitleMargin = CGFloat(18)


    // MARK: - Properties
    private let news: News

    // MARK: - UI
    private let titleEnLabel = UILabel.init(frame: .zero)
    private let titleZhLabel = UILabel.init(frame: .zero)
    private var chaptersCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var chaptersCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:chaptersCollectionViewFlowLayout)

    private let newsChapterCellReuseIdentifier = "zhNewsChapterCell"

    // MARK: - Datamodels
    private let dataFecther = NewsDataFetcher.init()
    private var zhChapters:[NewsChapter] = []

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitleLabel()
        setUpChapters()

        // Do any additional setup after loading the view.
        dataFecther.fetchNewsDetail(newsID: news.identifier, completionHandler: {
            (englishChapters, chineseChapters, error) in
            if (error == nil && chineseChapters != nil && englishChapters != nil) {
                DispatchQueue.main.async {
                    self.zhChapters = chineseChapters!
                    self.chaptersCollectionView.reloadData()
                }
            }
        })
    }
    
    // MARK: - Setup UI
    func setUpTitleLabel() {
        // Sets up the title.
        titleZhLabel.text = news.title_zh
        titleZhLabel.textColor = .black
        titleZhLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: titleLabelFontSize)
        titleZhLabel.numberOfLines = 3
        titleZhLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleZhLabel)

        titleEnLabel.text = news.title_en
        titleEnLabel.textColor = .black
        let languageToggleEnfontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleEnLabel.font = UIFont.init(descriptor: languageToggleEnfontDescriptor!, size: 0)
        titleEnLabel.numberOfLines = 3
        titleEnLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleEnLabel)


        // Sets up layout constrainsts.
        titleZhLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: trailingLeadingMargin).isActive = true
        titleZhLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailingLeadingMargin).isActive = true
        titleZhLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: titleLableTopMargin).isActive = true

        titleEnLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: trailingLeadingMargin).isActive = true
        titleEnLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailingLeadingMargin).isActive = true
        titleEnLabel.topAnchor.constraint(equalTo: titleZhLabel.bottomAnchor, constant: CGFloat(5)).isActive = true

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

        chaptersCollectionView.register(NewsChapterCollectionViewCell.self, forCellWithReuseIdentifier:newsChapterCellReuseIdentifier)
        view.addSubview(chaptersCollectionView)


        // view constraints
        chaptersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: trailingLeadingMargin).isActive = true
        chaptersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailingLeadingMargin).isActive = true
        chaptersCollectionView.topAnchor.constraint(equalTo: titleEnLabel.bottomAnchor, constant: chaptersToTitleMargin).isActive = true
        chaptersCollectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return zhChapters.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let chapter = zhChapters[indexPath.item]
        return CGSize(width: width, height: NewsChapterCollectionViewCell.cellHeight(with: width, newsChapter: chapter))

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let chapter = zhChapters[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsChapterCellReuseIdentifier, for: indexPath) as! NewsChapterCollectionViewCell
        cell.setNews(chapter)
        cell.setDelegate(delegate: self)
        return cell
    }

    // MARK: - NewsChapterCollectionViewCellDelegate
    func NewsChapterCollectionViewCellDidTapVocabulary(vocabulary: Vocabulary) {
        let vocabularyViewController = VocabularyViewController.init(vocabulary: Vocabulary.init())
        vocabularyViewController.modalPresentationStyle = .overFullScreen
        vocabularyViewController.modalTransitionStyle = .crossDissolve
        navigationController?.present(vocabularyViewController, animated: true, completion: nil)

    }

}
