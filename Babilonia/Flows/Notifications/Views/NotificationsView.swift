//
//  NotificationsView.swift
//  Babilonia
//
//  Created by Alya Filon  on 26.12.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class NotificationsView: NiblessView {

    private var titleLabel: UILabel = .init()
    private var emptyView: UIView = .init()

    override init() {
        super.init()

        setupView()
    }
}

extension NotificationsView {

    private func setupView() {
        backgroundColor = .white
        
        titleLabel.text = L10n.TabBar.Notifications.title
        titleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 26)
        titleLabel.textColor = Asset.Colors.almostBlack.color

        addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: safeAreaLayoutGuide.topAnchor, offsetBy: 27)
            $0.leading.equal(to: leadingAnchor, offsetBy: 14)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -14)
        }

        setupEmptyView()
    }

    private func setupEmptyView() {
        addSubview(emptyView)
        emptyView.layout {
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 0)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.bottom.equal(to: bottomAnchor)
        }

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Asset.Common.inboxSoonIcon.image

        emptyView.addSubview(imageView)
        imageView.layout {
            $0.height.equal(to: 64)
            $0.width.equal(to: 64)
            $0.centerX.equal(to: emptyView.centerXAnchor)
            $0.centerY.equal(to: emptyView.centerYAnchor, offsetBy: -55)
        }

        let label = UILabel()
        label.text = L10n.Inbox.commingSoon
        label.font = FontFamily.SamsungSharpSans.bold.font(size: 16)
        label.textColor = Asset.Colors.almostBlack.color
        emptyView.addSubview(label)
        label.layout {
            $0.top.equal(to: imageView.bottomAnchor, offsetBy: 14)
            $0.centerX.equal(to: emptyView.centerXAnchor)
        }
    }

}
