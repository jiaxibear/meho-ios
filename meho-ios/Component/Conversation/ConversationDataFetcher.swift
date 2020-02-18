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
    
    public func fetchDialogs(category: String?, difficulty: String?, completionHandler: @escaping ( Array<Dialog>?, Error?) -> Void) {
        if var dialogsURLComponents = URLComponents.init(string: fetchDialogsURLString) {
            var queryItems:[URLQueryItem] = []
            queryItems.append(URLQueryItem.init(name: "category", value: category))
            queryItems.append(URLQueryItem.init(name: "difficulty_level", value: difficulty))
            dialogsURLComponents.queryItems = queryItems
            if let dialogsURL = dialogsURLComponents.url {
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
    
    private func parseDialogsJSON(dialogsJSON: Dictionary<String, Any>) -> [Dialog]? {
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
                if let chaptersJSON = currentDialogJSON["chapter"] as? [Dictionary<String, Any>] {
                    var chapters:[Chapter] = []
                    for chapterJSON in chaptersJSON {
                        var chapter = Chapter.init()
                        if let content = chapterJSON["content"] as? String {
                            chapter.content = content
                        }
                        if let contentAudioURLString = chapterJSON["content_related_audio"] as? String {
                            if let contentAudioURL = URL.init(string: contentAudioURLString) {
                                chapter.contentAudioURL = contentAudioURL
                            }
                        }
                        if let contentPinyin = chapterJSON["content_pinyin"] as? String {
                            chapter.contentPinyin = contentPinyin
                        }
                        if let sequence = chapterJSON["seq_number"] as? NSNumber {
                            chapter.sequence = sequence.intValue
                        }
                        if let contentInLocalLanguage = chapterJSON["content_local_language"] as? String {
                            chapter.contentInLocalLanguage = contentInLocalLanguage
                        }
                        chapters.append(chapter)
                    }
                    dialog.chapters = chapters
                }
                currentDialogs.append(dialog)
            }
            return currentDialogs
        }
        return nil
    }
}
