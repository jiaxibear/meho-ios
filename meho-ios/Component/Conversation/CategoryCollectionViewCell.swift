//
//  CategoryCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 2/9/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)
    
    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(titleLabel)
        let margins = self.contentView.layoutMarginsGuide
        titleLabel.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }
    
    // MARK: - Public
    public func setCategory(category: Category) {
        titleLabel.text = category.title
        titleLabel.sizeToFit()
    }
}
