//
//  SignInStoriesCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 5/2/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class MehoCoverIntroCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let imageCornerRadius = CGFloat(10)
    private let titleLabelFontSize = CGFloat(30)

    // MARK: - Properties
    private lazy var storyImageView:UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = imageCornerRadius
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        return imageView
    } ()

    private lazy var titleLabel:UILabel = {
        let label = UILabel.init(frame: .zero)
        label.textColor = .wisteriaPurple
        label.textAlignment = .center
        label.backgroundColor = .white
        let fontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        label.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    } ()

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
        setupTitleLabel()
        setupCellImageUI()
    }

    // MARK: - Elements layout, style & constrains

    private func setupTitleLabel() {
        contentView.addSubview(titleLabel)
        let cellHeight = contentView.bounds.height
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: cellHeight / 6).isActive = true
    }

    private func setupCellImageUI() {
        contentView.addSubview(storyImageView)

        // constraints
        storyImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        storyImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        storyImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        storyImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    // MARK: - Public
    public func setStoryCardData(name: String) {
        let storyImage = UIImage.init(named: name)
        storyImageView.image = storyImage
        if name == "meho_cover_stories" {
            titleLabel.text = "Meho Stories"
        } else if name == "meho_cover_expressions" {
            titleLabel.text = "Meho Expressions"
        } else {
            titleLabel.text = "Meho Talk"
        }

    }
}
