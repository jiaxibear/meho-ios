//
//  PictographCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class PictographCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let descriptionTopMargin = CGFloat(13)
    private let cardCornerRadius = CGFloat(10)
    private let gifHorizontalMarginPercent = CGFloat(0.08)

    private let cardBackgroundImageName = "foundation_pictograph_card_background"
    private let cardBackgroundReversedImageName = "foundation_pictograph_card_background_reversed"

    // MARK: - Properties
    private let contentEnLabel = UILabel.init(frame: .zero)
    private let contentPinyinLabel = UILabel.init(frame: .zero)
    private let cardBackgroundImageView = UIImageView.init(frame: .zero)
    private let gifImageView = UIImageView.init(frame: .zero)
    private let enToPinyinDict:Dictionary<String, String> = ["fire":"huǒ", "wood":"mù", "mouth":"kǒu", "mountain":"shān", "human":"rén", "field":"tián", "cloud":"yún", "rain":"yǔ", "eye":"yǎn", "door":"mén", "fish":"yú", "earth":"tǔ", "hand":"shǒu", "goat":"yáng", "bird":"niǎo", "water":"shuǐ", "moon":"yuè", "sun":"rì"]

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
        // Sets up elements in the cell
        setupBackgroundImage()
        setupContentPinyinLabelUI()
        setupContentEnLabelUI()
        setupGifView()
    }

    private func setupBackgroundImage() {
        cardBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        cardBackgroundImageView.layer.cornerRadius = cardCornerRadius
        cardBackgroundImageView.clipsToBounds = true
        contentView.addSubview(cardBackgroundImageView)

        // constraints
        cardBackgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        cardBackgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        cardBackgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        cardBackgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    private func setupContentEnLabelUI() {
        contentEnLabel.numberOfLines = 1
        contentEnLabel.translatesAutoresizingMaskIntoConstraints = false
        contentEnLabel.textColor = .white
        contentEnLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(36))
        contentView.addSubview(contentEnLabel)

        // constraints
        contentEnLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        contentEnLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.bounds.height * 0.25).isActive = true
    }

    private func setupContentPinyinLabelUI() {
        contentPinyinLabel.numberOfLines = 1
        contentPinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        contentPinyinLabel.textColor = .white
        contentPinyinLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(50))
        contentView.addSubview(contentPinyinLabel)

        // constraints
        contentPinyinLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        contentPinyinLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.bounds.height * 0.1).isActive = true
    }

    private func setupGifView() {
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        gifImageView.layer.cornerRadius = cardCornerRadius
        gifImageView.clipsToBounds = true
        contentView.addSubview(gifImageView)
        let cellWidth = contentView.bounds.width

        gifImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        gifImageView.widthAnchor.constraint(equalToConstant: cellWidth * (1 - 2 * gifHorizontalMarginPercent)).isActive = true
        gifImageView.heightAnchor.constraint(equalToConstant: cellWidth * (1 - 2 * gifHorizontalMarginPercent)).isActive = true
        gifImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -cellWidth * gifHorizontalMarginPercent).isActive = true
    }

    // MARK: - Public
    public func setPictographCardData(pictograph: Pictograph, shouldReverse: Bool) {
        let enLabelText = pictograph.content_en.lowercased()
        contentEnLabel.text = enLabelText
        if let pinyinLabelText = self.enToPinyinDict[enLabelText] {
            contentPinyinLabel.text = pinyinLabelText
        } else {
            contentPinyinLabel.text = ""
        }

        contentEnLabel.textColor = .white

        let selectedCardBackgroundImageName = shouldReverse
            ? cardBackgroundReversedImageName : cardBackgroundImageName
        let cardBackgroundImage = UIImage.init(named: selectedCardBackgroundImageName)
        cardBackgroundImageView.image = cardBackgroundImage

        if let gifImageURL = pictograph.gifImageURL {
            gifImageView.loadGifFromURL(gifImageURL)
        }
    }
}
