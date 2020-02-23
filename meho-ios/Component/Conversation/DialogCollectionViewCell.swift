//
//  DialogCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 2/15/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class DialogCollectionViewCell: UICollectionViewCell, WebImageViewDelegate {
    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(18)
    private let titleLabelToCoverImageViewMargin = CGFloat(38)
    private let titleLabelTotitleInLocalLanguageLabelMargin = CGFloat(15)
    private let titleInLocalLanguageLabelFontSize = CGFloat(15)
    private let coverImageViewCornerRadius = CGFloat(2)
    private let coverImageViewWidth = CGFloat(60)
    private let coverImageViewHeight = CGFloat(60)
    private let coverImageTrailingMargin = CGFloat(25)
    private let cornerRadius = CGFloat(10)

    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)
    private let titleInLocalLanguageLabel = UILabel.init(frame: .zero)
    private let coverImageView = WebImageView.init(frame: .zero)

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius

        // Sets up cover image view.
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.layer.cornerRadius = coverImageViewCornerRadius
        coverImageView.clipsToBounds = true
        coverImageView.delegate = self
        self.contentView.addSubview(coverImageView)

        // Sets up title label.
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        titleLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: titleLabelFontSize)
        self.contentView.addSubview(titleLabel)

        // Sets up title in local language label.
        titleInLocalLanguageLabel.numberOfLines = 1
        titleInLocalLanguageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInLocalLanguageLabel.textColor = .textBlueGray
        titleInLocalLanguageLabel.font = UIFont.init(name: "AvenirNext-DemiBold", size: titleInLocalLanguageLabelFontSize)
        self.contentView.addSubview(titleInLocalLanguageLabel)

        // Sets up constraints
        let margins = self.contentView.layoutMarginsGuide
        coverImageView.widthAnchor.constraint(equalToConstant: coverImageViewWidth).isActive = true
        coverImageView.heightAnchor.constraint(equalToConstant: coverImageViewHeight).isActive = true
        coverImageView.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:coverImageTrailingMargin).isActive = true

        titleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: titleLabelToCoverImageViewMargin).isActive = true
        titleLabel.topAnchor.constraint(equalTo: coverImageView.topAnchor).isActive = true

        titleInLocalLanguageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        titleInLocalLanguageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: titleLabelTotitleInLocalLanguageLabelMargin).isActive = true

        self.contentView.isHidden = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame: CGRect)")
    }

    // MARK - WebImageViewDelegate
    func webImageViewDidSetImage(webImageView: WebImageView) {
        self.contentView.isHidden = false
    }

    // MARK: - Public
    public func setDialog(dialog: Dialog) {
        // Sets the text for the title label.
        titleLabel.text = dialog.title
        titleLabel.sizeToFit()
        titleInLocalLanguageLabel.text = dialog.titleInLocalLanguage
        titleInLocalLanguageLabel.sizeToFit()

        // Downloads the image.
        if let coverImageURL = dialog.coverImageURL {
            coverImageView.imageURL = coverImageURL
        }
    }
}
