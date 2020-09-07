//
//  UIGifExtension.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/18/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import ImageIO

extension UIImageView {

    public func loadGifFromLocal(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.loadGifFromLocal(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

    public func loadGifFromUrl(url: String) {
        DispatchQueue.global().async {
            let image = UIImage.loadGifFromUrl(url: url)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}

extension UIImage {

    public class func loadGifFromUrl(url: String) -> UIImage? {
        guard let bundleUrl = URL(string: url) else {
            print("Url: \"\(url)\" does not exist")
            return nil
        }

        guard let imageData = try? Data(contentsOf: bundleUrl) else {
            print("Cannot turn image url \"\(url)\" into byte buffer Data")
            return nil
        }

        return loadGifWithData(data: imageData)
    }

    public class func loadGifFromLocal(name: String) -> UIImage? {
        guard let bundleUrl = Bundle.main
          .url(forResource: name, withExtension: "gif") else {
            print("Image: \"\(name)\" is not a .gif")
            return nil
        }

        guard let imageData = try? Data(contentsOf: bundleUrl) else {
            print("Cannot turn image name \"\(name)\" into byte buffer Data")
            return nil
        }

        return loadGifWithData(data: imageData)
    }

    internal class func loadGifWithData(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        return UIImage.animateImageFromGifSource(source)
    }

    internal class func gcdEuklid(_ m: Int, _ n: Int) -> Int {
        let r: Int = m % n
        if r != 0 {
            return gcdEuklid(n, r)
        } else {
            return n
        }
    }

    internal class func getGcd(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]
        for val in array {
            gcd = gcdEuklid(val, gcd)
        }

        return gcd
    }

    internal class func animateImageFromGifSource(_ source: CGImageSource) -> UIImage? {
        let numOfImages = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        var totalDurationMillis = 0;

        for index in 0..<numOfImages {
            if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(image)
                let delayMills = Int(UIImage.delayForImageAtIndex(Int(index), source: source) * 1000.0)
                delays.append(delayMills) // Seconds to ms
                totalDurationMillis += delayMills
            }
        }

        // Get frames
        let delaysGcd = getGcd(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for index in 0..<numOfImages {
            frame = UIImage(cgImage: images[Int(index)])
            frameCount = Int(delays[Int(index)] / delaysGcd)
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        return UIImage.animatedImage(with: frames, duration: Double(totalDurationMillis) / 1000.0)
    }

    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        // calculated delay should be larger than 0
        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        }

        return delay
    }

}
