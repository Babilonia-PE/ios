//
//  LargeAnnotationView.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class LargeAnnotationView: UIView, AnnotationView {

    private let viewModel: AnnotationViewModel

    private var coverImageView: UIImageView!
    private var priceLabel: UILabel!
    private var distanceTitleLabel: UILabel!
    private var distanceValueLabel: UILabel!
    private var propertyTypeLabel: UILabel!
    private var separatorView: UIView!
    private var inlinePropertiesView: InlinePropertiesView!
    
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
            $0.width <= 64.0
            $0.height <= 64.0
            $0.centerY == centerYAnchor
            $0.leading == leadingAnchor + 8.0
        }
        
        separatorView = UIView()
        addSubview(separatorView)
        separatorView.layout {
            $0.height == 32.0
            $0.width == 1.0
            $0.centerY == centerYAnchor
            $0.trailing == trailingAnchor - 48.0
        }

        distanceTitleLabel = UILabel()
        distanceValueLabel = UILabel()
        
        let rightStackView = UIStackView()
        rightStackView.axis = .vertical
        rightStackView.distribution = .fill
        rightStackView.alignment = .center
        rightStackView.spacing = 0.0
        
        rightStackView.addArrangedSubview(distanceValueLabel)
        rightStackView.addArrangedSubview(distanceTitleLabel)

        addSubview(rightStackView)
        
        rightStackView.layout {
            $0.top == separatorView.topAnchor
            $0.bottom == separatorView.bottomAnchor
            $0.centerY == separatorView.centerYAnchor
            $0.trailing == trailingAnchor
            $0.leading == separatorView.leadingAnchor
        }

        priceLabel = UILabel()
        propertyTypeLabel = UILabel()
        inlinePropertiesView = InlinePropertiesView()
        
        let leftStackView = UIStackView()
        leftStackView.axis = .vertical
        leftStackView.distribution = .fill
        leftStackView.alignment = .leading
        leftStackView.spacing = 4.0

        leftStackView.addArrangedSubview(priceLabel)
        leftStackView.addArrangedSubview(propertyTypeLabel)
        leftStackView.addArrangedSubview(inlinePropertiesView)
        
        addSubview(leftStackView)
        
        leftStackView.layout {
            $0.leading == coverImageView.trailingAnchor + 12.0
            $0.trailing == rightStackView.leadingAnchor - 12.0
            $0.top == topAnchor + 8.0
            $0.bottom == bottomAnchor - 8.0
        }
    }
    
    private func setupViews() {
        coverImageView.addCornerRadius(4.0)
        
        inlinePropertiesView.setup(with: viewModel.annotationInlinePropertiesInfo)
        if let imageUrl = URL(string: viewModel.coverImage?.photo.smallURLString ?? "") {
            coverImageView.setImage(with: imageUrl)
        }

        separatorView.backgroundColor = Asset.Colors.whiteLilac.color

        priceLabel.textColor = Asset.Colors.vulcan.color
        priceLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 22.0)

        propertyTypeLabel.textColor = Asset.Colors.trout.color
        propertyTypeLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 12.0)
        propertyTypeLabel.text = viewModel.propertyType?.title

        distanceValueLabel.textColor = Asset.Colors.trout.color
        distanceValueLabel.font = FontFamily.AvenirLTStd._95Black.font(size: 20.0)
        distanceValueLabel.text = "--"

        distanceTitleLabel.textColor = Asset.Colors.trout.color
        distanceTitleLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 12.0)
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

extension LargeAnnotationView: DistanceConfigurable {
    
    func applyDistance(_ distance: Double) {
        distanceTitleLabel.text = metersTitle(by: distance)
        distanceValueLabel.text = String(Int(distance))
    }
    
}
