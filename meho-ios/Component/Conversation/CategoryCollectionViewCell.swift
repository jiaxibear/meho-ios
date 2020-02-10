//
//  CategoryCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 2/9/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import Foundation

class CategoryCollectionViewCell: UICollectionViewCell, WebImageViewDelegate {
    
    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(16)
    private let coverImageViewCornerRadius = CGFloat(5)
    private let coverImageShadowViewAlpha = CGFloat(0.5)
    
    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)
    private let coverImageSession = URLSession.init(configuration: .default)
    private let coverImageView = WebImageView.init(frame: .zero)
    private let coverImageShadowView = UIView.init(frame: .zero)
    
    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Sets up cover image view.
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.layer.cornerRadius = coverImageViewCornerRadius
        coverImageView.clipsToBounds = true
        coverImageView.delegate = self
        self.contentView.addSubview(coverImageView)
        
        // Sets up the cover image shadow view
        coverImageShadowView.backgroundColor = .darkGray
        coverImageShadowView.alpha = coverImageShadowViewAlpha
        coverImageShadowView.translatesAutoresizingMaskIntoConstraints = false
        coverImageShadowView.layer.cornerRadius = coverImageViewCornerRadius
        coverImageShadowView.clipsToBounds = true
        self.contentView.addSubview(coverImageShadowView)
        
        // Sets up title label.
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabelFontSize)
        self.contentView.addSubview(titleLabel)
        
        // Sets up constraints
        let margins = self.contentView.layoutMarginsGuide
        titleLabel.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        coverImageView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        coverImageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        coverImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        coverImageShadowView.topAnchor.constraint(equalTo: coverImageView.topAnchor).isActive = true
        coverImageShadowView.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor).isActive = true
        coverImageShadowView.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor).isActive = true
        coverImageShadowView.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor).isActive = true
        
        self.contentView.isHidden = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }
    
    // MARK - WebImageViewDelegate
    func webImageViewDidSetImage(webImageView: WebImageView) {
        self.contentView.isHidden = false
    }
    
    // MARK: - Public
    public func setCategory(category: Category) {
        // Sets the text for the title label.
        titleLabel.text = category.title
        titleLabel.sizeToFit()
        
        // Downloads the image.
        if let coverImageURL = category.coverImageURL {
            coverImageView.imageURL = coverImageURL
        }
    }
}
