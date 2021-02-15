//
//  IdiomViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/15/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class IdiomViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MehoAnalytics, IdiomCollectionViewCellDelegate, NewsPlayingNow, NewsPlayingNowViewDelegate {

    // MARK: - Constant
    private let cardHorizontalInsets = CGFloat(30)
    private let cardInterSpacing = CGFloat(30)
    private let idiomCellReuseIdentifier = "idiomCellReuseIdentifier"
    private let cellRatio = CGFloat(1.78)

    // MARK: - Properties
    // MARK: UI
    private lazy var idiomCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let idiomCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        idiomCollectionViewFlowLayout.scrollDirection = .horizontal
        idiomCollectionViewFlowLayout.minimumLineSpacing = cardInterSpacing * 2
        return idiomCollectionViewFlowLayout
    } ()

    private lazy var idiomCollectionView: UICollectionView = {
        let idiomCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: idiomCollectionViewFlowLayout)
        idiomCollectionView.translatesAutoresizingMaskIntoConstraints = false
        idiomCollectionView.backgroundColor = .white
        idiomCollectionView.dataSource = self
        idiomCollectionView.delegate = self
        idiomCollectionView.showsHorizontalScrollIndicator = false
        idiomCollectionView.register(IdiomCollectionViewCell.self, forCellWithReuseIdentifier:idiomCellReuseIdentifier)
        idiomCollectionView.isPagingEnabled = true
        return idiomCollectionView
    } ()

    private lazy var cellWidth: CGFloat = {
        return view.bounds.width - 2 * cardHorizontalInsets
    } ()

    private lazy var cellHeight: CGFloat = {
        return min(cellWidth * cellRatio, view.bounds.height - view.layoutMargins.top - view.layoutMargins.bottom);
    } ()

    // MARK: MehoAnalytics
    let screenName = "p_meho_foundations_idioms"
    let screenClass = "p_meho_foundations_idioms"

    // MARK: Data Models
    private lazy var idioms: [Idiom] = {
        let qqshImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/Foundation_1_%E7%90%B4%E6%A3%8B%E4%B9%A6%E7%94%BB.png")
        let qqshAudioURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/%E7%90%B4%E6%A3%8B%E4%B9%A6%E7%94%BB.mp3")
        let qqsh = Idiom.init(title: "琴棋书画", explanation: "all sorts of artistic talents", backgroundImageURL: qqshImageURL!, audioURL: qqshAudioURL!, firstWord: "琴:", firstWordExplanation: "Chinese zither", secondWord: "棋:", secondWordExplanation: "Go (the board game)", thirdWord: "书:", thirdWordExplanation: "calligraphy", fourthWord: "画:", fourthWordExplanation: "paintings")
        let sjjrImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/Foundation_2_%E8%88%8D%E5%B7%B1%E6%95%91%E4%BA%BA.png")
        let sjjrAudioURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/%E8%88%8D%E5%B7%B1%E6%95%91%E4%BA%BA.mp3")
        let sjjr = Idiom.init(title: "舍己救人", explanation: "to sacrifice oneself to save others", backgroundImageURL: sjjrImageURL!, audioURL: sjjrAudioURL!, firstWord: "舍:", firstWordExplanation: "to sacrifice (蛇 shé - snake)", secondWord: "己:", secondWordExplanation: "oneself （鸡 jī - chicken）", thirdWord: "救:", thirdWordExplanation: "to save (酒 jiǔ - wine)", fourthWord: "人:", fourthWordExplanation: "people, others")
        let csmlImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/Foundation_3_%E8%BD%A6%E6%B0%B4%E9%A9%AC%E9%BE%99.png")
        let csmlAudioURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/%E8%BD%A6%E6%B0%B4%E9%A9%AC%E9%BE%99.mp3")
        let csml = Idiom.init(title: "车水马龙", explanation: "wagons, vehicles", backgroundImageURL: csmlImageURL!, audioURL: csmlAudioURL!, firstWord: "车:", firstWordExplanation: "wagons, vehicles", secondWord: "水:", secondWordExplanation: "water, flow", thirdWord: "马:", thirdWordExplanation: "horse", fourthWord: "龙:", fourthWordExplanation: "dragon, a continuous stream")
        let rsrhImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/Foundation_4_%E4%BA%BA%E5%B1%B1%E4%BA%BA%E6%B5%B7.png")
        let rsrhAudioURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/%E4%BA%BA%E5%B1%B1%E4%BA%BA%E6%B5%B7.mp3")
        let rsrh = Idiom.init(title: "人山人海", explanation: "a huge crowd of people", backgroundImageURL: rsrhImageURL!, audioURL: rsrhAudioURL!, firstWord: "人:", firstWordExplanation: "people", secondWord: "山:", secondWordExplanation: "mountain", thirdWord: "人:", thirdWordExplanation: "people", fourthWord: "海:", fourthWordExplanation: "sea")
        let byjrImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/Foundation_5_%E6%8B%A8%E4%BA%91%E8%A7%81%E6%97%A5.png")
        let byjrAudioURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/%E6%8B%A8%E4%BA%91%E8%A7%81%E6%97%A5.mp3")
        let byjr = Idiom.init(title: "拨云见日", explanation: "remove the cloud to see the sun (see the light after darkness)", backgroundImageURL: byjrImageURL!, audioURL: byjrAudioURL!, firstWord: "拨:", firstWordExplanation: "to remove （菠 as in 菠萝 bō - pineapple）", secondWord: "云:", secondWordExplanation: "cloud", thirdWord: "见:", thirdWordExplanation: "to see", fourthWord: "日:", fourthWordExplanation: "the sun")
        let jfddImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/Foundation_6_%E9%B8%A1%E9%A3%9E%E8%9B%8B%E6%89%93.png")
        let jfddAudioURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/%E9%B8%A1%E9%A3%9E%E8%9B%8B%E6%89%93.mp3")
        let jfdd = Idiom.init(title: "鸡飞蛋打", explanation: "the hen has flown away and the eggs are broken - all is lost", backgroundImageURL: jfddImageURL!, audioURL: jfddAudioURL!, firstWord: "鸡:", firstWordExplanation: "hen", secondWord: "飞:", secondWordExplanation: "to fly", thirdWord: "蛋:", thirdWordExplanation: "egg", fourthWord: "打:", fourthWordExplanation: "broken, beaten")
        let bxjjImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/Foundation_7_%E6%82%B2%E5%96%9C%E4%BA%A4%E5%8A%A0.png")
        let bxjjAudioURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/%E6%82%B2%E5%96%9C%E4%BA%A4%E5%8A%A0.mp3")
        let bxjj = Idiom.init(title: "悲喜交加", explanation: "a mixed feeling of joy and sadness", backgroundImageURL: bxjjImageURL!, audioURL: bxjjAudioURL!, firstWord: "悲:", firstWordExplanation: "sadness", secondWord: "喜:", secondWordExplanation: "joy", thirdWord: "交:", thirdWordExplanation: "mixed", fourthWord: "加:", fourthWordExplanation: "added, overlapping （家 jiā - home）")
        let ksxfImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/Foundation_8_%E5%8F%A3%E6%98%AF%E5%BF%83%E9%9D%9E.png")
        let ksxfAudioURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/%E5%8F%A3%E6%98%AF%E5%BF%83%E9%9D%9E.mp3")
        let ksxf = Idiom.init(title: "口是心非", explanation: "when saying yes means no", backgroundImageURL: ksxfImageURL!, audioURL: ksxfAudioURL!, firstWord: "口:", firstWordExplanation: "mouth", secondWord: "是:", secondWordExplanation: "yes", thirdWord: "心:", thirdWordExplanation: "heart", fourthWord: "非:", fourthWordExplanation: "no")
        let xxxyImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/Foundation_9_%E5%BF%83%E5%BF%83%E7%9B%B8%E5%8D%B0.png")
        let xxxyAudioURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/%E5%BF%83%E5%BF%83%E7%9B%B8%E5%8D%B0.mp3")
        let xxxy = Idiom.init(title: "心心相印", explanation: "two hearts are in perfect harmonyo", backgroundImageURL: xxxyImageURL!, audioURL: xxxyAudioURL!, firstWord: "心:", firstWordExplanation: "heart", secondWord: "心:", secondWordExplanation: "heart", thirdWord: "相:", thirdWordExplanation: "mutually （象 xiàng - elephant) ", fourthWord: "印:", fourthWordExplanation: "corresponding")
        let yyrlImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/Foundation_10_%E4%BD%99%E9%9F%B3%E7%BB%95%E6%A2%81.png")
        let yyrlAudioURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/%E4%BD%99%E9%9F%B3%E7%BB%95%E6%A2%81.mp3")
        let yyrl = Idiom.init(title: "余音绕梁", explanation: "the lingering sound circles in the air", backgroundImageURL: yyrlImageURL!, audioURL: yyrlAudioURL!, firstWord: "余:", firstWordExplanation: "lingering（鱼 yú - fish）", secondWord: "音:", secondWordExplanation: "sound", thirdWord: "绕:", thirdWordExplanation: "circling", fourthWord: "梁:", fourthWordExplanation: "beam（粮 liáng - grain food)")
        let hthnImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/Foundation_11_%E8%99%8E%E5%A4%B4%E8%99%8E%E8%84%91.png")
        let hthnAudioURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/%E8%99%8E%E5%A4%B4%E8%99%8E%E8%84%91.mp3")
        let hthn = Idiom.init(title: "虎头虎脑", explanation: "to have a tiger’s head - to be rash and careless", backgroundImageURL: hthnImageURL!, audioURL: hthnAudioURL!, firstWord: "虎:", firstWordExplanation: "tiger", secondWord: "头:", secondWordExplanation: "head", thirdWord: "虎:", thirdWordExplanation: "tiger", fourthWord: "脑:", fourthWordExplanation: "head")
        let ymggImageURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/Foundation_12_%E5%A6%96%E9%AD%94%E9%AC%BC%E6%80%AA.png")
        let ymggAudioURL = URL.init(string: "https://meho-assets.s3-us-west-2.amazonaws.com/%E5%A6%96%E9%AD%94%E9%AC%BC%E6%80%AA.mp3")
        let ymgg = Idiom.init(title: "妖魔鬼怪", explanation: "all sorts of evil-doers", backgroundImageURL: ymggImageURL!, audioURL: ymggAudioURL!, firstWord: "妖:", firstWordExplanation: "evil fairy", secondWord: "魔:", secondWordExplanation: "demon", thirdWord: "鬼:", thirdWordExplanation: "ghost", fourthWord: "怪:", fourthWordExplanation: "monster")
        return [qqsh, sjjr, csml, rsrh, byjr, jfdd, bxjj, ksxf, xxxy, yyrl, hthn, ymgg]
    } ()

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.backgroundColor = .white
        title = NSLocalizedString("IdiomTitle", comment: "")
        view.addSubview(idiomCollectionView)

        idiomCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        idiomCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        idiomCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        idiomCollectionView.heightAnchor.constraint(equalToConstant: cellHeight + 1).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newsAudioPlayer = NewsAudioPlayer.shared
        if newsAudioPlayer.status != .notStarted, let newsPlayingNowView = newsAudioPlayer.newsPlayingNowView {
            displayNewsPlayingNowView(newsPlayingNowView)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
        for index in idioms.indices {
            idioms[index].contentTrackingID = UUID().uuidString
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return idioms.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idiomCellReuseIdentifier, for: indexPath) as! IdiomCollectionViewCell
        let idiom = idioms[indexPath.item]
        cell.setIdiom(idiom)
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: cellWidth, height: cellHeight)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: cardInterSpacing, bottom: 0, right: cardInterSpacing)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let idiom = idioms[indexPath.item]
        Analytics.logContentImpression(content: idiom, screenName: screenName)
    }

    // MARK: - IdiomCollectionViewCellDelegate
    func idiomCollectionViewCellDidTapPlayButton(idiom: Idiom) {
        Analytics.logContentAction(content: idiom, screenName: screenName, action: .play)
    }

    // MARK: - NewsPlayingNow
    func displayNewsPlayingNowView(_ newsPlayingNowView: NewsPlayingNowView) {
        if newsPlayingNowView.superview != nil {
            newsPlayingNowView.removeFromSuperview()
        }
        newsPlayingNowView.delegate = self

        view.addSubview(newsPlayingNowView)
        var contentInset = idiomCollectionView.contentInset
        contentInset.bottom = newsPlayingNowView.intrinsicContentSize.height
        idiomCollectionView.contentInset = contentInset
        NSLayoutConstraint.activate([
            newsPlayingNowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsPlayingNowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsPlayingNowView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - NewsPlayingNowViewDelegate
    func didTapCancelButton() {
        var contentInset = idiomCollectionView.contentInset
        contentInset.bottom = 0
        idiomCollectionView.contentInset = contentInset
    }
}
