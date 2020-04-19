//
//  PinyinFinalCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/19/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class PinyinFinalCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let cardRadius = CGFloat(10)
    private let cardBorderwidth = CGFloat(2)
    private let labelFontSize = CGFloat(15)
    // MARK: - Properties
    private let finalLabel = UILabel.init(frame: .zero)

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
        contentView.layer.cornerRadius = cardRadius
        contentView.layer.borderWidth = cardBorderwidth
        contentView.layer.borderColor = UIColor.skyBlue.cgColor
        contentView.clipsToBounds = true
        finalLabel.translatesAutoresizingMaskIntoConstraints = false
        finalLabel.textAlignment = .center
        finalLabel.textColor = .black
        let topLabelFontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        finalLabel.font = UIFont.init(descriptor: topLabelFontDescriptor!, size: 0)
        contentView.addSubview(finalLabel)

        finalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        finalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        finalLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        finalLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    public func setCell(final: String) {
        finalLabel.text = final
    }

    public func selectCell() {
        contentView.backgroundColor = .skyBlue
        finalLabel.textColor = .white
    }

    public func unSelectCell() {
        contentView.backgroundColor = .white
        finalLabel.textColor = .black
    }

    public func getCellLabel() -> String {
        return finalLabel.text!
    }
}
