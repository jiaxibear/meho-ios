//
//  WebImageView.swift
//  meho-ios
//
//  Created by Meho Dev on 2/9/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import Foundation

protocol WebImageViewDelegate : AnyObject {
    func webImageViewDidSetImage(webImageView: WebImageView)
}

class WebImageView: UIImageView {

    let imageDataSession = URLSession.init(configuration: .default)
    weak var delegate: WebImageViewDelegate?
    var imageURL:URL? {
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

    
}
