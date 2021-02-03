//
//  NewsItemSizeLCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/3/20.
//  Copyright © 2020 Meho. All rights reserved.
//
import UIKit

protocol NewsItemSizeLCollectionViewCellDelegate: AnyObject {
    func didTapPlayAudioButton(news: News)
}

class NewsItemSizeLCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(20)
    private let titleLabelLeadingTrailingMargin = CGFloat(12)

    private let elementMargin = CGFloat(10)

    private let coverImageViewHeight = CGFloat(200)
    private let coverImageViewCornerRadius = CGFloat(8)
    private let playAudioButtonWidth = CGFloat(40)
    private let playAudioButtonHeight = CGFloat(40)

    // MARK: - Properties
    var news: News? {
        didSet {
            if let news = news {
                // Sets the text for the title label.
                titleLabel.text = news.title_en

                // Sets the reason text
                reasonView.setReasonText(text: news.reason)

                // Downloads the image.
                if let coverImageURL = news.coverImageURL {
                    coverImageView.imageURL = coverImageURL
                } else if let imageKey = news.imageKey {
                    coverImageView.imageKey = imageKey
                }

                if news.audioEnKey != nil || news.audioZhKey != nil {
                    playAudioButton.isHidden = false
                } else {
                    playAudioButton.isHidden = true
                }
                reasonStackViewHeightConstraint.constant = reasonStackViewHeight()
                setNeedsUpdateConstraints()
            }
        }
    }

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        if let labelfontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded) {
            titleLabel.font = UIFont.init(descriptor: labelfontDescriptor, size: titleLabelFontSize)
        }
        return titleLabel
    } ()

    private lazy var reasonView: NewsReasonView = {
        let reasonView = NewsReasonView.init(frame: .zero, yellowBar: false, darkMode: false)
        reasonView.translatesAutoresizingMaskIntoConstraints = false
        reasonView.backgroundColor = .white
        return reasonView
    } ()

    private lazy var coverImageView: WebImageView = {
        let coverImageView = WebImageView.init(frame: .zero)
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.layer.cornerRadius = coverImageViewCornerRadius
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        return coverImageView
    } ()

    private lazy var playAudioButton: UIButton = {
        let playAudioButton = UIButton.init(frame: .zero)
        playAudioButton.translatesAutoresizingMaskIntoConstraints = false
        let playAudioButtonImage = UIImage.init(named: "stories_purple_headphone_play")
        playAudioButton.setImage(playAudioButtonImage, for: .normal)
        playAudioButton.isHidden = true
        playAudioButton.addTarget(self, action: #selector(didTapPlayAudioButton), for: .touchUpInside)
        return playAudioButton
    } ()

    private lazy var reasonStackView: UIStackView = {
        let reasonStackView = UIStackView.init(arrangedSubviews: [reasonView, playAudioButton])
        reasonStackView.translatesAutoresizingMaskIntoConstraints = false
        reasonStackView.axis = .horizontal
        reasonStackView.alignment = .center
        reasonStackView.spacing = elementMargin
        return reasonStackView
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [coverImageView, titleLabel, reasonStackView])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .equalSpacing
        return contentStackView
    } ()

    private lazy var reasonStackViewHeightConstraint: NSLayoutConstraint = {
        return reasonStackView.heightAnchor.constraint(equalToConstant: 0)
    } ()

    weak var delegate: NewsItemSizeLCollectionViewCellDelegate?

    private static var sizingCell = NewsItemSizeLCollectionViewCell.init(frame: .zero);

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
        backgroundColor = .white

        contentView.addSubview(contentStackView)

        // Sets up constraints
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            coverImageView.heightAnchor.constraint(equalToConstant: coverImageViewHeight),

            playAudioButton.widthAnchor.constraint(equalToConstant: playAudioButtonWidth),
            playAudioButton.heightAnchor.constraint(equalToConstant: playAudioButtonHeight),
            reasonStackViewHeightConstraint
        ])
    }

    // MARK: - Private
    private func reasonStackViewHeight() -> CGFloat {
        var reasonLabelFittingWidth = contentView.bounds.width
        if !playAudioButton.isHidden {
            reasonLabelFittingWidth = reasonLabelFittingWidth - elementMargin - playAudioButtonWidth
        }
        let reasonLabelFittingSize = CGSize.init(width: reasonLabelFittingWidth, height: .greatestFiniteMagnitude)
        let reasonLabelHeight = reasonView.sizeThatFits(reasonLabelFittingSize).height
        if playAudioButton.isHidden {
            return reasonLabelHeight
        } else {
            return max(reasonLabelHeight, playAudioButtonHeight)
        }
    }

    @objc
    private func didTapPlayAudioButton() {
        if let news = news {
            delegate?.didTapPlayAudioButton(news: news)
        }
    }

    // MARK: - Public
    public class func cellHeight(with width: CGFloat, news: News) -> CGFloat {
        sizingCell.news = news
        let height = sizingCell.coverImageViewHeight
            + sizingCell.elementMargin
            + sizingCell.titleLabel.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
            + sizingCell.elementMargin
            + sizingCell.reasonStackViewHeight()
        return height
    }
}
