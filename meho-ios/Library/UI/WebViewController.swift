//
//  WebViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 7/26/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import WebKit
import FirebaseAnalytics

class WebViewController: UIViewController, MehoAnalytics {

    // MARK: - MehoAnalytics
    let screenName: String
    let screenClass: String

    // MARK: - Property
    private lazy var webView: WKWebView = {
        let webView = WKWebView.init(frame: .zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    } ()

    // MARK: - Init
    init() {
        fatalError("Use init(allDifficulties: [Difficulty], currentDifficulty: Difficulty)")
    }

    init(title: String, contentURL: URL, screenName: String, screenClass: String) {
        self.screenName = screenName
        self.screenClass = screenClass
        super.init(nibName: nil, bundle: nil)
        webView.loadFileURL(contentURL, allowingReadAccessTo: contentURL)
        self.title = title
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(allDifficulties: [Difficulty], currentDifficulty: Difficulty)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(allDifficulties: [Difficulty], currentDifficulty: Difficulty)")
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }
}
