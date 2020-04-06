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
    let expressionTabBarItemImageName = "tabbar_expression_25pt"

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
}
