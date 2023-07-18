//
//  LocationPermissionPopupView.swift
//  Babilonia
//
//  Created by Denis on 8/1/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum PopupViewType {
    case location
    case arView

    var title: String {
        switch self {
        case .location: return L10n.ListingSearch.LocationPopup.title
        case .arView: return L10n.ListingSearch.ArPopup.title
        }
    }

    var text: String {
        switch self {
        case .location: return L10n.ListingSearch.LocationPopup.text
        case .arView: return L10n.ListingSearch.ArPopup.text
        }
    }

    var image: UIImage {
        switch self {
        case .location: return Asset.Search.Map.popupLocationIcon.image
        case .arView: return Asset.Search.Map.popupARIcon.image
        }
    }
}

final class LocationPermissionPopupView: FadeInPopupView {
    
    private var doneAction: (() -> Void)?
    private var cancelAction: (() -> Void)?
    
    private var infoImageView: UIImageView!
    private var titleLabel: UILabel!
    private var textLabel: UILabel!
    private var doneButton: UIButton!
    private var cancelButton: UIButton!
    private var containerShadowLayer: CALayer?
    
    private var disposeBag = DisposeBag()
    private var popupViewType: PopupViewType = .location
    
    // MARK: - lifecycle
    
    override init() {
        super.init()
        
        layout()
        setupViews()
    }

    init(popupViewType: PopupViewType) {
        self.popupViewType = popupViewType

        super.init()

        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addShadow()
    }
    
    func setup(with doneAction: (() -> Void)?, cancelAction: (() -> Void)? = nil) {
        disposeBag = DisposeBag()
        
        if let doneAction = doneAction {
            doneButton.rx.tap.bind(onNext: doneAction).disposed(by: disposeBag)
        }
        if let cancelAction = cancelAction {
            cancelButton.rx.tap.bind(onNext: cancelAction).disposed(by: disposeBag)
        }
    }
    
    // MARK: - private
    
    private func layout() {
        containerView = UIView()
        addSubview(containerView)
        containerView.layout {
            $0.leading == leadingAnchor + 24.0
            $0.trailing == trailingAnchor - 24.0
            $0.centerY == centerYAnchor
        }
        
        infoImageView = UIImageView()
        containerView.addSubview(infoImageView)
        infoImageView.layout {
            $0.top == containerView.topAnchor + 48.0
            $0.centerX == containerView.centerXAnchor
        }
        
        titleLabel = UILabel()
        containerView.addSubview(titleLabel)
        titleLabel.layout {
            $0.top == infoImageView.bottomAnchor + 25.0
            $0.leading == containerView.leadingAnchor + 40.0
            $0.trailing == containerView.trailingAnchor - 40.0
            $0.height >= 24.0
        }
        
        textLabel = UILabel()
        containerView.addSubview(textLabel)
        textLabel.layout {
            $0.top == titleLabel.bottomAnchor + 11.0
            $0.leading == containerView.leadingAnchor + 40.0
            $0.trailing == containerView.trailingAnchor - 40.0
            $0.height >= 24.0
        }
        
        doneButton = ConfirmationButton()
        containerView.addSubview(doneButton)
        doneButton.layout {
            $0.top == textLabel.bottomAnchor + 29.0
            $0.leading == containerView.leadingAnchor + 64.0
            $0.trailing == containerView.trailingAnchor - 64.0
            $0.height == 40.0
        }
        
        cancelButton = UIButton()
        containerView.addSubview(cancelButton)
        cancelButton.isHidden = popupViewType == .arView
        let bottomConstant: CGFloat = popupViewType == .arView ? 20 : -17.0
        cancelButton.layout {
            $0.top == doneButton.bottomAnchor + 15.0
            $0.leading == containerView.leadingAnchor + 64.0
            $0.trailing == containerView.trailingAnchor - 64.0
            $0.bottom.equal(to: containerView.bottomAnchor, offsetBy: bottomConstant)
            $0.height == 40.0
        }
    }
    
    private func setupViews() {
        containerView.backgroundColor = .clear
        
        infoImageView.image = popupViewType.image
        
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = popupViewType.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
            lineSpacing: 8.0,
            alignment: .center,
            color: Asset.Colors.vulcan.color,
            kern: 0.5
        )
        
        textLabel.numberOfLines = 0
        textLabel.attributedText = popupViewType.text.toAttributed(
            with: FontFamily.AvenirLTStd._55Roman.font(size: 14.0),
            lineSpacing: 10.0,
            alignment: .center,
            color: Asset.Colors.mako.color,
            kern: 0.0
        )
        
        doneButton.setAttributedTitle(
            L10n.ListingSearch.LocationPopup.Done.title.toAttributed(
                with: FontFamily.SamsungSharpSans.bold.font(size: 12.0),
                lineSpacing: 0.0,
                alignment: .center,
                color: .white,
                kern: 1.0
            ),
            for: .normal
        )
        cancelButton.backgroundColor = .clear
        cancelButton.setAttributedTitle(
            L10n.ListingSearch.LocationPopup.Cancel.title.toAttributed(
                with: FontFamily.AvenirLTStd._85Heavy.font(size: 14.0),
                lineSpacing: 0.0,
                alignment: .center,
                color: Asset.Colors.osloGray.color,
                kern: 0.0
            ),
            for: .normal
        )
    }
    
    private func addShadow() {
        if containerShadowLayer == nil {
            let backgroundLayer = CALayer()
            backgroundLayer.cornerRadius = 20.0
            backgroundLayer.backgroundColor = UIColor.white.cgColor
            backgroundLayer.frame = containerView.layer.bounds
            containerView.layer.insertSublayer(backgroundLayer, at: 0)
            containerView.layer.addShadowLayer(
                color: UIColor.black.cgColor,
                offset: CGSize(width: 0.0, height: 2.0),
                radius: 14.0,
                opacity: 0.5,
                cornerRadius: 20.0
            )
        }
    }
    
}
