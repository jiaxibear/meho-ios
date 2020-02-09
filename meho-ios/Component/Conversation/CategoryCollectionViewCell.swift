//
//  CategoryCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 2/9/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import Foundation

class CategoryCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)
    private let coverImageSession = URLSession.init(configuration: .default)
    private let coverImageView = UIImageView.init(frame: .zero)
    
    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Sets up cover image view.
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(coverImageView)
        
        // Sets up title label.
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        self.contentView.addSubview(titleLabel)
        
        // Sets up constraints
        let margins = self.contentView.layoutMarginsGuide
        titleLabel.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        coverImageView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        coverImageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        coverImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }
    
    // MARK: - Public
    public func setCategory(category: Category) {
        // Sets the text for the title label.
        titleLabel.text = category.title
        titleLabel.sizeToFit()
        
        // Downloads the image.
        if let coverImageURL = category.coverImageURL {
            let coverImageDataTask = coverImageSession.dataTask(with: coverImageURL, completionHandler: { (Data, URLResponse, Error) in
                if Error != nil {
                    print("There is an error getting the cover image")
                    return
                }
                if Data == nil {
                    print("The cover image is empty")
                    return
                }
                if let coverImage = UIImage(data: Data!) {
                    DispatchQueue.main.async {
                        self.coverImageView.image = coverImage
                    }
                }
            })
            coverImageDataTask.resume()
        }
    }
}
