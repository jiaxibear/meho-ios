//
//  NewsAudioPlayer.swift
//  meho-ios
//
//  Created by Meho Dev on 2/2/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit
import AVFoundation

class NewsAudioPlayer: NSObject {

    static let shared = NewsAudioPlayer.init()

    private var player: AVPlayer?

    var isPlaying = false

    // MARK: - Init
    private override init() {

    }

    // MARK: - Internal
    func playAudio(audioURL: URL) {
        isPlaying = true
        if let player = player {
            player.pause()
        }

        let playerItem = AVPlayerItem.init(url: audioURL)
        player = AVPlayer.init(playerItem: playerItem)
        player?.play()
    }
}
