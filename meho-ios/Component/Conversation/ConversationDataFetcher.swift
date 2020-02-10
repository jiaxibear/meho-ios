//
//  ConversationDataFetcher.swift
//  meho-ios
//
//  Created by Meho Dev on 2/9/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ConversationDataFetcher: NSObject {
    
    // MARK: - Constants
    
    private let fetchDialogsURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/talk/dialogues/"
    
    // MARK: - Properties
    
    private let session = URLSession(configuration: .default)
    
    // MARK: - Public
    
    public func fetchCategories(completionHandler: @escaping ( Array<Category>?, Error?) -> Void) {
        let categoriesURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/talk/dialogues/category/"
        let categoriesURL = URL.init(string: categoriesURLString)
        if categoriesURL != nil {
            let dataCategoriesTask = session.dataTask(with: categoriesURL!, completionHandler: { (data, URLResponse, error) in
                if error != nil {
                    print("There is an error getting the response of categories")
                    completionHandler(nil, error)
                    return
                }
                if data == nil {
                    print("The response of categories is empty")
                    completionHandler(nil, nil)
                    return
                }
                do {
                    if let categoriesJSON = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        let currentCategories = self.parseCurrentCategoriesJSON(categoriesJSON: categoriesJSON)
                        completionHandler(currentCategories, nil)
                    }
                } catch let JSONError as NSError {
                    print("Failed to parse categories JSON: \(JSONError.localizedDescription)")
                    completionHandler(nil, JSONError)
                }
            })
            dataCategoriesTask.resume()
        }
    }
    
    // MARK: - Private
    
    private func parseCurrentCategoriesJSON(categoriesJSON: Dictionary<String, Any>) -> Array<Category>? {
        if let currentCategoriesJSON = categoriesJSON["results"] as? [Dictionary<String, Any>] {
            var currentCategories:[Category] = []
            for currentCategoryJSON in currentCategoriesJSON {
                var category = Category.init()
                if let title = currentCategoryJSON["name"] as? String {
                    category.title = title
                }
                if let identifier = currentCategoryJSON["id"] as? Int {
                    category.identifier = identifier
                }
                if let coverImageIdentifier = currentCategoryJSON["cover_image_id"] as? String {
                    category.coverImageIdentifier = coverImageIdentifier
                }
                if let coverImageURLString = currentCategoryJSON["cover_image"] as? String {
                    let coverImageURL = URL.init(string: coverImageURLString)
                    category.coverImageURL = coverImageURL
                }
                currentCategories.append(category)
            }
            return currentCategories
        }
        return nil
    }
    
}
