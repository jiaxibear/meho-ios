//
//  PictographyViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/15/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class PictographyViewController: UIViewController {

    // MARK: - Properties
    private let featureName: String

    // MARK: - Datamodels
    private let dataFecther = FoundationDataFetcher.init()
    private var pictographList:[Pictograph] = []

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

    init(featureName: String) {
        self.featureName = featureName
        super.init(nibName: nil, bundle: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        // Do any additional setup after loading the view.
        view.backgroundColor = .white


        dataFecther.fetchPictrographList(completionHandler: { (pictographList, error) in
            if (error == nil && pictographList != nil) {
                DispatchQueue.main.async {
                    self.pictographList = pictographList!
                }
            }
        })
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
