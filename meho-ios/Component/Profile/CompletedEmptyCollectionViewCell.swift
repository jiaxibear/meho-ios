//
//  CompletedEmptyCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 12/27/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

protocol CompletedEmptyCollectionViewCellDelegate: AnyObject {
    func completedEmptyCollectionViewCellDidTapButton(navigation: CompletedNavigation)
}

struct CompletedNavigation {
    let category: ProfileContentCategory
    let subCategory: ProfileContentCategory?
}

class CompletedEmptyCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(14)
    private let titleLabelLeadingTrailingMargin = CGFloat(16)
    private let viewButtonHeight = CGFloat(36)
    private let viewButtonTopMargin = CGFloat(30)
    private let viewButtonTitleMargin = CGFloat(20)

    // MARK: - Models
    var completedNavigation: CompletedNavigation! {
        didSet {
            switch completedNavigation.category.categoryType {
            case .expression:
                if let subCategoryTitle = completedNavigation.subCategory?.title, subCategoryTitle != "All" {
                    let titleLabelTextFormat = NSLocalizedString("NoSavedExpressionsWithCategoryText", comment: "")
                    titleLabel.text = String.init(format: titleLabelTextFormat, subCategoryTitle)
                } else {
                    titleLabel.text = NSLocalizedString("NoSavedExpressionsText", comment: "")
                }
                break
            case .talk:
                if let subCategoryTitle = completedNavigation.subCategory?.title, subCategoryTitle != "All"  {
                    let titleLabelTextFormat = NSLocalizedString("NoSavedTalksWithCategoryText", comment: "")
                    titleLabel.text = String.init(format: titleLabelTextFormat, subCategoryTitle)
                } else {
                    titleLabel.text = NSLocalizedString("NoSavedTalksText", comment: "")
                }
                break
            case .story:
                titleLabel.text = NSLocalizedString("NoSavedStoriesText", comment: "")
                break
            case .all:
                assertionFailure()
                break
            }
            let viewButtonTitleFormat = NSLocalizedString("ViewButtonTitle", comment: "")
            viewButton.setTitle(String.init(format: viewButtonTitleFormat, completedNavigation.category.title), for: .normal)
            let viewButtonWidth = viewButton.sizeThatFits(CGSize.init(width: .greatestFiniteMagnitude, height: viewButtonHeight)).width + titleLabelLeadingTrailingMargin * 2
            viewButtonWidthConstraint.constant = viewButtonWidth
        }
    }

    // MARK: - Views
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .palePurple
        titleLabel.numberOfLines = 0
        if let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
            titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelFontSize)
        }
        return titleLabel
    } ()

    private lazy var viewButton: UIButton = {
        let viewButton = UIButton.init(frame: .zero)
        viewButton.translatesAutoresizingMaskIntoConstraints = false
        viewButton.backgroundColor = .skyBlue
        viewButton.setTitleColor(.white, for: .normal)
        viewButton.layer.cornerRadius = viewButtonHeight / 2
        viewButton.clipsToBounds = true
        return viewButton
    } ()

    private lazy var viewButtonWidthConstraint: NSLayoutConstraint = {
        return viewButton.widthAnchor.constraint(equalToConstant: 0)
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(viewButton)

        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: titleLabelLeadingTrailingMargin).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -titleLabelLeadingTrailingMargin).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

        viewButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: viewButtonTopMargin).isActive = true
        viewButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        viewButton.heightAnchor.constraint(equalToConstant: viewButtonHeight).isActive = true
        viewButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        viewButtonWidthConstraint.isActive = true
    }
}
