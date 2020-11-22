//
//  NewsRecapVocabularyCollectionViewCell.swift
//  meho-ios
//  Holds UI logic for showing
//
//  Created by Jiaxi Xiong on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3

class NewsRecapVocabularyCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    let labelFontSize = CGFloat(18)
    let labelToExplainMargin = CGFloat(10)
    let pronounceSpeakerSize = CGFloat(25)
    private let pronounceButtonImageName = "stories_speaker"

    // MARK: - Properties
    private lazy var vocabularyZhLabel: UILabel = {
        let vocabularyZhLabel = UILabel.init(frame: .zero)
        vocabularyZhLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyZhLabel.textColor = .darkGrayTwo
        vocabularyZhLabel.font = UIFont.init(name: "PingFangSC-Medium", size: labelFontSize)
        vocabularyZhLabel.numberOfLines = 1
        return vocabularyZhLabel
    } ()

    private lazy var vocabularyPinyinLabel: UILabel = {
        let vocabularyPinyinLabel = UILabel.init(frame: .zero)
        vocabularyPinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyPinyinLabel.textColor = .darkGrayTwo
        if let pinyinfontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded) {
            vocabularyPinyinLabel.font = UIFont.init(descriptor: pinyinfontDescriptor, size: labelFontSize)
        }
        vocabularyPinyinLabel.numberOfLines = 1
        return vocabularyPinyinLabel
    } ()

    private lazy var vocabularyEnLabel: UILabel = {
        let vocabularyEnLabel = UILabel.init(frame: .zero)
        vocabularyEnLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyEnLabel.textColor = .textBlueGray
        let enfontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        vocabularyEnLabel.font = UIFont.init(descriptor: enfontDescriptor!, size: 0)
        vocabularyEnLabel.numberOfLines = 0
        return vocabularyEnLabel
    } ()

    private lazy var prounceButton: UIButton = {
        let prounceButton = UIButton.init(frame: .zero)
        let pronounceSpeakerImage = UIImage.init(named: pronounceButtonImageName)
        prounceButton.translatesAutoresizingMaskIntoConstraints = false
        prounceButton.setImage(pronounceSpeakerImage, for: UIControl.State.normal)
        prounceButton.addTarget(self, action: #selector(didTapPronounceButton), for: .touchUpInside)
        return prounceButton
    } ()

    private lazy var topLineStackView: UIStackView = {
        let topLineStackView = UIStackView.init(arrangedSubviews: [vocabularyZhLabel, vocabularyPinyinLabel, prounceButton])
        topLineStackView.translatesAutoresizingMaskIntoConstraints = false
        topLineStackView.axis = .horizontal
        topLineStackView.alignment = .center
        return topLineStackView
    } ()

    private static var sizingCell = NewsRecapVocabularyCollectionViewCell.init(frame: .zero);

    // MARK: - Data
    private var player: AVPlayer?
    private var maybePronounceAudioUrl: URL?
    private var maybePronounceAudioBucket: String?
    private var maybePronounceAudioKey: String?


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

        addSubview(topLineStackView)
        topLineStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        topLineStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        prounceButton.widthAnchor.constraint(equalToConstant: pronounceSpeakerSize).isActive = true
        prounceButton.heightAnchor.constraint(equalToConstant: pronounceSpeakerSize).isActive = true
        setupeEnLabel()
    }

    func setupeEnLabel() {
        contentView.addSubview(vocabularyEnLabel)

        vocabularyEnLabel.topAnchor.constraint(equalTo: topLineStackView.bottomAnchor, constant: labelToExplainMargin).isActive = true
        vocabularyEnLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        vocabularyEnLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }


    // MARK: - Public
    public func setVocabulary(_ vocabulary: Vocabulary) {
        vocabularyZhLabel.text = vocabulary.content_zh
        vocabularyPinyinLabel.text = " /" + vocabulary.content_pinyin + "/  "
        var explanation = vocabulary.content_en
        if vocabulary.content_optional != "" {
            explanation = explanation + "\n" + vocabulary.content_optional
        }
        vocabularyEnLabel.text = explanation
        maybePronounceAudioUrl = vocabulary.audioURL
        maybePronounceAudioKey = vocabulary.audio_key
        maybePronounceAudioBucket = vocabulary.audio_bucket
    }

    public class func cellHeight(with width: CGFloat, vocabulary: Vocabulary) -> CGFloat {
        sizingCell.setVocabulary(vocabulary)
        let height = sizingCell.labelToExplainMargin
            + sizingCell.vocabularyEnLabel.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
            + sizingCell.vocabularyZhLabel.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
        return height
    }

    // MARK: - Private
    @objc func didTapPronounceButton() {
        if let pronounceURL = maybePronounceAudioUrl {
            let playerItem = AVPlayerItem.init(url: pronounceURL)
            player = AVPlayer.init(playerItem: playerItem)
            player?.rate = AudioPlaySpeed.normal.rawValue
            player?.play()
        }
        if let audioKey = maybePronounceAudioKey, let audioBucket = maybePronounceAudioBucket {
            let hackedUrlString = ("https://" + audioBucket + ".s3-us-west-2.amazonaws.com/public/" + audioKey).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let someURLComponent = URLComponents.init(string: hackedUrlString!) {
                if let fetchNewsDetailURL = someURLComponent.url {
                    let playerItem = AVPlayerItem.init(url: fetchNewsDetailURL)
                    player = AVPlayer.init(playerItem: playerItem)
                    player?.rate = AudioPlaySpeed.normal.rawValue
                    player?.play()
                }
            }

            /* The following code generate presignedurl like this - seems the signed part is not created properly, need to revisit; Also, need to abstract into some shared WebAudioPlayer
             "<Message>Query-string authentication version 4 requires the X-Amz-Algorithm, X-Amz-Credential, X-Amz-Signature, X-Amz-Date, X-Amz-SignedHeaders, and X-Amz-Expires parameters.</Message>"
             https://mehoassets213338-mehoadmin.s3-us-west-2.amazonaws.com/public/60a2853d-bcdc-4cab-9b9d-485b843b0e9c%E8%84%B8%E8%B0%B1.mp3?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAUJ3QZFM7CCH7GZ4V%2F20200820%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20200820T092137Z&X-Amz-Expires=3593&X-Amz-SignedHeaders=host&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEFkaCXVzLXdlc3QtMiJGMEQCICo84H%2B9pf%2BaL1%2FjExFKa94TP1qQWQGd7wFkHAUh4RroAiBeMqjr550BZSJ55bY1FIf2MC22yt4FnKEHQLT1mqvlIyqQBghCEAIaDDI5NjA1MjQwMzAwNiIMOYQiy%2FZzLtNWPsRrKu0FdpVGn3LSNzWAAjXsRHjrZus31%2Fo2EtxSdQOUbd9WOqyV2oOKIwcTvNFuUopRjMinSNSwGl%2BDW6WZnw6smyV3qSBpPzy3e9r7Lj3xgNpW6otAixo5WyP3SKSm9VJ9qJUwbXh4eM4GRF6SS3S6wNP23Y%2BEIIj5mPiNyFJTX2GTWQiBg5y7eum5IuRQ1nLi7WZnfrJxXJsJGz%2BtaITAnH6P1Z0cY%2Fg5A867uQ5avIX6g7toVkJTNNh1NvFlv131FlOeaT69Cv3hbU8JSaHYkOSTdj8JXWngLueIPGVfK9jmDefX2NdvzRgcQbZwIdjdHZrQMkqyW7nV%2FRO0kxdblQvQw1a%2FIAwSf1dQAl7SPcqQEMeDi1XTD78PYpzOsSirELPFIqDWlEusaxRNXzPGv%2FnuGNXlKccfjDk1SLaOrAsdniA%2BBCG%2BrAS8MN7opB92shjEQpY0ODGDtcdiVe4XRJU2%2BbgHFnWPsL
             */
//            let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
//            getPreSignedURLRequest.bucket = audioBucket
//            getPreSignedURLRequest.key = "public/" + audioKey
//            getPreSignedURLRequest.httpMethod = .GET
//            getPreSignedURLRequest.expires = Date(timeIntervalSinceNow: 3600)
//
//            AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPreSignedURLRequest).continueWith { (task:AWSTask<NSURL>) -> Any? in
//                if let error = task.error as? Error {
//                    print("Error: \(error)")
//                    return nil
//                }
//
//                let presignedURL = task.result
//                let playerItem = AVPlayerItem.init(url: presignedURL as! URL)
//                self.player = AVPlayer.init(playerItem: playerItem)
//                self.player?.rate = AudioPlaySpeed.normal.rawValue
//                self.player?.play()
//
//                return nil;
//            }
        }
    }
}
