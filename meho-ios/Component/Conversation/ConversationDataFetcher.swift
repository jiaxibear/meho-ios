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
    private let fetchCategoriesURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/talk/dialogues/category/"
    
    // MARK: - Properties
    
    private let session = URLSession(configuration: .default)
    
    // MARK: - Public
    
    public func fetchCategories(completionHandler: @escaping ( Array<Category>?, Error?) -> Void) {
        if let categoriesURL = URL.init(string: fetchCategoriesURLString) {
            let dataCategoriesTask = session.dataTask(with: categoriesURL, completionHandler: { (data, URLResponse, error) in
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
        } else {
            completionHandler(nil, nil)
        }
    }
    
    public func fetchDialogs(completionHandler: @escaping ( Array<Dialog>?, Error?) -> Void) {
        if let dialogsURL = URL.init(string: fetchDialogsURLString) {
            let dataCategoriesTask = session.dataTask(with: dialogsURL, completionHandler: { (data, URLResponse, error) in
                if error != nil {
                    print("There is an error getting the response of dialogs")
                    completionHandler(nil, error)
                    return
                }
                if data == nil {
                    print("The response of dialogs is empty")
                    completionHandler(nil, nil)
                    return
                }
                do {
                    if let dialogsJSON = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        let dialogs = self.parseDialogsJSON(dialogsJSON: dialogsJSON)
                        completionHandler(dialogs, nil)
                    }
                } catch let JSONError as NSError {
                    print("Failed to parse dialogs JSON: \(JSONError.localizedDescription)")
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
    
    private func parseDialogsJSON(dialogsJSON: Dictionary<String, Any>) -> Array<Dialog>? {
        if let currentDialogsJSON = dialogsJSON["results"] as? [Dictionary<String, Any>] {
            var currentDialogs:[Dialog] = []
            for currentDialogJSON in currentDialogsJSON {
                var dialog = Dialog.init()
                if let title = currentDialogJSON["title"] as? String {
                    dialog.title = title
                }
                if let titleInLocalLanguage = currentDialogJSON["title_local_language"] as? String {
                    dialog.titleInLocalLanguage = titleInLocalLanguage
                }
                if let coverImageURLString = currentDialogJSON["cover_image"] as? String {
                    let coverImageURL = URL.init(string: coverImageURLString)
                    dialog.coverImageURL = coverImageURL
                }
                currentDialogs.append(dialog)
            }
            return currentDialogs
        }
        return nil
    }
}
