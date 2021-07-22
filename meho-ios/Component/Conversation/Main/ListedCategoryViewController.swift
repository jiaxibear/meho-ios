//
//  ListedCategoryViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 11/15/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ListedCategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NewsPlayingNow, NewsPlayingNowViewDelegate {

    private let normalCategoryListCardHeight = CGFloat(60)
    private let featuredCategoryListCardHeight = CGFloat(124)
    private let contentLeadingTrailingMargin = CGFloat(16)

    private lazy var listedCategoriesCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let listedCategoriesCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        listedCategoriesCollectionViewFlowLayout.scrollDirection = .vertical
        listedCategoriesCollectionViewFlowLayout.minimumLineSpacing = contentLeadingTrailingMargin
        return listedCategoriesCollectionViewFlowLayout
    } ()

    private lazy var listedCategoriesCollectionView: UICollectionView = {
        let listedCategoriesCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:listedCategoriesCollectionViewFlowLayout)
        listedCategoriesCollectionView.dataSource = self
        listedCategoriesCollectionView.delegate = self
        listedCategoriesCollectionView.backgroundColor = .white
        listedCategoriesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        listedCategoriesCollectionView.showsVerticalScrollIndicator = false
        listedCategoriesCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: 2, bottom: 0, right: 2)
        listedCategoriesCollectionView.register(ListedNormalCategoryCollectionViewCell.self, forCellWithReuseIdentifier:listedCategoryCellIdentifier)
        listedCategoriesCollectionView.register(ListedFeaturedCategoryCollectionViewCell.self, forCellWithReuseIdentifier:featuredCategoryCellIdentifier)
        return listedCategoriesCollectionView
    } ()

    private let listedCategoryCellIdentifier = "listedCategory"
    private let featuredCategoryCellIdentifier = "featuredCategory"

    // MARK: - Datamodels
    private let dataFecther = ConversationDataFetcher.init()
    private var categories:[Category] = []

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.backgroundColor = .white
        title = ""

        setuplistedCategoryCollectionView()

        dataFecther.fetchCategories(maybeLimit: nil, completionHandler: { (categories, error) in
            if (error == nil && categories != nil) {
                DispatchQueue.main.async {
                    self.categories = categories!
                    self.listedCategoriesCollectionView.reloadData()
                }
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newsAudioPlayer = NewsAudioPlayer.shared
        if newsAudioPlayer.status != .notStarted, let newsPlayingNowView = newsAudioPlayer.newsPlayingNowView {
            displayNewsPlayingNowView(newsPlayingNowView)
        }
    }

    func setuplistedCategoryCollectionView() {
        view.addSubview(listedCategoriesCollectionView)

        NSLayoutConstraint.activate([
            listedCategoriesCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            listedCategoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentLeadingTrailingMargin),
            listedCategoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentLeadingTrailingMargin),
            listedCategoriesCollectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - collectionView.contentInset.left + collectionView.contentInset.right
        let category = categories[indexPath.item]
        if category.isFeatured {
            return CGSize(width: width, height: featuredCategoryListCardHeight)
        } else {
            let nonFeaturedWidth = (width - contentLeadingTrailingMargin) / 2
            return CGSize(width: nonFeaturedWidth, height: normalCategoryListCardHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = categories[indexPath.item]
        if category.isFeatured {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:featuredCategoryCellIdentifier, for: indexPath) as! ListedFeaturedCategoryCollectionViewCell
            cell.setCategory(category: category)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:listedCategoryCellIdentifier, for: indexPath) as! ListedNormalCategoryCollectionViewCell
            cell.setCategory(category: category)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        let dialogStreamViewController = DialogStreamViewController.init(category: category)
        navigationController?.pushViewController(dialogStreamViewController, animated: true)
    }

    // MARK: - NewsPlayingNow
    func displayNewsPlayingNowView(_ newsPlayingNowView: NewsPlayingNowView) {
        if newsPlayingNowView.superview != nil {
            newsPlayingNowView.removeFromSuperview()
        }
        newsPlayingNowView.delegate = self

        view.addSubview(newsPlayingNowView)
        var contentInset = listedCategoriesCollectionView.contentInset
        contentInset.bottom = newsPlayingNowView.intrinsicContentSize.height
        listedCategoriesCollectionView.contentInset = contentInset
        NSLayoutConstraint.activate([
            newsPlayingNowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsPlayingNowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsPlayingNowView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - NewsPlayingNowViewDelegate
    func didTapCancelButton() {
        var contentInset = listedCategoriesCollectionView.contentInset
        contentInset.bottom = 0
        listedCategoriesCollectionView.contentInset = contentInset
    }
}
