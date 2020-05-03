//
//  AudioVisualizerView.swift
//  meho-ios
//
//  Created by Meho Dev on 4/17/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

protocol AudioVisualizerViewDelegte : AnyObject {
    func audioVisualizerViewDidTapInside(_ audioVisualizerView: AudioVisualizerView)
}

class AudioVisualizerView: UIView, CAAnimationDelegate {

    // MARK: - Constants
    let numberOfBars = 20
    private let cornerRadius = CGFloat(4)
    private let leadingTrailingMargin = CGFloat(20)
    private let barMinHeight = CGFloat(20)
    private let barMaxHeight = CGFloat(80)

    // MARK: - Properties
    private var barSublayers = [CALayer].init()
    private var currentIndex = 0
    private var lastAnimatedLayer: CALayer!
    private var lastAnimatedLayerHeight = CGFloat(0)
    weak var delegate: AudioVisualizerViewDelegte?

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGestureRecognizer)
    }

    // MARK: - Internal
    func prepareBanners() {
        let barWidth = (frame.width - 2 * leadingTrailingMargin) / CGFloat(numberOfBars * 2)
        var startX = leadingTrailingMargin
        let height = frame.height
        var currentBarIndex = 0;
        let y = (height - barMinHeight) / 2
        if barSublayers.count == numberOfBars {
            while currentBarIndex < numberOfBars {
                let layer = barSublayers[currentBarIndex]
                layer.frame = CGRect.init(x: startX, y: y, width: barWidth, height:barMinHeight)
                startX += (barWidth * 2)
                currentBarIndex += 1
            }
        } else {
            while currentBarIndex < numberOfBars {
                let layer = CALayer()
                layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
                layer.backgroundColor = UIColor.wisteriaPurple.cgColor
                layer.frame = CGRect.init(x: startX, y: y, width: barWidth, height:barMinHeight)
                layer.cornerRadius = cornerRadius
                startX += (barWidth * 2)
                self.layer.addSublayer(layer)
                barSublayers.append(layer)
                currentBarIndex += 1
            }
        }
    }

    func drawBanner(value: Float) {
        let layer = barSublayers[currentIndex]
        let animation = CABasicAnimation.init(keyPath: "bounds.size.height")
        animation.fromValue = layer.bounds.size.height
        lastAnimatedLayerHeight = barMinHeight + (barMaxHeight - barMinHeight) * CGFloat(value)
        animation.toValue = lastAnimatedLayerHeight
        animation.duration = 0.02
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.delegate = self
        layer.add(animation, forKey: "Banner animation")
        lastAnimatedLayer = layer
        currentIndex = (currentIndex + 1) % numberOfBars
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let height = frame.height
        let y = (height - lastAnimatedLayerHeight) / 2
        let lastAnimatedLayerFrame = lastAnimatedLayer.frame
        lastAnimatedLayer.frame = CGRect.init(x: lastAnimatedLayerFrame.origin.x, y: y, width: lastAnimatedLayerFrame.width, height: lastAnimatedLayerHeight)
    }

    @objc
    private func didTapView() {
        delegate?.audioVisualizerViewDidTapInside(self)
    }

}
