//
//  NewsListHeaderCollectionReusableView.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class NewsListHeaderCollectionReusableView: UICollectionReusableView {

    // MARK: - Constants
    private let titleBottomMargin = CGFloat(30)
    private let titleLabelFontSize = CGFloat(34)

    // MARK: - Properties
    private let titleView = MainTabTitleView.init(frame: .zero)
    private static var sizingView = NewsListHeaderCollectionReusableView.init(frame: .zero)

    private var title = ""

    // MARK: - Init
    @available(*, unavailable)
        init() {
        fatalError("Use init(frame: CGRect)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    override init(frame: CGRect) {
    super.init(frame: frame)
        setupTitleView()
    }

    private func setupTitleView() {
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.setTitleText(text: NSLocalizedString("NewsTitle", comment: ""))
        addSubview(titleView)


        // Sets up layout constrainsts.
        titleView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }

    public func setTitle(title: String) {
        titleView.setTitleText(text: title)
    }

    public class func heightForTitle(with width: CGFloat, title: String) -> CGFloat {
        sizingView.setTitle(title: title)
        let titleEnLabelHeight = sizingView.titleView.getViewHeight()
        return titleEnLabelHeight + sizingView.titleBottomMargin
    }
}
