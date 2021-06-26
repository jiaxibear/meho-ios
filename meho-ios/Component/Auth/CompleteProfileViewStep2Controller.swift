//
//  CompleteProfileViewStep2Controller.swift
//  meho-ios
//
//  Created by Meho Dev on 8/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient
import FirebaseAnalytics

class CompleteProfileViewStep2Controller: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MehoAnalytics {

    // MARK: - Constants
    private let nextButtonWidth = CGFloat(200)
    private let nextButtonHeight = CGFloat(40)
    private let nextButtonCornerRadius = CGFloat(6)
    private let nextButtonBottomMargin = CGFloat(60)
    private let interestReasonLabelFontSize = CGFloat(18)
    private let interestReasonLabelTopMargin = CGFloat(24)
    private let contentLeadingTrailingMargin = CGFloat(20)
    private let questionCollectionViewCellReuseIdentifier = "questionCollectionViewCellReuseIdentifier"
    private let questionsCollectionViewTopBottomMargin = CGFloat(24)
    private let questionsCollectionViewCellSpacing = CGFloat(20)
    private let questionsCollectionViewCellHeight = CGFloat(150)
    private let questionsCollectionViewCellTitleFontSize = CGFloat(15)
    private let questionsCollectionViewSpecialCellHeight = CGFloat(40)
    private let questionsCollectionNumberOfCellsInRow = 2
    private let questionsCollectionViewMinimumLineSpacing = CGFloat(20)

    // MARK: - Properties
    // MARK: Model
    private let isSingleStep: Bool
    private let userDataFecther = UserDataFetcher.shared

    private lazy var questions: [ProfileQuestion] = {
        let friendsAndFamily = ProfileQuestion.init(title: "Friends & Family", subtitle: nil, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize, imageName: "onboarding_family_and_friends")
        let businessNeeds = ProfileQuestion.init(title: "Business Needs", subtitle: nil, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize, imageName: "onboarding_business_needs")
        let stayInformed = ProfileQuestion.init(title: "Stay Informed", subtitle: nil, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize, imageName: "onboarding_stay_informed")
        let travel = ProfileQuestion.init(title: "Travel & Leisure", subtitle: nil, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize, imageName: "onboarding_travel")
        let language = ProfileQuestion.init(title: "Language & Culture", subtitle: nil, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize, imageName: "onboarding_language_culture")
        let checkItOut = ProfileQuestion.init(title: "Just Check It Out", subtitle: nil, isSelected: false, titleFontSize: questionsCollectionViewCellTitleFontSize, imageName: "onboarding_just_check_it_out")
        return [friendsAndFamily, businessNeeds, stayInformed, travel, language, checkItOut]
    } ()

    // MARK: UI
    private lazy var nextButton: UIButton = {
        let nextButton = UIButton.init(frame: .zero)
        nextButton.isEnabled = false
        if isSingleStep {
            nextButton.setTitle(NSLocalizedString("SaveButtonTitle", comment: ""), for: .normal)
        } else {
            nextButton.setTitle(NSLocalizedString("NextButtonTitle", comment: ""), for: .normal)
        }
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
        questionsCollectionView.register(InterestQuestionCollectionViewCell.self, forCellWithReuseIdentifier: questionCollectionViewCellReuseIdentifier)
        questionsCollectionView.backgroundColor = .white
        questionsCollectionView.contentInset = UIEdgeInsets.init(top: 2, left: 2, bottom: 2, right: 2)
        return questionsCollectionView
    } ()

    // MARK: MehoAnalytics
    lazy var screenName: String = {
        if isSingleStep {
            return "p_meho_profiles_setting_update_goal"
        } else {
            return "p_meho_onboarding_intent"
        }
    } ()

    lazy var screenClass: String = {
        if isSingleStep {
            return "p_meho_profiles_setting"
        } else {
            return "p_meho_onboarding"
        }
    } ()

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let cellWidth = (availableWidth - CGFloat(questionsCollectionNumberOfCellsInRow - 1) * questionsCollectionViewCellSpacing) / CGFloat(questionsCollectionNumberOfCellsInRow)
        return CGSize.init(width: cellWidth, height: questionsCollectionViewCellHeight)
    }

    // MARK: - Init
    init(goals: [String]? = nil, isSingleStep: Bool = false) {
        self.isSingleStep = isSingleStep
        super.init(nibName: nil, bundle: nil)
        if let goals = goals {
            for goal in goals {
                for (index, _) in questions.enumerated() {
                    if questions[index].title == goal {
                        questions[index].isSelected = true
                    }
                }
            }
        }
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(goals: [String]? = nil, isSingleStep: Bool = false)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(goals: [String]? = nil, isSingleStep: Bool = false)")
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        questions[indexPath.item].isSelected = !questions[indexPath.item].isSelected
        collectionView.reloadItems(at: [indexPath])
        updateNextButton()
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let question = questions[indexPath.item]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: questionCollectionViewCellReuseIdentifier, for: indexPath) as? InterestQuestionCollectionViewCell {
            cell.setQuestion(question)
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
        nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -nextButtonBottomMargin).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        questionsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentLeadingTrailingMargin).isActive = true
        questionsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentLeadingTrailingMargin).isActive = true
        questionsCollectionView.topAnchor.constraint(equalTo: interestReasonLabel.bottomAnchor, constant: questionsCollectionViewTopBottomMargin).isActive = true
        questionsCollectionView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -questionsCollectionViewTopBottomMargin).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSingleStep {
            title = NSLocalizedString("UpdateGoalTitle", comment: "")
        } else {
            title = NSLocalizedString("completeProfileStep1Title", comment: "")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }

    // MARK: - Private
    @objc
    func didTapNextButton() {
        guard let userId = AWSMobileClient.default().userSub else { return }
        var goals: [String] = []
        for communication in questions {
            if communication.isSelected {
                goals.append(communication.title)
            }
        }

        userDataFecther.updateUser(id: userId, goals: goals) { (basicUser, error) in
            DispatchQueue.main.async {
                if self.isSingleStep {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.title = ""
                    self.navigationController?.pushViewController(CompleteProfileViewStep3Controller.init(interests: nil, isSingleStep: false), animated: true)
                }
            }
        }
    }

    func updateNextButton() {
        var hasSelected = false
        for communication in questions {
            if communication.isSelected {
                hasSelected = true
                break
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
