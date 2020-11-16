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
    private let titleLabelLeadingTrailingMargin = CGFloat(15)
    private let titleLabelTopMargin = CGFloat(10)
    private let titleLabelTotitleInLocalLanguageLabelMargin = CGFloat(15)
    private let titleInLocalLanguageLabelFontSize = CGFloat(15)
    private let coverImageViewCornerRadius = CGFloat(4)
    private let coverImageViewWidth = CGFloat(110)
    private let coverImageTrailingMargin = CGFloat(25)
    private let coverImageBorderWidth = CGFloat(1)
    private let arrowImageViewWidth = CGFloat(45)
    private let arrowImageViewHeight = CGFloat(45)
    private let arrowImageName = "conversation_arrow_in_circle"
    private let difficultyLabelCornerRadius = CGFloat(2)
    private let difficultyLabelWidth = CGFloat(66)
    private let difficultyLabelHeight = CGFloat(20)
    private let difficultyLabelTopMargin = CGFloat(2)
    private let difficultyLabelFontSize = CGFloat(10)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        titleLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: titleLabelFontSize)
        return titleLabel
    } ()

    private lazy var titleInLocalLanguageLabel: UILabel = {
        let titleInLocalLanguageLabel = UILabel.init(frame: .zero)
        titleInLocalLanguageLabel.numberOfLines = 2
        titleInLocalLanguageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInLocalLanguageLabel.textColor = .textBlueGray
        let titleInLocalLanguageFontDescriptor = UIFont.systemFont(ofSize: titleInLocalLanguageLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleInLocalLanguageLabel.font = UIFont.init(descriptor: titleInLocalLanguageFontDescriptor!, size: titleInLocalLanguageLabelFontSize)
        return titleInLocalLanguageLabel
    } ()

    private lazy var coverImageView: WebImageView = {
        let coverImageView = WebImageView.init(frame: .zero)
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.layer.cornerRadius = coverImageViewCornerRadius
        coverImageView.layer.borderWidth = coverImageBorderWidth
        coverImageView.layer.borderColor = UIColor.borderGray.cgColor
        coverImageView.clipsToBounds = true
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.delegate = self
        return coverImageView
    } ()

    private lazy var arrowImageView: UIImageView = {
        let arrowImage = UIImage.init(named: arrowImageName)
        let arrowImageView = UIImageView.init(image: arrowImage)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        return arrowImageView
    } ()

    private lazy var difficultyLabel: UILabel = {
        let difficultyLabel = UILabel.init(frame: .zero)
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        difficultyLabel.clipsToBounds = true
        difficultyLabel.layer.cornerRadius = difficultyLabelCornerRadius
        difficultyLabel.textColor = .white
        difficultyLabel.textAlignment = .center
        let difficultyLabelFontDescriptor = UIFont.systemFont(ofSize: difficultyLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        difficultyLabel.font = UIFont.init(descriptor: difficultyLabelFontDescriptor!, size: difficultyLabelFontSize)
        return difficultyLabel
    } ()

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleInLocalLanguageLabel)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(difficultyLabel)

        // Sets up constraints
        coverImageView.widthAnchor.constraint(equalToConstant: coverImageViewWidth).isActive = true
        coverImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

        difficultyLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: titleLabelLeadingTrailingMargin).isActive = true
        difficultyLabel.topAnchor.constraint(equalTo: coverImageView.topAnchor, constant: difficultyLabelTopMargin).isActive = true
        difficultyLabel.widthAnchor.constraint(equalToConstant: difficultyLabelWidth).isActive = true
        difficultyLabel.heightAnchor.constraint(equalToConstant: difficultyLabelHeight).isActive = true

        titleLabel.leadingAnchor.constraint(equalTo: difficultyLabel.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: titleLabelTopMargin).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -titleLabelLeadingTrailingMargin).isActive = true

        titleInLocalLanguageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        titleInLocalLanguageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: titleLabelTotitleInLocalLanguageLabelMargin).isActive = true
        titleInLocalLanguageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true

        arrowImageView.widthAnchor.constraint(equalToConstant: arrowImageViewWidth).isActive = true
        arrowImageView.heightAnchor.constraint(equalToConstant: arrowImageViewHeight).isActive = true
        arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        contentView.isHidden = true
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
    public func setDialog(_ dialog: Dialog) {
        // Sets the text for the title label.
        titleLabel.text = dialog.title
        titleInLocalLanguageLabel.text = dialog.titleInLocalLanguage

        // Downloads the image.
        if let coverImageURL = dialog.coverImageURL {
            coverImageView.imageURL = coverImageURL
        } else if let imageKey = dialog.coverImageKey {
            let s3Key = S3ImageViewKey.init(bucket: "mehoassets213338-mehoadmin", key: imageKey)
            coverImageView.imageKey = s3Key
        }

        difficultyLabel.text = dialog.difficulty.title.uppercased()
        switch dialog.difficulty.identifier {
        case .advanced:
            difficultyLabel.backgroundColor = .skyBlue
            break
        case .intermediate:
            difficultyLabel.backgroundColor = .greenBlue
            break
        case .beginner:
            difficultyLabel.backgroundColor = .wisteriaPurple
            break
        }
    }
}
