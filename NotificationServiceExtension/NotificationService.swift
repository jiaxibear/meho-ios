//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Meho Dev on 6/5/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            let userInfo = request.content.userInfo
            guard let userInfoData = userInfo["data"] as? [AnyHashable: Any], let attachmentURLString = userInfoData["media-url"] as? String else {
                contentHandler(bestAttemptContent)
                return
            }

            guard let attachmentURL = URL.init(string: attachmentURLString) else {
                contentHandler(bestAttemptContent)
                return
            }


            guard let imageData = try? Data.init(contentsOf: attachmentURL) else {
                contentHandler(bestAttemptContent)
                return
            }

            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let temporaryFilename = ProcessInfo().globallyUniqueString.appending(".jpg")
            let temporaryFileURL =
                temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
            guard (try? imageData.write(to: temporaryFileURL, options: .atomic)) != nil else {
                contentHandler(bestAttemptContent)
                return
            }

            guard let attachment = try? UNNotificationAttachment.init(identifier: "", url: temporaryFileURL, options: nil) else {
                contentHandler(bestAttemptContent)
                return
            }
            bestAttemptContent.attachments = [attachment]
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
