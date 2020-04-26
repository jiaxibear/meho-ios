//
//  ExpressionViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 4/5/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ExpressionViewController: UIViewController {

    // MARK: - Constants
    private let expressionTabBarItemImageName = "tabbar_expression_25pt"
    private let foundationCoverTitle = "Expressions"
    private let titleLabelFontSize = CGFloat(34)

    private let titleLabelLeadingMargin = CGFloat(15)
    private let titleLabelTopMargin = CGFloat(30)

    // MARK: - Properties
    private let titleView = MainTabTitleView.init(frame: .zero)


    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let expressionTabBarItemImage = UIImage.init(named: expressionTabBarItemImageName)
        let expressionTabBarItem = UITabBarItem.init(title: nil, image: expressionTabBarItemImage, tag: 0)
        tabBarItem = expressionTabBarItem
        view.backgroundColor = .white
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupTitleView()
    }

    func setupTitleView() {
        let margins = self.view.layoutMarginsGuide
        titleView.setTitleText(text: foundationCoverTitle)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)

        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: titleLabelLeadingMargin).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -titleLabelLeadingMargin).isActive = true
        titleView.topAnchor.constraint(equalTo: margins.topAnchor, constant: titleLabelTopMargin).isActive = true
//        titleView.heightAnchor.constraint(equalToConstant: titleView.getViewHeight()).isActive = true
    }
}
