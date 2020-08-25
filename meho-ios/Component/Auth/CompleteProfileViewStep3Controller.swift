//
//  CompleteProfileViewStep3Controller.swift
//  meho-ios
//
//  Created by Meho Dev on 8/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

class CompleteProfileViewStep3Controller: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    // MARK: - Constants
    private let nextButtonWidth = CGFloat(200)
    private let nextButtonHeight = CGFloat(40)
    private let nextButtonCornerRadius = CGFloat(18)
    private let nextButtonBottomMargin = CGFloat(80)
    private let interestReasonLabelFontSize = CGFloat(18)
    private let interestReasonLabelTopMargin = CGFloat(40)
    private let contentLeadingTrailingMargin = CGFloat(20)
    private let questionCollectionViewCellReuseIdentifier = "questionCollectionViewCellReuseIdentifier"
    private let questionsCollectionViewTopBottomMargin = CGFloat(24)
    private let questionsCollectionViewCellSpacing = CGFloat(20)
    private let questionsCollectionViewCellHeight = CGFloat(86)
    private let questionsCollectionViewSpecialCellHeight = CGFloat(40)
    private let questionsCollectionNumberOfCellsInRow = 2
    private let questionsCollectionViewMinimumLineSpacing = CGFloat(40)
    private let questionsCollectionViewCellTitleFontSize = CGFloat(18)
    private let industryBottomLineHeight = CGFloat(3)
    private let industryStackViewTopMargin = CGFloat(30)
    private let industryStackViewBottomMargin = CGFloat(16)

    // MARK: - Properties
    // MARK: Model
    private let userDataFecther = UserDataFetcher.init()

    private lazy var questions: [ProfileQuestion] = {
        let academic = ProfileQuestion.init(title: "Academic", subtitle: "(student, scholar, researcher, etc)", color: .skyBlue, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let finance = ProfileQuestion.init(title: "Finance", subtitle: "(investment, banking, consulting, etc)", color: .skyBlue, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let trade = ProfileQuestion.init(title: "Trade", subtitle: "(import, export, ecommerce, etc)", color: .periwinkleBlue, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let service = ProfileQuestion.init(title: "Service", subtitle: "(hospitality, retail, media, travel, medical, etc)", color: .periwinkleBlue, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let tech = ProfileQuestion.init(title: "Tech", subtitle: "(software, telecom, hardward, etc)", color: .periwinkle, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let infrastructure = ProfileQuestion.init(title: "Infrastructure", subtitle: "(road, railway, energy, etc)", color: .periwinkle, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let others = ProfileQuestion.init(title: "Others", subtitle: nil, color: .periwinkle, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        return [academic, finance, trade, service, tech, infrastructure, others]
    } ()

    private var lastSelectedIndex = -1
    private var questionsCollectionViewHeight = CGFloat(0)

    // MARK: UI
    private lazy var nextButton: UIButton = {
        let nextButton = UIButton.init(frame: .zero)
        nextButton.isEnabled = false
        nextButton.setTitle(NSLocalizedString("StartLearningButtonTitle", comment: ""), for: .normal)
        nextButton.backgroundColor = .lightBlueGrey
        nextButton.setTitleColor(.white, for: .disabled)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        nextButton.clipsToBounds = true
        nextButton.layer.cornerRadius = nextButtonCornerRadius
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        return nextButton
    } ()

    private lazy var interestReasonLabel: UILabel = {
        let interestReasonLabel = UILabel.init(frame: .zero)
        interestReasonLabel.text = NSLocalizedString("IndustryTitle", comment: "")
        interestReasonLabel.textColor = .darkGrayTwo
        let interestReasonLabelFontDescriptor = UIFont.systemFont(ofSize: interestReasonLabelFontSize).fontDescriptor.withDesign(.rounded)
        interestReasonLabel.font = UIFont.init(descriptor: interestReasonLabelFontDescriptor!, size: interestReasonLabelFontSize)
        interestReasonLabel.translatesAutoresizingMaskIntoConstraints = false
        interestReasonLabel.numberOfLines = 0
        return interestReasonLabel
    } ()

    private lazy var questionsCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let questionsCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        questionsCollectionViewFlowLayout.minimumLineSpacing = questionsCollectionViewMinimumLineSpacing
        return questionsCollectionViewFlowLayout
    } ()

    private lazy var questionsCollectionView: UICollectionView = {
        let questionsCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: questionsCollectionViewFlowLayout)
        questionsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        questionsCollectionView.delegate = self
        questionsCollectionView.dataSource = self
        questionsCollectionView.register(QuestionCollectionViewCell.self, forCellWithReuseIdentifier: questionCollectionViewCellReuseIdentifier)
        questionsCollectionView.backgroundColor = .white
        return questionsCollectionView
    } ()

    private lazy var industryTextField: UITextField = {
        let industryTextField = UITextField.init(frame: .zero)
        industryTextField.translatesAutoresizingMaskIntoConstraints = false
        industryTextField.borderStyle = .none
        industryTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        industryTextField.delegate = self
        return industryTextField
    } ()

    private lazy var industryBottomLine: UIView = {
        let industryBottomLine = UIView.init(frame: .zero)
        industryBottomLine.translatesAutoresizingMaskIntoConstraints = false
        industryBottomLine.backgroundColor = .wisteriaPurple
        return industryBottomLine
    } ()

    private lazy var industryStackView: UIStackView = {
        let industryStackView = UIStackView.init(arrangedSubviews: [industryTextField, industryBottomLine])
        industryStackView.translatesAutoresizingMaskIntoConstraints = false
        industryStackView.axis = .vertical
        industryStackView.isHidden = true
        return industryStackView
    } ()

    private lazy var questionsCollectionViewHeightConstraint: NSLayoutConstraint = {
        return questionsCollectionView.heightAnchor.constraint(equalToConstant: questionsCollectionViewHeight)
    } ()

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        if indexPath.item == questions.count - 1 {
            return CGSize.init(width: availableWidth, height: questionsCollectionViewSpecialCellHeight)
        }
        let cellWidth = (availableWidth - CGFloat(questionsCollectionNumberOfCellsInRow - 1) * questionsCollectionViewCellSpacing) / CGFloat(questionsCollectionNumberOfCellsInRow)
        return CGSize.init(width: cellWidth, height: questionsCollectionViewCellHeight)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        if index == lastSelectedIndex {
            lastSelectedIndex = -1
            questions[index].isSelected = false
            collectionView.reloadItems(at: [indexPath])
        } else {
            questions[index].isSelected = true
            if (lastSelectedIndex != -1) {
                questions[lastSelectedIndex].isSelected = false
                collectionView.reloadItems(at: [indexPath, IndexPath.init(item: lastSelectedIndex, section: 0)])
            } else {
                collectionView.reloadItems(at: [indexPath])
            }
            lastSelectedIndex = index
        }
        if index == questions.count - 1 {
            industryStackView.isHidden = false
        } else {
            industryStackView.isHidden = true
            industryTextField.text = nil
        }
        updateNextButton()
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: questionCollectionViewCellReuseIdentifier, for: indexPath) as? QuestionCollectionViewCell {
            cell.setQuestion(questions[indexPath.item])
            return cell
        }
        return UICollectionViewCell.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        view.addSubview(questionsCollectionView)
        view.addSubview(interestReasonLabel)
        view.addSubview(nextButton)
        view.addSubview(industryStackView)

        interestReasonLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentLeadingTrailingMargin).isActive = true
        interestReasonLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentLeadingTrailingMargin).isActive = true
        interestReasonLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: interestReasonLabelTopMargin).isActive = true

        nextButton.widthAnchor.constraint(equalToConstant: nextButtonWidth).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: nextButtonHeight).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -nextButtonBottomMargin).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        industryStackView.leadingAnchor.constraint(equalTo: questionsCollectionView.leadingAnchor).isActive = true
        industryStackView.trailingAnchor.constraint(equalTo: questionsCollectionView.trailingAnchor).isActive = true
        let industryStackViewHeight = industryTextField.intrinsicContentSize.height + industryBottomLineHeight
        industryStackView.heightAnchor.constraint(equalToConstant: industryStackViewHeight).isActive = true
        industryStackView.topAnchor.constraint(equalTo: questionsCollectionView.bottomAnchor, constant: industryStackViewTopMargin).isActive = true

        questionsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentLeadingTrailingMargin).isActive = true
        questionsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentLeadingTrailingMargin).isActive = true
        questionsCollectionView.topAnchor.constraint(equalTo: interestReasonLabel.bottomAnchor, constant: questionsCollectionViewTopBottomMargin).isActive = true
        let viewHeight = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.layoutMarginsGuide.layoutFrame.height ?? view.bounds.height
        let interestReasonLabelHeight = interestReasonLabel.sizeThatFits(CGSize.init(width: view.bounds.width, height: .greatestFiniteMagnitude)).height
        let navigationBarHeight = navigationController?.navigationBar.frame.size.height ?? 0
        let questionsCollectionViewTop = interestReasonLabelHeight + interestReasonLabelTopMargin + questionsCollectionViewTopBottomMargin + navigationBarHeight
        let questionsCollectionViewBottom = nextButtonHeight + nextButtonBottomMargin + industryStackViewHeight + industryStackViewTopMargin + industryStackViewBottomMargin
        let availableQuestionsCollectionViewHeight = viewHeight - questionsCollectionViewTop - questionsCollectionViewBottom
        let questionsCollectionViewIdealHeight = (questionsCollectionViewCellHeight + questionsCollectionViewMinimumLineSpacing) * CGFloat((questions.count - 1) / questionsCollectionNumberOfCellsInRow) + questionsCollectionViewSpecialCellHeight
        questionsCollectionViewHeight = min(availableQuestionsCollectionViewHeight, questionsCollectionViewIdealHeight)
        questionsCollectionViewHeightConstraint.constant = questionsCollectionViewHeight
        questionsCollectionViewHeightConstraint.isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = NSLocalizedString("completeProfileStep3Title", comment: "")
    }

    // MARK: - Private
    @objc
    func didTapNextButton() {
        guard let userId = AWSMobileClient.default().userSub else { return }

        let profession: String?
        if lastSelectedIndex != questions.count - 1 {
            profession = questions[lastSelectedIndex].title
        } else {
            profession = industryTextField.text
        }
        if profession != nil {
            userDataFecther.updateUser(id: userId, profession: profession!) { (maybeUpdatedUser, error) in
                DispatchQueue.main.async {
                    self.navigationController?.setViewControllers([MehoCoverViewController.init()], animated: false)
                }
            }
        }
    }

    @objc
    private func textFieldDidChange() {
        updateNextButton()
    }

    @objc
    func keyboardWillShow() {
        questionsCollectionViewHeightConstraint.constant = questionsCollectionViewSpecialCellHeight
        view.layoutIfNeeded()
        questionsCollectionView.scrollToItem(at: IndexPath.init(item: questions.count - 1, section: 0), at: .bottom, animated: true)
    }

    @objc
    func keyboardWillHide() {
        questionsCollectionViewHeightConstraint.constant = questionsCollectionViewHeight
    }

    func updateNextButton() {
        var hasSelectedQuestion = false
        for question in questions {
            if question.isSelected {
                hasSelectedQuestion = true
                break
            }
        }
        if !industryStackView.isHidden {
            hasSelectedQuestion = hasSelectedQuestion && industryTextField.text != nil && industryTextField.text!.count > 0
        }
        nextButton.isEnabled = hasSelectedQuestion
        if nextButton.isEnabled {
            nextButton.backgroundColor = .skyBlue
        } else {
            nextButton.backgroundColor = .lightBlueGrey
        }
    }
}
