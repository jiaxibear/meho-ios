//
//  ContentEvaluator.swift
//  meho-ios
//
//  Created by Meho Dev on 4/27/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import TAISDK

enum ContentEvaluatorError: Error {
    case server
    case client
}

class ContentEvaluator: NSObject, TAIOralEvaluationDelegate {

    // MARK: - Constants
    private let pronAccuraryMin = Float(60)

    // MARK: - Properties
    private lazy var oralEvaluation: TAIOralEvaluation = {
        let oralEvaluation = TAIOralEvaluation.init()
        oralEvaluation.delegate = self
        return oralEvaluation
    } ()

    private lazy var param: TAIOralEvaluationParam = {
        let param = TAIOralEvaluationParam.init()
        param.sessionId = UUID().uuidString
        param.appId = "1300579049"
        param.workMode = .once
        param.evalMode = .paragraph
        param.workMode = .stream
        param.storageMode = .disable
        param.serverType = .chinese
        param.scoreCoeff = 1.0
        param.fileType = .mp3
        param.secretId = "AKIDiHaeZOnGK8h083q4B2cy3sUsBF4KYctt"
        param.secretKey = "tWsyoQo8D1auymOozu4A0pOzLPCk49xX"
        param.textMode = .noraml
        return param
    } ()

    private var content: String!
    private var completion: ((Result<ContentEvaluationResult, Error>) -> Void)!

    // MARK: - Internal
    func evaluate(content: String, audioFileURL: URL, completion: @escaping (Result<ContentEvaluationResult, Error>) -> Void) {
        if (self.content != nil) {
            completion(.failure(ContentEvaluatorError.client))
            return
        }
        self.content = content
        self.completion = completion
        let audioConverter = AudioConverter.init()
        if let mp3FileName = audioConverter.mp3File(fromM4aFile: audioFileURL.path) {
            let mp3FileURL = URL.init(fileURLWithPath: mp3FileName)
            let data = TAIOralEvaluationData.init()
            data.bEnd = true
            data.seqId = 1
            data.audio = try? Data.init(contentsOf: mp3FileURL)
            param.refText = content
            oralEvaluation.oralEvaluation(param, data: data, callback: { (error) in
                if (error?.code != TAIErrCode.succ) {
                    self.content = nil
                    completion(.failure(ContentEvaluatorError.server))
                }
            })
        }
    }

    // MARK: - TAIOralEvaluationDelegate
    func oralEvaluation(_ oralEvaluation: TAIOralEvaluation!, onEvaluateData data: TAIOralEvaluationData!, result: TAIOralEvaluationRet!, error: TAIError!) {
        if result != nil {
            let suggestScore = result.suggestedScore
            let scoredContent = self.scoredContent(result: result)
            let contentEvaluationResult = ContentEvaluationResult.init(score: suggestScore, scoredContent: scoredContent)
            completion(.success(contentEvaluationResult))
        }
        content = nil
        completion = nil
    }

    func oralEvaluation(_ oralEvaluation: TAIOralEvaluation!, onVolumeChanged volume: Int) {

    }

    func onEndOfSpeech(in oralEvaluation: TAIOralEvaluation!) {

    }

    // MARK: - Private
    private func scoredContent(result: TAIOralEvaluationRet) -> NSAttributedString {
        let scoredContent = NSMutableAttributedString.init(string: content)
        if let scoredWords = result.words {
            if scoredWords.count == 0 {
                scoredContent.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor.coral, range: NSRange.init(location: 0, length: content.count))
            } else {
                var scoredWordsIndex = 0
                for (index, character) in content.enumerated() {
                    if (scoredWordsIndex >= scoredWords.count) {
                        scoredContent.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor.wisteriaPurple, range: NSRange.init(location: index, length: 1))
                    } else {
                        let contentWord = String(character)
                        let scoredWord = scoredWords[scoredWordsIndex]
                        if contentWord == scoredWord.word {
                            if scoredWord.pronAccuracy > pronAccuraryMin {
                                scoredContent.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor.wisteriaPurple, range: NSRange.init(location: index, length: 1))
                            } else {
                                scoredContent.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor.coral, range: NSRange.init(location: index, length: 1))
                            }
                            scoredWordsIndex = scoredWordsIndex + 1;
                        } else {
                            scoredContent.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor.wisteriaPurple, range: NSRange.init(location: index, length: 1))
                        }
                    }
                }
            }
        }
        return scoredContent
    }
}
