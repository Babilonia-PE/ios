//
//  ListingDetailsFacilitiesView.swift
//  Babilonia
//
//  Created by Denis on 7/16/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

final class ListingDetailsFacilitiesView: UIView {

    enum ViewType {
        case facility, advanced

        var title: String {
            switch self {
            case .facility: return L10n.ListingDetails.Facilities.title
            case .advanced: return L10n.ListingDetails.Advanced.title
            }
        }
    }
    
    private var titleView: UIView!
    private var titleTextLabel: UILabel!
    private var collectionView: UICollectionView!
    private var titleViewHeightConstraint: NSLayoutConstraint!
    private var collectionViewHeightConstraint: NSLayoutConstraint!
    
    private var infos: [ListingDetailsFacilityInfo]!
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with type: ViewType, infos: [ListingDetailsFacilityInfo]) {
        self.infos = infos
        
        if infos.isEmpty {
            titleViewHeightConstraint.constant = 0.0
            collectionViewHeightConstraint.priority = UILayoutPriority(999.0)
        } else {
            titleViewHeightConstraint.constant = 36.0
            collectionViewHeightConstraint.priority = UILayoutPriority(1.0)
        }
        
        collectionView.reloadData()
        titleTextLabel.text = type.title
    }
    
    // MARK: - private
    
    private func layout() {
        titleView = UIView()
        addSubview(titleView)
        titleView.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            titleViewHeightConstraint = $0.height == 36.0
        }
        
        titleTextLabel = UILabel()
        titleView.addSubview(titleTextLabel)
        titleTextLabel.layout {
            $0.leading == titleView.leadingAnchor + 16.0
            $0.trailing <= titleView.trailingAnchor - 16.0
            $0.centerY == titleView.centerYAnchor
        }
        
        let layout = GridFlowLayout()
        layout.numberOfLines = 2.0
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.imageAreaRatio = 3.35714
        layout.sectionInset = UIEdgeInsets(top: 4.0, left: 0.0, bottom: 8.0, right: 0.0)
        collectionView = AutoresizedCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        addSubview(collectionView)
        collectionView.layout {
            $0.top == titleView.bottomAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
            collectionViewHeightConstraint = $0.height == (0.0, UILayoutPriority(1.0))
        }
    }
    
    private func setupViews() {
        titleView.clipsToBounds = true
        
        titleTextLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 16.0)
        titleTextLabel.textColor = Asset.Colors.vulcan.color
        
        collectionView.backgroundColor = .white
        collectionView.registerReusableCell(cellType: ListingDetailsFacilityCell.self)
        collectionView.dataSource = self
        collectionView.clipsToBounds = true
    }
    
}

extension ListingDetailsFacilitiesView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infos.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: ListingDetailsFacilityCell = collectionView.dequeueReusableCell(indexPath)
        cell.setup(with: infos[indexPath.row])
        
        return cell
    }
    
}
