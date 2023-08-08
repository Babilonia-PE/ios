//
//  ListingDetailsDescriptionViewController.swift
//  Babilonia
//
//  Created by Denis on 7/15/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingDetailsDescriptionViewController: UIViewController {
    
    private var backButtonItem: UIBarButtonItem!
    private var descriptionTextView: UITextView!
    
    private let model: ListingDetailsDescriptionModel
    
    init(model: ListingDetailsDescriptionModel) {
        self.model = model
        
        super.init(nibName: nil, bundle: nil)
        
        setupNavigationItem()
        
        layout()
        setupViews()
        setupBindings()
        descriptionTextView.attributedText = model.descriptionString.toAttributed(
            with: FontFamily.AvenirLTStd._55Roman.font(size: 16.0),
            lineSpacing: 8.0,
            alignment: .left,
            color: Asset.Colors.almostBlack.color,
            kern: 0.0
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
        descriptionTextView = UITextView()
        view.addSubview(descriptionTextView)
        descriptionTextView.layout {
            $0.top == view.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }
    }
    
    private func setupViews() {
        descriptionTextView.contentInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        descriptionTextView.textContainer.lineFragmentPadding = 0
        descriptionTextView.tintColor = Asset.Colors.hippieBlue.color
        descriptionTextView.textColor = Asset.Colors.vulcan.color
        descriptionTextView.font = FontFamily.AvenirLTStd._55Roman.font(size: 16.0)
        descriptionTextView.isEditable = false
    }
    
    private func setupBindings() {
        backButtonItem.rx
            .tap
            .bind(onNext: model.back)
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = L10n.CreateListing.Common.Description.Edit.title
        backButtonItem = UIBarButtonItem(
            image: Asset.Common.backIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.leftBarButtonItem = backButtonItem
    }
}
