//
//  SingleEnglishNewsViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/5/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class SingleEnglishNewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(22)
    private let titleLableTopMargin = CGFloat(8) // marked as 18 to source subtitle, adjust as no navigationbar border
    private let titleLabelFontSize = CGFloat(24)
    private let chaptersToTitleMargin = CGFloat(18)

    // MARK: - Properties
    private let news: News

    // MARK: - UI
    private let titleLabel = UILabel.init(frame: .zero)
    private var chaptersCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var chaptersCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:chaptersCollectionViewFlowLayout)

    private let newsChapterCellReuseIdentifier = "enNewsChapterCell"

    // MARK: - Datamodels
    private let dataFecther = NewsDataFetcher.init()
    private var enChapters:[NewsChapter] = []

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
                    self.enChapters = englishChapters!
                    self.chaptersCollectionView.reloadData()
                }
            }
        })
    }

    // MARK: - Setup UI
    func setUpTitleLabel() {
        // Sets up the title.
        titleLabel.text = news.title_en
        titleLabel.textColor = .black
        let fontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)


        // Sets up layout constrainsts.
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: trailingLeadingMargin).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailingLeadingMargin).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: titleLableTopMargin).isActive = true
    }

    func setUpChapters() {
        chaptersCollectionView.dataSource = self
        chaptersCollectionView.delegate = self
        chaptersCollectionView.backgroundColor = .white
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
        chaptersCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: chaptersToTitleMargin).isActive = true
        chaptersCollectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return enChapters.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let chapter = enChapters[indexPath.item]
        return CGSize(width: width, height: NewsChapterCollectionViewCell.cellHeight(with: width, newsChapter: chapter))

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let chapter = enChapters[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsChapterCellReuseIdentifier, for: indexPath) as! NewsChapterCollectionViewCell
        cell.setNews(chapter)
        return cell
    }

}
