//
//  NewsViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(15)
    private let titleLabelFontSize = CGFloat(34)
    private let newsTabBarItemImageName = "tabbar_news_25pt"

    private let newsCollectionViewCellHeight = CGFloat(110)
    private let newsCollectionViewCellGroupSpacing = CGFloat(20)

    private let newsCollectionHorizontalMargin = CGFloat(15)
    private let newsCollectionTopMargin = CGFloat(30)


    // MARK: UI
    private let titleLabel = UILabel.init(frame: .zero)
    private var newsCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var newsCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:newsCollectionViewFlowLayout)

    private let newsItemSizeXLCellReuseIdentifier = "NewsItemSizeXL"
    private let newsItemSizeLCellReuseIdentifier = "NewsItemSizeL"
    private let newsItemSizeSCellReuseIdentifier = "NewsItemSizeS"
    private let newsItemSizeXSCellReuseIdentifier = "NewsItemSizeXS"

    // MARK: - Datamodels
    private let dataFecther = NewsDataFetcher.init()
    private var newsList:[News] = []

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let newsTabBarItemImage = UIImage.init(named: newsTabBarItemImageName)
        let newsTabBarItem = UITabBarItem.init(title: nil, image: newsTabBarItemImage, tag: 0)
        tabBarItem = newsTabBarItem
    }


    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        let margins = view.layoutMarginsGuide

        // Sets up the title.
        titleLabel.text = NSLocalizedString("NewsTitle", comment: "")
        titleLabel.textColor = .wisteriaPurple
        let fontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Sets up news collection.

        newsCollectionView.dataSource = self
        newsCollectionView.delegate = self
        newsCollectionView.backgroundColor = .white
        newsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        newsCollectionView.showsVerticalScrollIndicator = false
        newsCollectionView.contentInset = .zero

        // collection layout
        newsCollectionViewFlowLayout.scrollDirection = .vertical
        newsCollectionViewFlowLayout.minimumLineSpacing = 30

        newsCollectionView.register(NewsItemSizeXLCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeXLCellReuseIdentifier)
        newsCollectionView.register(NewsItemSizeLCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeLCellReuseIdentifier)
        newsCollectionView.register(NewsItemSizeSCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeSCellReuseIdentifier)
        newsCollectionView.register(NewsItemSizeXSCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeXSCellReuseIdentifier)
        view.addSubview(newsCollectionView)



        // Sets up layout constrainsts.
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: trailingLeadingMargin).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailingLeadingMargin).isActive = true
        titleLabel.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true

        // view constraints
        newsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: newsCollectionHorizontalMargin).isActive = true
        newsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -newsCollectionHorizontalMargin).isActive = true
        newsCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: newsCollectionTopMargin).isActive = true
        newsCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true

        dataFecther.fetchNewsList { (newsList, error) in
            if (error == nil && newsList != nil) {
                DispatchQueue.main.async {
                    self.newsList = newsList!
                    self.newsCollectionView.reloadData()
                }
            }
        }
    }


    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsList.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let newsItem = newsList[indexPath.item]
        switch chooseRenterType(news:newsItem) {
        case "XL":
            return CGSize(width: width, height: NewsItemSizeXLCollectionViewCell.cellHeight(with: width, news: newsItem))
        case "L":
            return CGSize(width: width, height: NewsItemSizeLCollectionViewCell.cellHeight(with: width, news: newsItem))
        case "S":
            return CGSize(width: width, height: NewsItemSizeSCollectionViewCell.cellHeight(with: width, news: newsItem))
        case "XS":
            return CGSize(width: width, height: NewsItemSizeXSCollectionViewCell.cellHeight(with: width, news: newsItem))
        default:
            return CGSize(width: width, height: 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let newsItem = newsList[indexPath.item]
        switch chooseRenterType(news:newsItem) {
        case "XL":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsItemSizeXLCellReuseIdentifier, for: indexPath) as! NewsItemSizeXLCollectionViewCell
            cell.setNews(newsItem)
            return cell
        case "L":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsItemSizeLCellReuseIdentifier, for: indexPath) as! NewsItemSizeLCollectionViewCell
            cell.setNews(newsItem)
            return cell
        case "S":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsItemSizeSCellReuseIdentifier, for: indexPath) as! NewsItemSizeSCollectionViewCell
            cell.setNews(newsItem)
            return cell
        case "XS":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsItemSizeXSCellReuseIdentifier, for: indexPath) as! NewsItemSizeXSCollectionViewCell
            cell.setNews(newsItem)
            return cell
        default:
            return UICollectionViewCell.init()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newsItem = newsList[indexPath.item]
        let detailedNewsViewController = DetailedNewsViewController.init(news: newsItem)
        navigationController?.pushViewController(detailedNewsViewController, animated: true)

    }

    // rendertype is returned as one of [XS, S, L, XL], usually we respect it. S, L, XL all come with images while XS don't.  If one news is not marked XS but still does not come with image, we should still degrade to XS
    func chooseRenterType(news: News) -> String {
        return news.coverImageURL == nil ? "XS" : news.renderType
    }
}
