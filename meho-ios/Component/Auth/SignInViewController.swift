//
//  SignInViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 2/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // uncomment next line if you want enforce login every time app launch
        // logout()
        self.checkSignIn()
    }
    
    @objc
    func logout() {
        AWSMobileClient.default().signOut { (error) in
            guard error == nil else { return }
            self.checkSignIn()
        }
    }
    
    func checkSignIn() {
        if AWSMobileClient.default().isSignedIn {
            // sign in func
            self.navigationController? .setViewControllers([MainViewController.init()], animated: false)
        }
        else {
            let options = SignInUIOptions(canCancel: false)
            AWSMobileClient.default().showSignIn(navigationController: self.navigationController!, signInUIOptions: options) { (userState, error) in
                guard error == nil else { return }
                guard let state =   userState else { return }
                
                switch state {
                case .signedIn:
                    self.navigationController? .setViewControllers([MainViewController.init()], animated: false)
                default:
                    print ("default")
                }
            }
        }
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
