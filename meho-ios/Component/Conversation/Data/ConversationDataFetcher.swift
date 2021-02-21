//
//  ConversationDataFetcher.swift
//  meho-ios
//
//  Created by Meho Dev on 2/9/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSAppSync

class ConversationDataFetcher: NSObject {

    // MARK: - Constants

    private let fetchDetailedDialogURLString = "https://150uu7wn8b.execute-api.us-west-2.amazonaws.com/dev/getDetailedDialogue"
    private let fetchDialogsURLString = "https://150uu7wn8b.execute-api.us-west-2.amazonaws.com/dev/getDialoguesByCategory"
    private let categoryQueryItemName = "category_id"
    private let difficultyQueryItemName = "level"
    private let dialogIDQueryItemName = "dialogue_id"
    private let fetchCategoriesURLString = "https://150uu7wn8b.execute-api.us-west-2.amazonaws.com/dev/getAllCategories"
    private let fetchFeaturedDialogsURLString = "https://150uu7wn8b.execute-api.us-west-2.amazonaws.com/dev/getFeaturedDialogues"
    private let fetchMostPopularDialogsURLString = "https://150uu7wn8b.execute-api.us-west-2.amazonaws.com/dev/getMostPopularDialogues"

    // MARK: - Properties
    private var appSyncClient: AWSAppSyncClient?
    private let session = URLSession(configuration: .default)

    // MARK: - Init
    override init() {
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
    }

    // MARK: - Public
    public func fetchCategories(maybeLimit:Int?, completionHandler: @escaping ( Array<Category>?, Error?) -> Void) {
        let q = ListTagsQuery()
        q.limit = 100
        appSyncClient?.fetch(query: q) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, nil)
                return
            }
            guard let items = result?.data?.listTags?.items, items.count > 0 else {
                completionHandler(nil, nil)
                return
            }

            var categoryList:[Category] = []
            for item in items {
                guard let tag = item else {continue}
                guard let dialogueCount = tag.dialogues?.items?.count, dialogueCount > 0 else {continue}
                var category = Category.init()
                category.identifier = tag.id
                category.title = tag.content
                if let coverImageKey = tag.image?.key {
                    category.coverImageKey = coverImageKey
                }
                if let isTagFeatured = tag.isFeatured {
                    category.isFeatured = isTagFeatured
                }
                if let featuredSlogan = tag.featuredSlogan {
                    category.featuredSlogan = featuredSlogan
                }
                if let featuredImageKey = tag.featuredImage?.key {
                    category.featuredImageKey = featuredImageKey
                }

                if category.isFeatured {
                    categoryList.insert(category, at: 0)
                } else {
                    categoryList.append(category)
                }
            }

            // post operations of category list: maybe apply limit
            if let limit = maybeLimit {
                let limitedCategories:Array<Category> = Array(categoryList.prefix(limit))
                return completionHandler(limitedCategories, nil)
            } else {
                return completionHandler(categoryList, nil)
            }
        }
    }

    public func fetchDialoguesOfCategory(categoryID:String, completionHandler: @escaping ( Array<Dialog>?, Error?) -> Void) {
        let q = GetTagQuery(id: categoryID)
        appSyncClient?.fetch(query: q) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, nil)
                return
            }
            guard let items = result?.data?.getTag?.dialogues?.items, items.count > 0 else {
                completionHandler(nil, nil)
                return
            }

            var dialogueList:[Dialog] = []
            for item in items {
                guard let remoteDialogue = item?.dialogue else {continue}
                var dialog = Dialog.init()
                dialog.identifier = remoteDialogue.id
                if let titleEn = remoteDialogue.titleEn {
                    dialog.titleInLocalLanguage = titleEn
                }
                if let titleZh = remoteDialogue.titleZh {
                    dialog.title = titleZh
                }
                if let difficulty = remoteDialogue.difficultyLevel {
                    if difficulty == DifficultyIdentifier.advanced.rawValue {
                        dialog.difficulty = .advanced
                    } else if difficulty == DifficultyIdentifier.intermediate.rawValue {
                        dialog.difficulty = .intermediate
                    } else if difficulty == DifficultyIdentifier.beginner.rawValue {
                        dialog.difficulty = .beginner
                    }
                }
                if let whyYouShouldLearn = remoteDialogue.whyYouShouldLearnThisDialogue {
                    dialog.whyYouShouldLearn = whyYouShouldLearn
                }
                if let image_key = remoteDialogue.coverImage?.key {
                    dialog.coverImageKey = image_key
                }

                // default graphQL generation doesn't include detailed chapers
                dialogueList.append(dialog)
            }
            completionHandler(dialogueList, nil)
        }
    }

    public func fetchDetailedDialog(dialogID:String, completionHandler: @escaping ( Dialog?, Error?) -> Void) {
        let q = GetDialogueQuery(id: dialogID)
        appSyncClient?.fetch(query: q) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, nil)
                return
            }
            guard let remoteDialogue = result?.data?.getDialogue else {
                completionHandler(nil, nil)
                return
            }

            var dialog = Dialog.init()
            dialog.identifier = remoteDialogue.id
            if let titleEn = remoteDialogue.titleEn {
                dialog.titleInLocalLanguage = titleEn
            }
            if let titleZh = remoteDialogue.titleZh {
                dialog.title = titleZh
            }
            if let difficulty = remoteDialogue.difficultyLevel {
                if difficulty == DifficultyIdentifier.advanced.rawValue {
                    dialog.difficulty = .advanced
                } else if difficulty == DifficultyIdentifier.intermediate.rawValue {
                    dialog.difficulty = .intermediate
                } else if difficulty == DifficultyIdentifier.beginner.rawValue {
                    dialog.difficulty = .beginner
                }
            }
            if let whyYouShouldLearn = remoteDialogue.whyYouShouldLearnThisDialogue {
                dialog.whyYouShouldLearn = whyYouShouldLearn
            }
            if let image_key = remoteDialogue.coverImage?.key {
                dialog.coverImageKey = image_key
            }

            // parse chapters of the dialogue
            guard let remoteChapters = remoteDialogue.chapters?.items, remoteChapters.count > 0 else {
                completionHandler(dialog, nil)
                return
            }
            var chapterList:[Chapter] = []
            for maybeRemoteChapter in remoteChapters {
                guard let remoteChapter = maybeRemoteChapter else { continue }
                var chapter = Chapter.init()
                chapter.identifier = remoteChapter.id
                if let contentEn = remoteChapter.contentEn {
                    chapter.contentInLocalLanguage = contentEn
                }
                if let contentPinyin = remoteChapter.contentPinyin {
                    chapter.contentPinyin = contentPinyin
                }
                if let contentInLocalLanguage = remoteChapter.contentZh {
                    chapter.content = contentInLocalLanguage
                }
                if let seqNumber = remoteChapter.seqNumber {
                    chapter.sequence = seqNumber
                }
                if let role = remoteChapter.npcRole {
                    chapter.role = role
                }
                if let roleAvatar = remoteChapter.npcAvatar {
                    chapter.roleAvatar = S3ResourceKey.init(bucket: roleAvatar.bucket, key: roleAvatar.key)
                }
                if let audioKey = remoteChapter.audio?.key {
                    chapter.contentAudioKey = audioKey
                }
                chapterList.append(chapter)
            }
            chapterList.sort{ $0.sequence < $1.sequence }
            dialog.chapters = chapterList

            // default graphQL generation doesn't include detailed chapers
            completionHandler(dialog, nil)
        }
    }

    public func fetchMostPopularDialogs(difficulty: String?, completionHandler: @escaping ( Array<Dialog>?, Error?) -> Void) {
        let q = GetDialoguesByStatusQuery()
        q.status = "PUBLISHED"
        let popularFilter = ModelDialogueFilterInput.init(markAsMostPopular: ModelBooleanInput.init(eq: true))
        q.filter = popularFilter
        appSyncClient?.fetch(query: q) { (result, error) in
            print (error?.localizedDescription as Any)
            guard error == nil else {
                completionHandler(nil, nil)
                return
            }
            guard let items = result?.data?.getDialoguesByStatus?.items, items.count > 0 else {
                completionHandler(nil, nil)
                return
            }

            var dialogueList:[Dialog] = []
            for item in items {
                guard let remoteDialogue = item else {continue}
                var dialog = Dialog.init()
                dialog.identifier = remoteDialogue.id
                if let titleEn = remoteDialogue.titleEn {
                    dialog.titleInLocalLanguage = titleEn
                }
                if let titleZh = remoteDialogue.titleZh {
                    dialog.title = titleZh
                }
                if let difficulty = remoteDialogue.difficultyLevel {
                    if difficulty == DifficultyIdentifier.advanced.rawValue {
                        dialog.difficulty = .advanced
                    } else if difficulty == DifficultyIdentifier.intermediate.rawValue {
                        dialog.difficulty = .intermediate
                    } else if difficulty == DifficultyIdentifier.beginner.rawValue {
                        dialog.difficulty = .beginner
                    }
                }
                if let whyYouShouldLearn = remoteDialogue.whyYouShouldLearnThisDialogue {
                    dialog.whyYouShouldLearn = whyYouShouldLearn
                }
                if let image_key = remoteDialogue.coverImage?.key {
                    dialog.coverImageKey = image_key
                }
                // default graphQL generation doesn't include detailed chapers
                dialogueList.append(dialog)
            }
            completionHandler(dialogueList, nil)
        }
    }

    // MARK: - BELOW ARE ALL DEPRECATED RESTFUL CALL AND PARSING CODE
    public func fetchCategoriesRest(completionHandler: @escaping ( Array<Category>?, Error?) -> Void) {
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
                    if let categoriesJSON = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                        let currentCategories = self.parseCurrentCategoriesJSON(categoriesJSON: categoriesJSON)
                        completionHandler(currentCategories, nil)
                    }
                } catch let JSONError as NSError {
                    print("Failed to parse featured categories JSON: \(JSONError.localizedDescription)")
                    completionHandler(nil, JSONError)
                }
            })
            dataCategoriesTask.resume()
        } else {
            completionHandler(nil, nil)
        }
    }

    public func fetchMostPopularDialogsRest(difficulty: String?, completionHandler: @escaping ( Array<Dialog>?, Error?) -> Void) {
        if var fetchMostPopularDialogsURLComponent = URLComponents.init(string: fetchMostPopularDialogsURLString) {
            if difficulty != nil {
                var queryItems:[URLQueryItem] = []
                queryItems.append(URLQueryItem.init(name: difficultyQueryItemName, value: difficulty))
                fetchMostPopularDialogsURLComponent.queryItems = queryItems
            }
            if let fetchMostPopularDialogsURL = fetchMostPopularDialogsURLComponent.url {
                let dataCategoriesTask = session.dataTask(with: fetchMostPopularDialogsURL, completionHandler: { (data, URLResponse, error) in
                    if error != nil {
                        print("There is an error getting the response of most popular dialogs")
                        completionHandler(nil, error)
                        return
                    }
                    if data == nil {
                        print("The response of most popular dialogs is empty")
                        completionHandler(nil, nil)
                        return
                    }
                    do {
                        if let dialogsJSON = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                            let dialogs = self.parseDialogsJSON(dialogsJSON: dialogsJSON)
                            completionHandler(dialogs, nil)
                        } else {
                            completionHandler(nil, nil)
                        }
                    } catch let JSONError as NSError {
                        print("Failed to parse most popular dialogs JSON: \(JSONError.localizedDescription)")
                        completionHandler(nil, JSONError)
                    }
                })
                dataCategoriesTask.resume()
            } else {
                completionHandler(nil, nil)
            }
        } else {
            completionHandler(nil, nil)
        }
    }

    public func fetchFeaturedDialogs(difficulty: String?, completionHandler: @escaping ( Array<Dialog>?, Error?) -> Void) {
        if var fetchFeaturedDialogsURLComponents = URLComponents.init(string: fetchFeaturedDialogsURLString) {
            if difficulty != nil {
                var queryItems:[URLQueryItem] = []
                queryItems.append(URLQueryItem.init(name: difficultyQueryItemName, value: difficulty))
                fetchFeaturedDialogsURLComponents.queryItems = queryItems
            }
            if let fetchFeaturedDialogsURL = fetchFeaturedDialogsURLComponents.url {
                let dataCategoriesTask = session.dataTask(with: fetchFeaturedDialogsURL, completionHandler: { (data, URLResponse, error) in
                    if error != nil {
                        print("There is an error getting the response of featured dialogs")
                        completionHandler(nil, error)
                        return
                    }
                    if data == nil {
                        print("The response of featured dialogs is empty")
                        completionHandler(nil, nil)
                        return
                    }
                    do {
                        if let dialogsJSON = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                            let dialogs = self.parseDialogsJSON(dialogsJSON: dialogsJSON)
                            completionHandler(dialogs, nil)
                        } else {
                            completionHandler(nil, nil)
                        }
                    } catch let JSONError as NSError {
                        print("Failed to parse featured dialogs JSON: \(JSONError.localizedDescription)")
                        completionHandler(nil, JSONError)
                    }
                })
                dataCategoriesTask.resume()
            } else {
                completionHandler(nil, nil)
            }
        } else {
            completionHandler(nil, nil)
        }
    }


    public func fetchDetailedDialogRest(dialogID: String, completionHandler: @escaping ( Dialog?, Error?) -> Void) {
        if var fetchDetailedDialogURLComponent = URLComponents.init(string: fetchDetailedDialogURLString) {
            let quertItem = URLQueryItem.init(name: dialogIDQueryItemName, value: dialogID)
            fetchDetailedDialogURLComponent.queryItems = [quertItem]
            if let fetchDetailedDialogURL = fetchDetailedDialogURLComponent.url {
                let detailedDialogDataTask = session.dataTask(with: fetchDetailedDialogURL, completionHandler: { (data, URLResponse, error) in
                    if error != nil {
                        print("There is an error getting the response of the detailed dialog")
                        completionHandler(nil, error)
                        return
                    }
                    if data == nil {
                        print("The response of the detailed dialog is empty")
                        completionHandler(nil, nil)
                        return
                    }
                    do {
                        if let detailedDialogJSON = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            let detailedDialog = self.parseDialogJSON(dialogJSON: detailedDialogJSON)
                            completionHandler(detailedDialog, nil)
                        } else {
                            completionHandler(nil, nil)
                        }
                    } catch let JSONError as NSError {
                        print("Failed to parse the detailed dialog JSON: \(JSONError.localizedDescription)")
                        completionHandler(nil, JSONError)
                    }
                })
                detailedDialogDataTask.resume()
            } else {
                completionHandler(nil, nil)
            }
        } else {
            completionHandler(nil, nil)
        }
    }

    public func fetchDialogs(category: String, difficulty: String?, completionHandler: @escaping ( Array<Dialog>?, Error?) -> Void) {
        if var dialogsURLComponents = URLComponents.init(string: fetchDialogsURLString) {
            var queryItems:[URLQueryItem] = []
            queryItems.append(URLQueryItem.init(name: categoryQueryItemName, value: category))
            if difficulty != nil {
                queryItems.append(URLQueryItem.init(name: difficultyQueryItemName, value: difficulty))
            }
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
                        if let dialogsJSON = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                            let dialogs = self.parseDialogsJSON(dialogsJSON: dialogsJSON)
                            completionHandler(dialogs, nil)
                        } else {
                            completionHandler(nil, nil)
                        }
                    } catch let JSONError as NSError {
                        print("Failed to parse dialogs JSON: \(JSONError.localizedDescription)")
                        completionHandler(nil, JSONError)
                    }
                })
                dataCategoriesTask.resume()
            } else {
                completionHandler(nil, nil)
            }
        } else {
            completionHandler(nil, nil)
        }
    }

    // MARK: - Private

    private func parseCurrentCategoriesJSON(categoriesJSON: [[String: Any]]) -> Array<Category> {
        var currentCategories:[Category] = []
        for currentCategoryJSON in categoriesJSON {
            var category = Category.init()
            if let title = currentCategoryJSON["name"] as? String {
                category.title = title
            }
            if let identifier = currentCategoryJSON["id"] as? String {
                category.identifier = identifier
            }
            if let coverImageIdentifier = currentCategoryJSON["cover_image_id"] as? String {
                category.coverImageKey = coverImageIdentifier
            }
            if let coverImageURLString = currentCategoryJSON["cover_image"] as? String {
                let coverImageURL = URL.init(string: coverImageURLString)
                category.coverImageURL = coverImageURL
            }
            currentCategories.append(category)
        }
        return currentCategories
    }

    private func parseDialogJSON(dialogJSON: [String : Any]) -> Dialog {
        var dialog = Dialog.init()
        if let identifier = dialogJSON["id"] as? String {
            dialog.identifier = identifier
        }
        if let title = dialogJSON["title"] as? String {
            dialog.title = title
        }
        if let whyYouShouldLearn = dialogJSON["why_you_should_learn"] as? String {
            dialog.whyYouShouldLearn = whyYouShouldLearn
        }
        if let titleInLocalLanguage = dialogJSON["title_local_language"] as? String {
            dialog.titleInLocalLanguage = titleInLocalLanguage
        }
        if let coverImageURLString = dialogJSON["cover_image"] as? String {
            let coverImageURL = URL.init(string: coverImageURLString)
            dialog.coverImageURL = coverImageURL
        }
        if let difficulty = dialogJSON["difficulty_level"] as? String {
            if difficulty == DifficultyIdentifier.advanced.rawValue {
                dialog.difficulty = .advanced
            } else if difficulty == DifficultyIdentifier.intermediate.rawValue {
                dialog.difficulty = .intermediate
            } else if difficulty == DifficultyIdentifier.beginner.rawValue {
                dialog.difficulty = .beginner
            }
        }
        if let chaptersJSON = dialogJSON["chapters"] as? [Dictionary<String, Any>] {
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
                if let role = chapterJSON["role"] as? String {
                    chapter.role = role
                }
                if let identifier = chapterJSON["id"] as? String {
                    chapter.identifier = identifier
                }
                chapters.append(chapter)
            }
            dialog.chapters = chapters
        }
        return dialog
    }

    private func parseDialogsJSON(dialogsJSON: [Dictionary<String, Any>]) -> [Dialog] {
        var dialogs:[Dialog] = []
        for dialogJSON in dialogsJSON {
            let dialog = parseDialogJSON(dialogJSON: dialogJSON)
            dialogs.append(dialog)
        }
        return dialogs
    }
}
