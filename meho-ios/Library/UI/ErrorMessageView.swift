//
//  ErrorMessageView.swift
//  meho-ios
//
//  Created by Meho Dev on 5/22/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import Foundation
import UIKit

class ErrorMessageView: UIView {

    private let cornerRadius = CGFloat(6)
    private let fontSize = CGFloat(18)
    private let stackViewSpacing = CGFloat(16)
    private let errorImageViewWidth = CGFloat(40)
    private let errorImageViewHeight = CGFloat(40)
    private let contentMargin = CGFloat(14)

    private lazy var errorImageView: UIImageView = {
        let errorImage = UIImage.init(named: "login_wrong")
        let errorImageView = UIImageView.init(image: errorImage)
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        return errorImageView
    } ()

    private lazy var errorLabel: UILabel = {
        let errorLabel = UILabel.init(frame: .zero)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        var font = UIFont.systemFont(ofSize: fontSize, weight: .light)
        if let fontDescriptor = font.fontDescriptor.withDesign(.rounded) {
            font = UIFont.init(descriptor: fontDescriptor, size: fontSize)
        }
        errorLabel.font = font
        errorLabel.textColor = .darkGrayTwo
        errorLabel.numberOfLines = 0
        return errorLabel
    } ()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.init(arrangedSubviews: [errorImageView, errorLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = stackViewSpacing
        return stackView
    } ()

    override var frame: CGRect {
        didSet {
            layer.applySketchShadow(color: UIColor.paleLilac, alpha: 1, x: 0, y: 2, blur: 4, spread: 2)
        }
    }

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect, errorMessage: String)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame: CGRect, errorMessage: String)")
    }

    init(frame: CGRect, errorMessage: String) {
        super.init(frame: frame)

        layer.cornerRadius = cornerRadius
        layer.applySketchShadow(color: UIColor.paleLilac, alpha: 1, x: 0, y: 2, blur: 4, spread: 2)
        backgroundColor = .white
        errorLabel.text = errorMessage

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentMargin),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: contentMargin),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentMargin),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentMargin),

            errorImageView.widthAnchor.constraint(equalToConstant: errorImageViewWidth),
            errorImageView.heightAnchor.constraint(equalToConstant: errorImageViewHeight)
        ])
    }
}

