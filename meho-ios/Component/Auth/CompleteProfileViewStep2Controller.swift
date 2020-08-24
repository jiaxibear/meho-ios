//
//  CompleteProfileViewStep2Controller.swift
//  meho-ios
//
//  Created by Meho Dev on 8/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

class CompleteProfileViewStep2Controller: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
    private let questionsCollectionViewCellHeight = CGFloat(36)
    private let questionsCollectionNumberOfCellsInRow = 3
    private let questionsCollectionViewMinimumLineSpacing = CGFloat(26)
    private let questionsCollectionViewCellTitleFontSize = CGFloat(14)

    // MARK: - Properties
    // MARK: Model
    private let userDataFecther = UserDataFetcher.init()

    private lazy var questions: [ProfileQuestion] = {
        let business = ProfileQuestion.init(title: "#Business", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let tech = ProfileQuestion.init(title: "#Tech", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let finance = ProfileQuestion.init(title: "#Finance", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let networking = ProfileQuestion.init(title: "#Networking", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let career = ProfileQuestion.init(title: "#Career", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let culture = ProfileQuestion.init(title: "#Culture", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let travel = ProfileQuestion.init(title: "#Travel", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let cuisine = ProfileQuestion.init(title: "#Cuisine", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let shopping = ProfileQuestion.init(title: "#Shopping", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let transportation = ProfileQuestion.init(title: "#Transportation", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let history = ProfileQuestion.init(title: "#History", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let hospitality = ProfileQuestion.init(title: "#Hospitality", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let movie = ProfileQuestion.init(title: "#Movie", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let reading = ProfileQuestion.init(title: "#Reading", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let sports = ProfileQuestion.init(title: "#Sports", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let society = ProfileQuestion.init(title: "#Society", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let health = ProfileQuestion.init(title: "#Health", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        return [business, tech, finance, networking, career, culture, travel, cuisine, shopping, transportation, history, hospitality, movie, reading, sports, society, health]
    } ()

    // MARK: UI
    private lazy var nextButton: UIButton = {
        let nextButton = UIButton.init(frame: .zero)
        nextButton.isEnabled = false
        nextButton.setTitle(NSLocalizedString("NextButtonTitle", comment: ""), for: .normal)
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
        interestReasonLabel.text = NSLocalizedString("InterestReasonTitle", comment: "")
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

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let cellWidth = (availableWidth - CGFloat(questionsCollectionNumberOfCellsInRow - 1) * questionsCollectionViewCellSpacing) / CGFloat(questionsCollectionNumberOfCellsInRow)
        return CGSize.init(width: cellWidth, height: questionsCollectionViewCellHeight)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        questions[indexPath.item].isSelected = !questions[indexPath.item].isSelected
        collectionView.reloadItems(at: [indexPath])
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

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(questionsCollectionView)
        view.addSubview(interestReasonLabel)
        view.addSubview(nextButton)

        interestReasonLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentLeadingTrailingMargin).isActive = true
        interestReasonLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentLeadingTrailingMargin).isActive = true
        interestReasonLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: interestReasonLabelTopMargin).isActive = true

        nextButton.widthAnchor.constraint(equalToConstant: nextButtonWidth).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: nextButtonHeight).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -nextButtonBottomMargin).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        questionsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentLeadingTrailingMargin).isActive = true
        questionsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentLeadingTrailingMargin).isActive = true
        questionsCollectionView.topAnchor.constraint(equalTo: interestReasonLabel.bottomAnchor, constant: questionsCollectionViewTopBottomMargin).isActive = true
        questionsCollectionView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -questionsCollectionViewTopBottomMargin).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = NSLocalizedString("completeProfileStep2Title", comment: "")
    }

    // MARK: - Private
    @objc
    func didTapNextButton() {
        guard let userId = AWSMobileClient.default().userSub else { return }
        var interests: [String] = []
        for question in questions {
            if question.isSelected {
                interests.append(question.title)
            }
        }

        userDataFecther.updateUser(id: userId, interests: interests) { (basicUser, error) in
            DispatchQueue.main.async {
                self.title = ""
                self.navigationController?.pushViewController(CompleteProfileViewStep3Controller.init(), animated: true)
            }
        }
    }

    func updateNextButton() {
        var hasSelectedQuestion = false
        for question in questions {
            if question.isSelected {
                hasSelectedQuestion = true
                break
            }
        }
        nextButton.isEnabled = hasSelectedQuestion
        if nextButton.isEnabled {
            nextButton.backgroundColor = .skyBlue
        } else {
            nextButton.backgroundColor = .lightBlueGrey
        }
    }
}

