//
//  SearchListingEmptyView.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/26/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

class SearchListingEmptyView: UIView {

    private var emptySearchView: EmptySearchView!
    private var iconImageView: UIImageView!
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    
    private func layout() {
        emptySearchView = EmptySearchView()
        addSubview(emptySearchView)
        emptySearchView.layout {
            $0.top == topAnchor + 16.0
            $0.leading == leadingAnchor + 16.0
            $0.trailing == trailingAnchor - 16.0
        }
        
        iconImageView = UIImageView()
        addSubview(iconImageView)
        iconImageView.layout {
            $0.top == emptySearchView.bottomAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.height.equal(to: iconImageView.widthAnchor, multiplier: 1.0)
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        iconImageView.image = Asset.Search.searchListingsEmpty.image
    }

}
