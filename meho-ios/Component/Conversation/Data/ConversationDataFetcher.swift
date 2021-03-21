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
                if let audioKey = remoteChapter.audioKey {
                    chapter.contentAudioKey = audioKey
                } else if let audioKey = remoteChapter.audio?.key {
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
}
