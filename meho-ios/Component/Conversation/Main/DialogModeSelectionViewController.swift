//
//  DialogModeSelectionViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 6/21/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

protocol DialogModeSelectionViewControllerDelegate: AnyObject {
    func dialogModeSelectionViewControllerDidTapSoloPracticeButton(dialogID: String)
    func dialogModeSelectionViewControllerDidTapDuoRolePlayButton(dialogID: String)
}

class DialogModeSelectionViewController: UIViewController {

    private let difficultyLabelCornerRadius = CGFloat(2)
    private let difficultyLabelWidth = CGFloat(66)
    private let difficultyLabelHeight = CGFloat(20)
    private let difficultyLabelTopMargin = CGFloat(16)
    private let difficultyLabelFontSize = CGFloat(10)
    private let titleLabelFontSize = CGFloat(20)
    private let titleLabelTopMargin = CGFloat(24)
    private let titleInLocalLanguageLabelFontSize = CGFloat(16)
    private let titleInLocalLanguageLabelTopMargin = CGFloat(12)
    private let introductionLabelFontSize = CGFloat(16)
    private let introductionLabelTopMargin = CGFloat(20)
    private let viewWidth = CGFloat(330)
    private let contentStackViewLeadingTrailingMarging = CGFloat(16)
    private let buttonsStackViewTopMargin = CGFloat(44)
    private let buttonsStackViewBottomMargin = CGFloat(40)
    private let buttonsStackViewHeight = CGFloat(36)
    private let buttonsStackViewSpacing = CGFloat(20)
    private let buttonCornerRadius = CGFloat(8)
    private let buttonFontSize = CGFloat(14)

    // MARK: - Property
    // MARK: Data Models
    let dialog: Dialog

    // MARK: UI
    private lazy var difficultyLabel: UILabel = {
        let difficultyLabel = UILabel.init(frame: .zero)
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        difficultyLabel.clipsToBounds = true
        difficultyLabel.layer.cornerRadius = difficultyLabelCornerRadius
        difficultyLabel.textColor = .white
        difficultyLabel.textAlignment = .center
        let difficultyLabelFontDescriptor = UIFont.systemFont(ofSize: difficultyLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        difficultyLabel.font = UIFont.init(descriptor: difficultyLabelFontDescriptor!, size: difficultyLabelFontSize)
        difficultyLabel.text = dialog.difficulty.title.uppercased()
        switch dialog.difficulty.identifier {
        case .advanced:
            difficultyLabel.backgroundColor = .skyBlue
            break
        case .intermediate:
            difficultyLabel.backgroundColor = .periwinkle
            break
        case .beginner:
            difficultyLabel.backgroundColor = .wisteriaPurple
            break
        }
        return difficultyLabel
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        titleLabel.font = UIFont.init(name: "PingFangSC-Medium", size: titleLabelFontSize)
        titleLabel.text = dialog.title
        titleLabel.numberOfLines = 0
        return titleLabel
    } ()

    private lazy var titleInLocalLanguageLabel: UILabel = {
        let titleInLocalLanguageLabel = UILabel.init(frame: .zero)
        titleInLocalLanguageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInLocalLanguageLabel.textColor = .textBlueGray
        let titleInLocalLanguageLabelFontDescriptor = UIFont.systemFont(ofSize: titleInLocalLanguageLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleInLocalLanguageLabel.font = UIFont.init(descriptor: titleInLocalLanguageLabelFontDescriptor!, size: titleLabelFontSize)
        titleInLocalLanguageLabel.text = dialog.titleInLocalLanguage
        titleInLocalLanguageLabel.numberOfLines = 0
        return titleInLocalLanguageLabel
    } ()

    private lazy var introductionLabel: UILabel = {
        let introductionLabel = UILabel.init(frame: .zero)
        introductionLabel.translatesAutoresizingMaskIntoConstraints = false
        introductionLabel.textColor = .darkGrayTwo
        introductionLabel.font = UIFont.systemFont(ofSize: introductionLabelFontSize)
        introductionLabel.text = "Learn how to introduce yourself to collegues"
        introductionLabel.numberOfLines = 0
        // TODO: Use real text.
        return introductionLabel
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [difficultyLabel, titleLabel, titleInLocalLanguageLabel, introductionLabel])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.alignment = .leading
        contentStackView.setCustomSpacing(titleLabelTopMargin, after: difficultyLabel)
        contentStackView.setCustomSpacing(titleInLocalLanguageLabelTopMargin, after: titleLabel)
        contentStackView.setCustomSpacing(introductionLabelTopMargin, after: titleInLocalLanguageLabel)
        return contentStackView
    } ()

    private lazy var soloPracticeButton: UIButton = {
        let soloPracticeButton = UIButton.init(frame: .zero)
        soloPracticeButton.translatesAutoresizingMaskIntoConstraints = false
        soloPracticeButton.setTitleColor(.white, for: .normal)
        soloPracticeButton.setTitle(NSLocalizedString("soloPracticeButtonTitle", comment: ""), for: .normal)
        soloPracticeButton.backgroundColor = .wisteriaPurple
        soloPracticeButton.clipsToBounds = true
        soloPracticeButton.layer.cornerRadius = buttonCornerRadius
        let soloPracticeButtonFontDescriptor = UIFont.systemFont(ofSize: buttonFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        soloPracticeButton.titleLabel?.font = UIFont.init(descriptor: soloPracticeButtonFontDescriptor!, size: buttonFontSize)
        soloPracticeButton.addTarget(self, action: #selector(didTapSoloPracticeButton), for: .touchUpInside)
        return soloPracticeButton
    } ()

    private lazy var duoRolePlayButton: UIButton = {
        let duoRolePlayButton = UIButton.init(frame: .zero)
        duoRolePlayButton.translatesAutoresizingMaskIntoConstraints = false
        duoRolePlayButton.setTitleColor(.white, for: .normal)
        duoRolePlayButton.setTitle(NSLocalizedString("duoRolePlayButtonTitle", comment: ""), for: .normal)
        duoRolePlayButton.backgroundColor = .skyBlue
        duoRolePlayButton.clipsToBounds = true
        duoRolePlayButton.layer.cornerRadius = buttonCornerRadius
        let duoRolePlayButtonFontDescriptor = UIFont.systemFont(ofSize: buttonFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        duoRolePlayButton.titleLabel?.font = UIFont.init(descriptor: duoRolePlayButtonFontDescriptor!, size: buttonFontSize)
        duoRolePlayButton.addTarget(self, action: #selector(didTapDuoRolePlayButton), for: .touchUpInside)
        return duoRolePlayButton
    } ()

    private lazy var buttonsStackView: UIStackView = {
        let buttonsStackView = UIStackView.init(arrangedSubviews: [soloPracticeButton, duoRolePlayButton])
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = buttonsStackViewSpacing
        buttonsStackView.distribution = .fillEqually
        return buttonsStackView
    } ()

    var delegate: DialogModeSelectionViewControllerDelegate?

    // MARK: - Init
    init() {
        fatalError("init(dialog: Dialog)")
    }

    init(dialog: Dialog) {
        self.dialog = dialog
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(dialog: Dialog)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(dialog: Dialog)")
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentStackView)
        view.addSubview(buttonsStackView)
        view.backgroundColor = .white

        difficultyLabel.widthAnchor.constraint(equalToConstant: difficultyLabelWidth).isActive = true
        difficultyLabel.heightAnchor.constraint(equalToConstant: difficultyLabelHeight).isActive = true

        var viewHeight = difficultyLabelTopMargin
        var contentStackViewHeight = difficultyLabelHeight
        let contentStackViewWidth = viewWidth - 2 * contentStackViewLeadingTrailingMarging
        let labelFittingSize = CGSize.init(width: contentStackViewWidth, height: .greatestFiniteMagnitude)
        contentStackViewHeight = contentStackViewHeight + titleLabel.sizeThatFits(labelFittingSize).height + titleLabelTopMargin
        contentStackViewHeight = contentStackViewHeight + titleInLocalLanguageLabel.sizeThatFits(labelFittingSize).height + titleInLocalLanguageLabelTopMargin
        contentStackViewHeight = contentStackViewHeight + introductionLabel.sizeThatFits(labelFittingSize).height + introductionLabelTopMargin
        viewHeight = viewHeight + contentStackViewHeight + buttonsStackViewTopMargin + buttonsStackViewHeight + buttonsStackViewBottomMargin

        contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: difficultyLabelTopMargin).isActive = true
        contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentStackViewLeadingTrailingMarging).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentStackViewLeadingTrailingMarging).isActive = true
        contentStackView.heightAnchor.constraint(equalToConstant: contentStackViewHeight).isActive = true

        buttonsStackView.topAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: buttonsStackViewTopMargin).isActive = true
        buttonsStackView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor).isActive = true
        buttonsStackView.heightAnchor.constraint(equalToConstant: buttonsStackViewHeight).isActive = true

        preferredContentSize = CGSize.init(width: viewWidth, height: viewHeight)
    }

    // MARK: - Private
    @objc
    func didTapSoloPracticeButton() {
        delegate?.dialogModeSelectionViewControllerDidTapSoloPracticeButton(dialogID: dialog.identifier)
    }

    @objc
    func didTapDuoRolePlayButton()  {
        delegate?.dialogModeSelectionViewControllerDidTapDuoRolePlayButton(dialogID: dialog.identifier)
    }
}
