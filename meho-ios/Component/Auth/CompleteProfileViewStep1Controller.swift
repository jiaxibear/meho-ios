//
//  CompleteProfileViewStep1Controller.swift
//  meho-ios
//
//  Created by Meho Dev on 8/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

class CompleteProfileViewStep1Controller: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    enum CompleteProfileViewStep1Section: Int {
        case communication = 0
        case general = 1
    }

    // MARK: - Constants
    private let nextButtonWidth = CGFloat(200)
    private let nextButtonHeight = CGFloat(40)
    private let nextButtonCornerRadius = CGFloat(18)
    private let nextButtonBottomMargin = CGFloat(80)
    private let interestReasonLabelFontSize = CGFloat(18)
    private let interestReasonLabelTopMargin = CGFloat(40)
    private let contentLeadingTrailingMargin = CGFloat(20)
    private let questionCollectionViewCellReuseIdentifier = "questionCollectionViewCellReuseIdentifier"
    private let questionCollectionViewHeaderReuseIdentifier = "questionCollectionViewHeaderReuseIdentifier"
    private let questionsCollectionViewTopBottomMargin = CGFloat(24)
    private let questionsCollectionViewCellSpacing = CGFloat(20)
    private let questionsCollectionViewCellHeight = CGFloat(80)
    private let questionsCollectionViewCellTitleFontSize = CGFloat(16)
    private let questionsCollectionViewSpecialCellHeight = CGFloat(40)
    private let questionsCollectionNumberOfCellsInRow = 3
    private let questionsCollectionViewSectionTopBottomInset = CGFloat(30)
    private let questionsCollectionViewMinimumLineSpacing = CGFloat(40)

    // MARK: - Properties
    // MARK: Model
    private let userDataFecther = UserDataFetcher.init()
    private let sections = [CompleteProfileViewStep1Section.communication, CompleteProfileViewStep1Section.general]

    private lazy var communicationQuestions: [ProfileQuestion] = {
        let friendsAndFamily = ProfileQuestion.init(title: "Friends & Family", subtitle: nil, color: .skyBlue, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let colleagues = ProfileQuestion.init(title: "Colleagues", subtitle: nil, color: .periwinkleBlueTwo, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let businessContacts = ProfileQuestion.init(title: "Business Contacts", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        return [friendsAndFamily, colleagues, businessContacts]
    } ()

    private lazy var generalQuestions: [ProfileQuestion] = {
        let consumeContent = ProfileQuestion.init(title: "Consume Content", subtitle: nil, color: .skyBlue, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let travel = ProfileQuestion.init(title: "Travel", subtitle: nil, color: .periwinkleBlueTwo, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let work = ProfileQuestion.init(title: "Work for Chinese Companies", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        let checkItOut = ProfileQuestion.init(title: "Just to Check It Out", subtitle: nil, color: .wisteriaPurple, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize)
        return [consumeContent, travel, work, checkItOut]
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
        questionsCollectionView.register(QuestionHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: questionCollectionViewHeaderReuseIdentifier)
        questionsCollectionView.backgroundColor = .white
        return questionsCollectionView
    } ()

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        if sections[indexPath.section] == .general && indexPath.item == generalQuestions.count - 1 {
            return CGSize.init(width: availableWidth, height: questionsCollectionViewSpecialCellHeight)
        }
        let cellWidth = (availableWidth - CGFloat(questionsCollectionNumberOfCellsInRow - 1) * questionsCollectionViewCellSpacing) / CGFloat(questionsCollectionNumberOfCellsInRow)
        return CGSize.init(width: cellWidth, height: questionsCollectionViewCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var headerTitle: String
        switch sections[section] {
        case .communication:
            headerTitle = NSLocalizedString("communicationSelectionsText", comment: "")
        case .general:
            headerTitle = NSLocalizedString("otherSelectionsText", comment: "")
        }
        let headerWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        return CGSize.init(width: 0, height: QuestionHeaderReusableView.heightForTitle(with: headerWidth, title: headerTitle))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: questionsCollectionViewSectionTopBottomInset, left: 0, bottom: questionsCollectionViewSectionTopBottomInset, right: 0)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .communication:
            communicationQuestions[indexPath.item].isSelected = !communicationQuestions[indexPath.item].isSelected
        case .general:
            generalQuestions[indexPath.item].isSelected = !generalQuestions[indexPath.item].isSelected
        }
        collectionView.reloadItems(at: [indexPath])
        updateNextButton()
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: questionCollectionViewHeaderReuseIdentifier, for: indexPath) as? QuestionHeaderReusableView{
                switch sections[indexPath.section] {
                case .communication:
                    headerView.setTitle(title: NSLocalizedString("communicationSelectionsText", comment: ""))
                case .general:
                     headerView.setTitle(title: NSLocalizedString("otherSelectionsText", comment: ""))
                }
                return headerView
            }
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var question: ProfileQuestion
        switch sections[indexPath.section] {
        case .communication:
            question = communicationQuestions[indexPath.item]
        case .general:
            question = generalQuestions[indexPath.item]
        }
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: questionCollectionViewCellReuseIdentifier, for: indexPath) as? QuestionCollectionViewCell {
            cell.setQuestion(question)
            return cell
        }
        return UICollectionViewCell.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .communication:
            return communicationQuestions.count
        case .general:
            return generalQuestions.count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
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
        title = NSLocalizedString("completeProfileStep1Title", comment: "")
    }

    // MARK: - Private
    @objc
    func didTapNextButton() {
        guard let userId = AWSMobileClient.default().userSub else { return }
        var goals: [String] = []
        for communication in communicationQuestions {
            if communication.isSelected {
                goals.append(communication.title)
            }
        }
        for general in generalQuestions {
            if general.isSelected {
                goals.append(general.title)
            }
        }

        userDataFecther.updateUser(id: userId, goals: goals) { (basicUser, error) in
            DispatchQueue.main.async {
                self.title = ""
                self.navigationController?.pushViewController(CompleteProfileViewStep2Controller.init(), animated: true)
            }
        }
    }

    func updateNextButton() {
        var hasSelected = false
        for communication in communicationQuestions {
            if communication.isSelected {
                hasSelected = true
                break
            }
        }
        if !hasSelected {
            for general in generalQuestions {
                if general.isSelected {
                    hasSelected = true
                    break
                }
            }
        }
        nextButton.isEnabled = hasSelected
        if nextButton.isEnabled {
            nextButton.backgroundColor = .skyBlue
        } else {
            nextButton.backgroundColor = .lightBlueGrey
        }
    }
}
