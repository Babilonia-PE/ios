//
//  ListingTableViewCell.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/26/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingTableViewCell: UITableViewCell {

    var didToggleFavorite: ((Bool) -> Void)?
    var didToggleDetails: ((ListingPreviewContentView) -> Void)?
    var didTogglePhotoTap: (() -> Void)?

    private let containerView: UIView = .init()
    private var previewView: ListingPreviewContentView!

    private var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with viewModel: ListingPreviewViewModel) {
        previewView.setup(with: viewModel)
    }
    
    // MARK: - private
    
    private func layout() {
        contentView.addSubview(containerView)
        containerView.pinEdges(to: contentView)
        
        previewView = ListingPreviewContentView()
        previewView.didToggleFavorite = { [weak self] isSelected in
            self?.didToggleFavorite?(isSelected)
        }
        previewView.didToggleDetails = { [weak self] view in
            self?.didToggleDetails?(view)
        }
        previewView.didTogglePhotoTap = { [weak self] in
            self?.didTogglePhotoTap?()
        }
        containerView.addSubview(previewView)
        previewView.layout {
            $0.top.equal(to: containerView.topAnchor, offsetBy: 3)
            $0.leading.equal(to: containerView.leadingAnchor)
            $0.trailing.equal(to: containerView.trailingAnchor)
            $0.bottom.equal(to: containerView.bottomAnchor)
        }
    }

}

extension ListingTableViewCell: Reusable { }
