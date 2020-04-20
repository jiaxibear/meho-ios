//
//  PinyinDetailView.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/19/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class PinyinDetailView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants
    private let pinyinToneDetailCellIdentifier = "pinyinToneDetailCell"
    private let messageLabelFontSize = CGFloat(20)
    private let toneCellLineSpacing = CGFloat(10)

    // MARK: - Properties
    private let detailNotFoundMessageLabel = UILabel.init(frame: .zero)
    private let toneDetailCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var toneDetailCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:toneDetailCollectionViewFlowLayout)


    // MARK: - Data
    private var maybePinyinDetail: Pinyin?


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

        setupDetailedPinyinNotFoundMessageLabel()
        setupDetailedPinyinCollectionView()
    }

    private func setupDetailedPinyinNotFoundMessageLabel () {
        detailNotFoundMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        let fontDescriptor = UIFont.systemFont(ofSize: messageLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        detailNotFoundMessageLabel.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        detailNotFoundMessageLabel.textColor = .wisteriaPurple
        detailNotFoundMessageLabel.numberOfLines = 3
        detailNotFoundMessageLabel.textAlignment = .center
        addSubview(detailNotFoundMessageLabel)

        detailNotFoundMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        detailNotFoundMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        detailNotFoundMessageLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        detailNotFoundMessageLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        detailNotFoundMessageLabel.isHidden = true
    }

    private func setupDetailedPinyinCollectionView() {
        toneDetailCollectionView.translatesAutoresizingMaskIntoConstraints = false
        toneDetailCollectionView.backgroundColor = .white
        addSubview(toneDetailCollectionView)

        // view constraints
        toneDetailCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        toneDetailCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        toneDetailCollectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        toneDetailCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        // collection layout
        toneDetailCollectionViewFlowLayout.scrollDirection = .vertical
        toneDetailCollectionViewFlowLayout.minimumLineSpacing = toneCellLineSpacing

        // Sets up cell data
        toneDetailCollectionView.showsHorizontalScrollIndicator = false
        toneDetailCollectionView.dataSource = self
        toneDetailCollectionView.delegate = self
        toneDetailCollectionView.register(PinyinToneDetailCollectionViewCell.self, forCellWithReuseIdentifier:pinyinToneDetailCellIdentifier)

        toneDetailCollectionView.isHidden = true
    }


    func setFoundDetail(pinyin: Pinyin) {
        maybePinyinDetail = pinyin
        toneDetailCollectionView.reloadData()
        detailNotFoundMessageLabel.isHidden = true
        toneDetailCollectionView.isHidden = false
    }

    func setNotFound(message: String) {
        detailNotFoundMessageLabel.text = message
        detailNotFoundMessageLabel.isHidden = false
        toneDetailCollectionView.isHidden = true
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maybePinyinDetail == nil ? 0 : 4
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width * 0.45
        let height = collectionView.bounds.height * 0.45
        return CGSize(width: width, height: height)
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let pinyinDetail = maybePinyinDetail {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pinyinToneDetailCellIdentifier, for: indexPath) as! PinyinToneDetailCollectionViewCell
            switch indexPath.item {
            case 0:
                if (pinyinDetail.toneOneSymbol != "") {
                    cell.setDetailsFound(symbol: pinyinDetail.toneOneSymbol, character: pinyinDetail.toneOneCharacter, pronounceUrl: pinyinDetail.toneOnePronounceUrl)
                } else {
                    cell.setDetailsNotFound(symbol: pinyinDetail.pinyin)
                }
            case 1:
                if (pinyinDetail.toneTwoSymbol != "") {
                    cell.setDetailsFound(symbol: pinyinDetail.toneTwoSymbol, character: pinyinDetail.toneTwoCharacter, pronounceUrl: pinyinDetail.toneTwoPronounceUrl)
                } else {
                   cell.setDetailsNotFound(symbol: pinyinDetail.pinyin)
               }
            case 2:
                if (pinyinDetail.toneThreeSymbol != "") {
                    cell.setDetailsFound(symbol: pinyinDetail.toneThreeSymbol, character: pinyinDetail.toneThreeCharacter, pronounceUrl: pinyinDetail.toneThreePronounceUrl)
                } else {
                    cell.setDetailsNotFound(symbol: pinyinDetail.pinyin)
                }
            case 3:
                if (pinyinDetail.toneFourSymbol != "") {
                    cell.setDetailsFound(symbol: pinyinDetail.toneFourSymbol, character: pinyinDetail.toneFourCharacter, pronounceUrl: pinyinDetail.toneFourPronounceUrl)
                } else {
                    cell.setDetailsNotFound(symbol: pinyinDetail.pinyin)
                }
            default:
                print("Should not come here")
            }
            return cell

        }
        return UICollectionViewCell.init()
    }

}
