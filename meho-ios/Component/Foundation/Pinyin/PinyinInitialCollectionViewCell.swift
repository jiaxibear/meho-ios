//
//  PinyinInitialCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/18/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class PinyinInitialCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let cardRadius = CGFloat(10)
    private let cardBorderwidth = CGFloat(2)
    private let labelFontSize = CGFloat(15)
    // MARK: - Properties
    private let initialLabel = UILabel.init(frame: .zero)

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
        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        initialLabel.textAlignment = .center
        initialLabel.textColor = .black
        let topLabelFontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        initialLabel.font = UIFont.init(descriptor: topLabelFontDescriptor!, size: 0)
        contentView.addSubview(initialLabel)

        initialLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        initialLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        initialLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        initialLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    public func setCell(initial: String) {
        initialLabel.text = initial
    }

    public func selectCell() {
        contentView.backgroundColor = .skyBlue
        initialLabel.textColor = .white
    }

    public func unSelectCell() {
        contentView.backgroundColor = .white
        initialLabel.textColor = .black
    }

    public func getCellLabel() -> String {
        return initialLabel.text!
    }
}
