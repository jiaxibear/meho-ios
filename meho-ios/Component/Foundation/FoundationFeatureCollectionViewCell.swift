//
//  FoundationFeatureCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 2/9/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation
import UIKit

class FoundationFeatureCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let descriptionTopMargin = CGFloat(13)
    private let descriptionHorizontalMargin = CGFloat(18)
    private let imageCornerRadius = CGFloat(10)
    
    // MARK: - Properties
    private let descriptionLabel = UILabel.init(frame: .zero)
    private let featureImageView = UIImageView.init(frame: .zero)
    
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
        setupCellImageUI()
        setupDescriptionLabelUI()
    }
    
    // MARK: - Elements layout, style & constrains
    private func setupCellImageUI() {
        let cellView = self.contentView
        featureImageView.translatesAutoresizingMaskIntoConstraints = false
        featureImageView.layer.cornerRadius = imageCornerRadius
        featureImageView.clipsToBounds = true
        cellView.addSubview(featureImageView)

        // constraints
        featureImageView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor).isActive = true
        featureImageView.trailingAnchor.constraint(equalTo: cellView.trailingAnchor).isActive = true
        featureImageView.topAnchor.constraint(equalTo: cellView.topAnchor).isActive = true
        featureImageView.bottomAnchor.constraint(equalTo: cellView.bottomAnchor).isActive = true
        
    }
    
    private func setupDescriptionLabelUI() {
        let cellView = self.contentView
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(13))
        cellView.addSubview(descriptionLabel)
    
        // constraints
        descriptionLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: descriptionHorizontalMargin).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -descriptionHorizontalMargin).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: descriptionTopMargin).isActive = true
        
    }
    
    // MARK: - Public
    public func setFeatureCardData(feature: Feature) {
        descriptionLabel.text = feature.description
        descriptionLabel.textColor = feature.textColor
        descriptionLabel.sizeToFit()

        let featureImage = UIImage.init(named: feature.imageName)
        featureImageView.image = featureImage
    }
    
}
