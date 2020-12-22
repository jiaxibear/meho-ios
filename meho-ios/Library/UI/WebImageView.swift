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
import Kingfisher

protocol WebImageViewDelegate : AnyObject {
    func webImageViewDidSetImage(webImageView: WebImageView)
}

struct S3ResourceKey {
    let bucket: String
    let key: String
}

class WebImageView: UIImageView {

    weak var delegate: WebImageViewDelegate?
    var imageURL: URL? {
        didSet {
            if self.imageURL != nil {
                self.kf.setImage(with: imageURL, placeholder: nil, options: nil, progressBlock: nil) { result in
                    switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        print("There is an error getting the image: \(error)")
                        break
                    }
                }
            }
        }
    }

    override var image: UIImage? {
        didSet {
            if image != nil {
                self.notifyDelegate()
            }
        }
    }

    var imageKey: S3ResourceKey? {
        didSet {
            guard let key = imageKey?.key else {
                return
            }

            let imageCache = ImageCache.default
            if imageCache.isCached(forKey: key) {
                imageCache.retrieveImage(forKey: key) { result in
                    switch result {
                    case .success(let value):
                        self.image = value.image
                    case .failure(let error):
                        print("There is an error getting the image: \(error)")
                    }
                }
            } else {
                Amplify.Storage.getURL(key: key) { event in
                    switch event {
                    case let .success(imageURL):
                        let imageResource = ImageResource.init(downloadURL: imageURL, cacheKey: key)
                        DispatchQueue.main.async {
                            self.kf.setImage(with: imageResource, placeholder: nil, options: nil, progressBlock: nil) { result in
                                switch result {
                                case .success(_):
                                    break
                                case .failure(let error):
                                    print("There is an error getting the image: \(error)")
                                }
                            }
                        }
                    case let .failure(storageError):
                        print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    }
                }
            }
        }
    }

    func notifyDelegate() {
        DispatchQueue.main.async {
            self.delegate?.webImageViewDidSetImage(webImageView: self)
        }
    }
}
