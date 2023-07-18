//
//  PaymentPlanFlowLayout.swift
//  Babilonia
//
//  Created by Alya Filon  on 03.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

class PaymentPlanFlowLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()

        scrollDirection = .horizontal
        minimumLineSpacing = 16
        minimumInteritemSpacing = 16

        let sideOffset: CGFloat = 120
        let width = UIConstants.screenWidth - sideOffset
        let ratio: CGFloat = 0.549

        itemSize = CGSize(width: width, height: width * ratio)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)

        super.prepare()
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
            guard let collectionView = collectionView,
                let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds) else {
                return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
            }

            let midSide = collectionView.bounds.size.width / 2
            let proposedContentOffsetCenterOrigin = proposedContentOffset.x + midSide

            var targetContentOffset: CGPoint
            let closest = layoutAttributes.sorted {
                let firstValue = $0.center.x - proposedContentOffsetCenterOrigin
                let secondValue = $1.center.x - proposedContentOffsetCenterOrigin

                return abs(firstValue) < abs(secondValue)
            }.first ?? UICollectionViewLayoutAttributes()

            targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)

            return targetContentOffset
        }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }

}
