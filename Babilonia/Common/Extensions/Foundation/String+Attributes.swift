//
//  String+Attributes.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

extension String {
    
    func toAttributed(
        with font: UIFont,
        lineSpacing: CGFloat = 1,
        alignment: NSTextAlignment = .left,
        color: UIColor = .black,
        kern: Double = 0,
        underlineStyle: NSUnderlineStyle = []
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        
        return NSAttributedString(
            string: self,
            attributes: [
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle,
                .font: font as Any,
                .kern: kern,
                .underlineStyle: underlineStyle.rawValue
            ]
        )
    }

    func toAttributedLinkPart(with font: FontConvertible.Font?,
                              color: UIColor = .black,
                              lineSpacing: CGFloat = 1,
                              alignment: NSTextAlignment = .center,
                              stringPart: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment

        let mutableString = NSMutableAttributedString(string: self,
                                                      attributes: [.foregroundColor: color,
                                                                   .paragraphStyle: paragraphStyle,
                                                                   .font: font as Any])

        if let range = self.range(of: stringPart) {
            mutableString.addAttributes([.foregroundColor: Asset.Colors.watermelon.color,
                                         .font: FontFamily.AvenirLTStd._85Heavy.font(size: 14) as Any],
                                        range: NSRange(range, in: self))
        }

        return mutableString
    }

    func toAttributedImaged(
        with image: UIImage,
        secondPart: String,
        font: FontConvertible.Font?,
        lineSpacing: CGFloat = 1,
        alignment: NSTextAlignment = .left,
        color: UIColor = .black,
        kern: Double = 0,
        underlineStyle: NSUnderlineStyle = []
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment

        let mutableString = NSMutableAttributedString(string: self,
                                                      attributes: [.foregroundColor: color,
                                                                   .paragraphStyle: paragraphStyle,
                                                                   .font: font as Any,
                                                                   .kern: kern,
                                                                   .underlineStyle: underlineStyle.rawValue]
        )
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        let imageString = NSAttributedString(attachment: imageAttachment)

        mutableString.append(imageString)
        mutableString.append(NSAttributedString(string: secondPart))

        return mutableString
    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )

        return ceil(boundingBox.width)
    }

    func appliedFilterTitle(title: String? = nil, isListingType: Bool = false) -> NSAttributedString {
        let mutableString = NSMutableAttributedString()
        if let title = title {
            let titleString = NSMutableAttributedString(
                string: title,
                attributes: [.foregroundColor: Asset.Colors.bluishGrey.color,
                .font: FontFamily.AvenirLTStd._65Medium.font(size: 12) as Any]
            )
            mutableString.append(titleString)
        }

        let foregroundColor = isListingType ? .white : Asset.Colors.gunmetal.color
        let filterString = NSMutableAttributedString(
            string: self,
            attributes: [.foregroundColor: foregroundColor,
                         .font: FontFamily.AvenirLTStd._65Medium.font(size: 14) as Any]
        )
        mutableString.append(filterString)

        return mutableString
    }

    func inlineProperty(title: String) -> NSAttributedString {
        let mutableString = NSMutableAttributedString()
        let titleString = NSMutableAttributedString(
            string: title,
            attributes: [.foregroundColor: Asset.Colors.gunmetal.color,
                         .font: FontFamily.AvenirLTStd._55Roman.font(size: 12) as Any]
        )
        mutableString.append(titleString)

        let filterString = NSMutableAttributedString(
            string: self,
            attributes: [.foregroundColor: Asset.Colors.almostBlack.color,
                         .font: FontFamily.AvenirLTStd._85Heavy.font(size: 12) as Any]
        )
        mutableString.append(filterString)

        return mutableString
    }
    
}
