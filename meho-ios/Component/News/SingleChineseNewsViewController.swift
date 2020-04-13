//
//  SingleChineseNewsViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/6/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class SingleChineseNewsViewController: UIViewController {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(22)

    private let titleLabelFontSize = CGFloat(24)

    // MARK: - Properties
    private let title_zh: String
    private let title_en: String

    // MARK: - UI
    private let titleEnLabel = UILabel.init(frame: .zero)
    private let titleZhLabel = UILabel.init(frame: .zero)

    // MARK: - Init
    init() {
        fatalError("Use init")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    init(title_zh: String, title_en: String) {
        self.title_zh = title_zh
        self.title_en = title_en
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Sets up the title.
        titleZhLabel.text = title_zh
        titleZhLabel.textColor = .black
        titleZhLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: titleLabelFontSize)
        titleZhLabel.numberOfLines = 3
        titleZhLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleZhLabel)

        titleEnLabel.text = title_en
        titleEnLabel.textColor = .black
        let languageToggleEnfontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleEnLabel.font = UIFont.init(descriptor: languageToggleEnfontDescriptor!, size: 0)
        titleEnLabel.numberOfLines = 3
        titleEnLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleEnLabel)


        // Sets up layout constrainsts.
        titleZhLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: trailingLeadingMargin).isActive = true
        titleZhLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailingLeadingMargin).isActive = true
        titleZhLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true

        titleEnLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: trailingLeadingMargin).isActive = true
        titleEnLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailingLeadingMargin).isActive = true
        titleEnLabel.topAnchor.constraint(equalTo: titleZhLabel.bottomAnchor, constant: CGFloat(5)).isActive = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
