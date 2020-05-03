//
//  SignInStoriesCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 5/2/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class SignInStoriesCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let imageCornerRadius = CGFloat(10)

    // MARK: - Properties
    private let storyImageView = UIImageView.init(frame: .zero)

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCellImageUI()
    }

    // MARK: - Elements layout, style & constrains
    private func setupCellImageUI() {
        let cellView = self.contentView
        storyImageView.translatesAutoresizingMaskIntoConstraints = false
        storyImageView.layer.cornerRadius = imageCornerRadius
        storyImageView.contentMode = .scaleAspectFill
        storyImageView.clipsToBounds = true
        cellView.addSubview(storyImageView)

        // constraints
        storyImageView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor).isActive = true
        storyImageView.trailingAnchor.constraint(equalTo: cellView.trailingAnchor).isActive = true
        storyImageView.topAnchor.constraint(equalTo: cellView.topAnchor).isActive = true
        storyImageView.bottomAnchor.constraint(equalTo: cellView.bottomAnchor).isActive = true
    }

    // MARK: - Public
    public func setStoryCardData(name: String) {
        let storyImage = UIImage.init(named: name)
        storyImageView.image = storyImage
    }
}
