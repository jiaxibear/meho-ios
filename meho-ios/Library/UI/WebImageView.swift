//
//  WebImageView.swift
//  meho-ios
//
//  Created by Meho Dev on 2/9/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import Foundation
import AWSS3
import Amplify
import AmplifyPlugins

protocol WebImageViewDelegate : AnyObject {
    func webImageViewDidSetImage(webImageView: WebImageView)
}

struct S3ImageViewKey {
    let bucket: String
    let key: String
}

class WebImageView: UIImageView {

    let imageDataSession = URLSession.init(configuration: .default)
    weak var delegate: WebImageViewDelegate?
    var imageURL: URL? {
        didSet {
            if self.imageURL != nil {
                self.imageDataSession.dataTask(with: self.imageURL!, completionHandler: { (data, request, error) in
                    if error != nil {
                        print("There is an error getting the image")
                        return
                    }
                    if data == nil {
                        print("The image is empty")
                        return
                    }
                    if request?.url == self.imageURL {
                        if let image = UIImage.init(data: data!) {
                            DispatchQueue.main.async {
                                self.image = image
                                self.delegate?.webImageViewDidSetImage(webImageView: self)
                            }
                        }
                    }
                    }).resume()
            }
        }
    }

    override var image: UIImage? {
        didSet {
            self.delegate?.webImageViewDidSetImage(webImageView: self)
        }
    }

    var imageKey: S3ImageViewKey? {
        didSet {
            if self.imageKey != nil {
                let imageKey = self.imageKey!


                Amplify.Storage.getURL(key: imageKey.key) { event in
                    switch event {
                    case let .success(url):
                        print("Completed: \(url)")
                        self.imageDataSession.dataTask(with: url, completionHandler: { (data, request, error) in
                            if error != nil {
                                print("There is an error getting the image")
                                return
                            }
                            if data == nil {
                                print("The image is empty")
                                return
                            }
                            if request?.url == url {
                                if let image = UIImage.init(data: data!) {
                                    DispatchQueue.main.async {
                                        self.image = image
                                        self.delegate?.webImageViewDidSetImage(webImageView: self)
                                    }
                                }
                            }
                            }).resume()
                    case let .failure(storageError):
                        print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    }
                }
            }
        }
    }
}
