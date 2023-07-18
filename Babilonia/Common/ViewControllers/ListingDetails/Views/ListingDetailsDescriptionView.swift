//
//  ListingDetailsDescriptionView.swift
//  Babilonia
//
//  Created by Denis on 7/15/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa

struct ListingDetailsDescriptionInfo {
    
    let yearOfConstruction: Int?
    let floorNumber: Int?
    let totalFloors: Int?
    let descriptionText: String
    
}

final class ListingDetailsDescriptionView: UIView {
    
    var showMoreTapAction: ControlEvent<Void> { return showMoreButton.rx.tap }
    
    private var titleLabel: UILabel!
    private var descriptionTextView: UITextView!
    private var showMoreButton: UIButton!
    private var showMoreImage: UIImageView!
    private var infoInlinePropertiesView: InlinePropertiesView!

    private var infoInlineViewHeightConstraint: NSLayoutConstraint?
    private var descriptionViewTopConstraint: NSLayoutConstraint?
    
    // MARK: - lifecycle
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let text = descriptionTextView.attributedText else { return }
        
        let constraintRect = CGSize(width: descriptionTextView.frame.width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            context: nil
        )
        
        if ceil(boundingBox.height) > 76.0 {
            descriptionTextView.textContainer.exclusionPaths = [
                UIBezierPath(rect: convert(showMoreButton.frame, to: descriptionTextView))
            ]
            showMoreButton.isHidden = false
            showMoreImage.isHidden = false
        } else {
            descriptionTextView.textContainer.exclusionPaths = []
            showMoreButton.isHidden = true
            showMoreImage.isHidden = true
        }
    }
    
    func setup(with info: ListingDetailsDescriptionInfo) {
        setupInfoItems(info)
        descriptionTextView.attributedText = info.descriptionText.toAttributed(
            with: FontFamily.AvenirLTStd._55Roman.font(size: 14.0),
            lineSpacing: 8.0,
            alignment: .left,
            color: Asset.Colors.trout.color,
            kern: 0.0
        )
    }
    
    // MARK: - private

    private func setupInfoItems(_ info: ListingDetailsDescriptionInfo) {
        var strings = [String]()
        if let yearOfConstruction = info.yearOfConstruction, yearOfConstruction > 0 {
            strings.append(L10n.ListingDetails.About.Year.text(String(yearOfConstruction)))
        }
        if let totalFloors = info.totalFloors {
            strings.append(L10n.ListingDetails.TotalFloorsCount.text(totalFloors))
        }
        if let floorNumber = info.floorNumber {
            strings.append(L10n.ListingDetails.FloorNumber.text(floorNumber))
        }

        infoInlineViewHeightConstraint?.constant = strings.isEmpty ? 0 : 20
        infoInlinePropertiesView.setup(with: InlinePropertiesInfo(strings: strings))
        descriptionViewTopConstraint?.constant = strings.isEmpty ? -5 : 8
    }
    
    private func layout() {
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.layout {
            $0.top == topAnchor + 14.0
            $0.leading == leadingAnchor + 16.0
            $0.trailing <= trailingAnchor - 16.0
            $0.height == 24.0
        }

        infoInlinePropertiesView = InlinePropertiesView(labelType: .large)
        addSubview(infoInlinePropertiesView)
        infoInlinePropertiesView.layout {
            $0.top == titleLabel.bottomAnchor + 20.0
            $0.leading == leadingAnchor + 16.0
            $0.trailing <= trailingAnchor - 16.0
            infoInlineViewHeightConstraint = $0.height.equal(to: 0)
        }

        descriptionTextView = AutoresizedTextView()
        addSubview(descriptionTextView)
        descriptionTextView.layout {
            descriptionViewTopConstraint = $0.top == infoInlinePropertiesView.bottomAnchor + 8.0
            $0.leading == leadingAnchor + 16.0
            $0.trailing == trailingAnchor - 16.0
            $0.bottom == bottomAnchor - 18.0
            $0.height <= 94.0
        }
        
        showMoreButton = UIButton()
        addSubview(showMoreButton)
        showMoreButton.layout {
            $0.trailing == descriptionTextView.trailingAnchor
            $0.bottom == descriptionTextView.bottomAnchor + 5.0
        }
        
        showMoreImage = UIImageView()
        addSubview(showMoreImage)
        showMoreImage.layout {
            $0.trailing == descriptionTextView.trailingAnchor + 2.0
            $0.bottom == descriptionTextView.bottomAnchor + 1.0
        }
    }
    
    private func setupViews() {
        titleLabel.text = L10n.ListingDetails.About.title
        titleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 16.0)
        titleLabel.textColor = Asset.Colors.vulcan.color
        
        descriptionTextView.isUserInteractionEnabled = false
        descriptionTextView.contentInset = .zero
        descriptionTextView.textContainer.lineFragmentPadding = 0
        descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
        
        showMoreButton.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 16.0, bottom: 6.0, right: 16.0)
        showMoreButton.setAttributedTitle(
            L10n.ListingDetails.About.ShowMore.title.toAttributed(
                with: FontFamily.AvenirLTStd._85Heavy.font(size: 12.0),
                lineSpacing: 0.0,
                alignment: .center,
                color: Asset.Colors.hippieBlue.color,
                kern: 0
            ),
            for: .normal
        )
        showMoreImage.image = Asset.ListingDetails.showMoreIcon.image
    }

}
