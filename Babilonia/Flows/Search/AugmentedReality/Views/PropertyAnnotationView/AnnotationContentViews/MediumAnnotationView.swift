//
//  MediumAnnotationView.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift

final class MediumAnnotationView: UIView, AnnotationView {
    
    private let viewModel: AnnotationViewModel

    private var coverImageView: UIImageView!
    private var priceLabel: UILabel!
    private var distanceTitleLabel: UILabel!
    private var distanceValueLabel: UILabel!
    private var propertyTypeLabel: UILabel!
    
    private let disposeBag = DisposeBag()

    init(viewModel: AnnotationViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: CGRect.zero)
        
        layout()
        setupViews()
        setupBindings()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        coverImageView = UIImageView()
        addSubview(coverImageView)
        coverImageView.layout {
            $0.width == 48.0
            $0.height == 48.0
            $0.centerY == centerYAnchor
            $0.leading == leadingAnchor + 4.0
        }
        
        distanceTitleLabel = UILabel()
        distanceValueLabel = UILabel()
        
        let rightStackView = UIStackView()
        rightStackView.axis = .vertical
        rightStackView.distribution = .equalSpacing
        rightStackView.alignment = .center
        rightStackView.spacing = 3.0
        
        rightStackView.addArrangedSubview(distanceValueLabel)
        rightStackView.addArrangedSubview(distanceTitleLabel)
        
        addSubview(rightStackView)
        
        rightStackView.layout {
            $0.trailing == trailingAnchor
            $0.centerY == centerYAnchor
        }
        
        priceLabel = UILabel()
        propertyTypeLabel = UILabel()
        
        let leftStackView = UIStackView()
        leftStackView.axis = .vertical
        leftStackView.distribution = .equalSpacing
        leftStackView.alignment = .leading
        leftStackView.spacing = 5.0

        leftStackView.addArrangedSubview(priceLabel)
        leftStackView.addArrangedSubview(propertyTypeLabel)

        addSubview(leftStackView)

        leftStackView.layout {
            $0.leading == coverImageView.trailingAnchor + 12.0
            $0.trailing == rightStackView.leadingAnchor - 12.0
            $0.centerY == centerYAnchor
        }
    }
    
    private func setupViews() {
        coverImageView.addCornerRadius(4.0)
        if let imageUrl = URL(string: viewModel.coverImage?.photo.originalURLString ?? "") {
            coverImageView.setImage(with: imageUrl)
        } else {
            coverImageView.image = Asset.MyListings.myListingsDraft.image
        }

        priceLabel.textColor = Asset.Colors.vulcan.color
        priceLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 18.0)
        
        propertyTypeLabel.textColor = Asset.Colors.trout.color
        propertyTypeLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 10.0)
        propertyTypeLabel.text = viewModel.propertyType?.title

        distanceValueLabel.textColor = Asset.Colors.trout.color
        distanceValueLabel.font = FontFamily.AvenirLTStd._95Black.font(size: 16.0)
        distanceValueLabel.text = "--"
        
        distanceTitleLabel.textColor = Asset.Colors.trout.color
        distanceTitleLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 8.0)
        distanceTitleLabel.text = L10n.Ar.MetersCounter.Many.title
    }
    
    private func setupBindings() {
        viewModel.priceUpdated
            .drive(onNext: { [weak self] price in
                self?.priceLabel.text = price
            })
            .disposed(by: disposeBag)
    }

}

extension MediumAnnotationView: DistanceConfigurable {
    
    func applyDistance(_ distance: Double) {
        distanceTitleLabel.text = metersTitle(by: distance)
        distanceValueLabel.text = String(Int(distance))
    }

}
