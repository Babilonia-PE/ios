//
//  AppDescriptionButton.swift
//  Babilonia
//
//  Created by Alya Filon  on 02.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

class AppDescriptionButton: NiblessView {

    let button: UIButton = .init()
    private let titleLabel: UILabel = .init()
    private let descriprionLabel: UILabel = .init()
    private let placeholderView: UIView = .init()

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var descriptionText: String? {
        didSet {
            descriprionLabel.text = descriptionText
        }
    }

    override init() {
        super.init()

        setupView()
    }

}

extension AppDescriptionButton {

    private func setupView() {
        placeholderView.backgroundColor = Asset.Colors.mandy.color
        placeholderView.layerCornerRadius = 28
        placeholderView.makeShadow(Asset.Colors.brickRed.color.withAlphaComponent(0.3), opacity: 1)

        addSubview(placeholderView)
        placeholderView.pinEdges(to: self)

        titleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 16.0)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white

        placeholderView.addSubview(titleLabel)
        titleLabel.layout {
            $0.centerX.equal(to: placeholderView.centerXAnchor)
            $0.top.equal(to: placeholderView.topAnchor, offsetBy: 10)
        }

        descriprionLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 12)
        descriprionLabel.textAlignment = .center
        descriprionLabel.textColor = .white

        placeholderView.addSubview(descriprionLabel)
        descriprionLabel.layout {
            $0.centerX.equal(to: placeholderView.centerXAnchor)
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 1)
        }

        placeholderView.addSubview(button)
        button.pinEdges(to: placeholderView)
    }

}
