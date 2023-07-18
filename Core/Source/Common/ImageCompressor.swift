//
//  ImageCompressor.swift
//  Core
//
//  Created by Denis on 7/5/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import AVFoundation
import YALResult

private let maxImageSizeInBytes: Int = 7_000_000  // ~7mb in bytes
private let maxImageSide: Int = 1420
private let defaultCompressionQuality: CGFloat = 0.98

public enum ImageCompressorError: Error {
    case wrongImageFormat
}

typealias CompressedImage = (data: Data, image: UIImage)

class ImageCompressor {
    
    static func prepareForUpload(
        _ image: UIImage,
        maxImageSizeInBytes: Int = maxImageSizeInBytes,
        maxImageSide: Int = maxImageSide,
        preferredCompression: CGFloat = defaultCompressionQuality
    ) -> YALResult<CompressedImage> {
        let boundingRect = CGRect(origin: .zero, size: CGSize(width: maxImageSide, height: maxImageSide))
        let resizedImage = resize(image, boundingRect: boundingRect) ?? image
        return compress(
            resizedImage,
            maxImageSizeInBytes: maxImageSizeInBytes,
            preferredCompression: preferredCompression
        )
    }
    
    private static func resize(_ image: UIImage, boundingRect: CGRect) -> UIImage? {
        guard image.size.width > boundingRect.size.width ||
            image.size.height > boundingRect.size.height else {
                return image
        }
        
        var designatedRect = AVMakeRect(aspectRatio: image.size, insideRect: boundingRect)
        designatedRect.origin = .zero
        
        UIGraphicsBeginImageContextWithOptions(designatedRect.size, false, 0.0)
        image.draw(in: designatedRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    private static func compress(
        _ image: UIImage, maxImageSizeInBytes: Int,
        preferredCompression: CGFloat
    ) -> YALResult<CompressedImage> {
        guard let data = image.jpegData(compressionQuality: preferredCompression)
            else {
                return .failure(ImageCompressorError.wrongImageFormat)
        }
        
        let originalImageSize = data.count
        if originalImageSize > maxImageSizeInBytes {
            let compressionMultiplier = CGFloat(maxImageSizeInBytes / originalImageSize)
            guard let compressedData = image.jpegData(compressionQuality: compressionMultiplier),
                let image = UIImage(data: compressedData)
                else { return .failure(ImageCompressorError.wrongImageFormat) }
            
            return .success(CompressedImage(compressedData, image))
        } else {
            return .success(CompressedImage(data, image))
        }
    }
    
}
