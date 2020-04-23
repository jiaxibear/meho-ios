//
//  PinyinSectionHeaderCollectionReusableView.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/19/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class PinyinSectionHeaderCollectionReusableView: UICollectionReusableView {

    // MARK: - Properties
    private let delimiterView = PinyinDelimiterView.init(frame: .zero)

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupDelimiterView()
    }

    private func setupDelimiterView() {
        delimiterView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(delimiterView)

        delimiterView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        delimiterView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        delimiterView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        delimiterView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    public func setTitle(_ title: String) {
        delimiterView.setTitle(title: title)
    }

    public class func heightForTitle(_ title: String) -> CGFloat {
        let label = UILabel.init(frame: .zero)
        label.text = title
        label.sizeToFit()
        return label.frame.height
    }

}
