//
//  AvatarLoaderView.swift
//  Babilonia
//
//  Created by Alya Filon  on 13.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class AvatarLoaderView: NiblessView {

    private let blurView: UIVisualEffectView = .init()
    private let loaderView: LoaderView = .init()

    override init() {
        super.init()

        setupView()
    }

    func updateProgress(_ progress: CGFloat) {
        loaderView.endAngle = progress * (2 * CGFloat.pi)
    }

}

extension AvatarLoaderView {

    private func setupView() {
        let effect = UIBlurEffect(style: .extraLight)
        blurView.effect = effect

        addSubview(blurView)
        blurView.pinEdges(to: self)

        addSubview(loaderView)
        loaderView.pinEdges(to: self, with: UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22))
    }

}

class LoaderView: NiblessView {

    var endAngle: CGFloat = 0 {
        didSet {
            shapeLayer.path = UIBezierPath(arcCenter: .zero,
                                           radius: 20,
                                           startAngle: 0,
                                           endAngle: endAngle,
                                           clockwise: true).cgPath
        }
    }

    let shapeLayer = CAShapeLayer()

    public override init() {
        super.init()

        backgroundColor = .clear
        setupLayer()
    }

    private func setupLayer() {
        shapeLayer.position = CGPoint(x: 22, y: 22)
        shapeLayer.lineWidth = 4
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = Asset.Colors.watermelon.color.cgColor
        shapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        shapeLayer.path = UIBezierPath(arcCenter: .zero,
                                       radius: 20,
                                       startAngle: 0,
                                       endAngle: endAngle,
                                       clockwise: true).cgPath
        layer.addSublayer(shapeLayer)
    }

}
