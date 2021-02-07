//
//  NewsAudioPlayer.swift
//  meho-ios
//
//  Created by Meho Dev on 2/2/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class NewsAudioPlayer: NSObject {

    private let moveDuration = Double(5)

    static let shared = NewsAudioPlayer.init()

    private var player: AVPlayer?
    private var observation: NSKeyValueObservation?

    var newsPlayingNowView: NewsPlayingNowView?
    var isPlaying = false

    // MARK: - Init
    private override init() {

    }

    // MARK: - Internal
    func playAudio(audioURL: URL, title: String, coverImageKey: S3ResourceKey?) {
        isPlaying = true
        if let player = player {
            player.pause()
        }

        let playerItem = AVPlayerItem.init(url: audioURL)
        let currentPlayer = AVPlayer.init(playerItem: playerItem)
        player = currentPlayer
        currentPlayer.play()
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle : title,
            MPNowPlayingInfoPropertyPlaybackRate : currentPlayer.rate,
            MPNowPlayingInfoPropertyElapsedPlaybackTime : playerItem.currentTime().seconds
        ]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        observation = playerItem.observe(\AVPlayerItem.duration) { (playerItem, change) in
            let duration = playerItem.duration
            if duration != .indefinite {
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration.seconds
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }

        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        let changePlaybackPositionCommand = remoteCommandCenter.changePlaybackPositionCommand
        changePlaybackPositionCommand.isEnabled = true
        changePlaybackPositionCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            guard let player = self.player else {
                return .noSuchContent
            }
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            let newTime = event.positionTime
            player.seek(to: CMTimeMakeWithSeconds(newTime, preferredTimescale: player.currentTime().timescale), toleranceBefore: .zero, toleranceAfter: .zero)
            if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = newTime
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
            return .success
        }

        let playCommand = remoteCommandCenter.playCommand
        playCommand.isEnabled = true
        playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            guard let player = self.player else {
                return .noSuchContent
            }
            player.play()
            return .success
        }

        let pauseCommand = remoteCommandCenter.pauseCommand
        pauseCommand.isEnabled = true
        pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            guard let player = self.player else {
                return .noSuchContent
            }
            player.pause()
            return .success
        }

        let skipForwardCommand = remoteCommandCenter.skipForwardCommand
        skipForwardCommand.preferredIntervals = [ NSNumber.init(value: moveDuration)]
        skipForwardCommand.isEnabled = true
        skipForwardCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            guard let player = self.player, let duration = player.currentItem?.duration.seconds else {
                return .noSuchContent
            }

            guard let event = event as? MPSkipIntervalCommandEvent else {
                return .commandFailed
            }

            let current = player.currentTime().seconds
            let newTime = min(duration, current + event.interval)
            player.seek(to: CMTimeMakeWithSeconds(newTime, preferredTimescale: player.currentTime().timescale), toleranceBefore: .zero, toleranceAfter: .zero)
            if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = newTime
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
            return .success
        }
        
        let skipBackwardCommand = remoteCommandCenter.skipBackwardCommand
        skipBackwardCommand.preferredIntervals = [ NSNumber.init(value: moveDuration)]
        skipBackwardCommand.isEnabled = true
        skipBackwardCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            guard let player = self.player else {
                return .noSuchContent
            }

            guard let event = event as? MPSkipIntervalCommandEvent else {
                return .commandFailed
            }

            let current = player.currentTime().seconds
            let newTime = max(0, current - event.interval)
            player.seek(to: CMTimeMakeWithSeconds(newTime, preferredTimescale: player.currentTime().timescale), toleranceBefore: .zero, toleranceAfter: .zero)
            if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = newTime
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
            return .success
        }

        var newsPlayingNowView: NewsPlayingNowView
        if let currentNewsPlayingNowView = self.newsPlayingNowView {
            newsPlayingNowView = currentNewsPlayingNowView
        } else {
            newsPlayingNowView = NewsPlayingNowView.init(title: title, coverImageKey: coverImageKey)
            newsPlayingNowView.translatesAutoresizingMaskIntoConstraints = false
            self.newsPlayingNowView = newsPlayingNowView
        }
    }
}
