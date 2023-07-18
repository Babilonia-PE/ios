//
//  SmallAnnotationView.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class SmallAnnotationView: UIView, AnnotationView {
    
    private let viewModel: AnnotationViewModel

    private var coverImageView: UIImageView!
    private var priceLabel: UILabel!
    private var distanceLabel: UILabel!
    
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
            $0.width == 32.0
            $0.height == 32.0
            $0.centerY == centerYAnchor
            $0.leading == leadingAnchor + 4.0
        }
        
        priceLabel = UILabel()
        distanceLabel = UILabel()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 0.0
        
        stackView.addArrangedSubview(priceLabel)
        stackView.addArrangedSubview(distanceLabel)
        
        addSubview(stackView)
        
        stackView.layout {
            $0.leading == coverImageView.trailingAnchor + 8.0
            $0.trailing == trailingAnchor - 8.0
            $0.centerY == centerYAnchor
        }
    }
    
    private func setupViews() {
        coverImageView.addCornerRadius(4.0)
        if let imageUrl = URL(string: viewModel.coverImage?.photo.smallURLString ?? "") {
            coverImageView.setImage(with: imageUrl)
        }

        priceLabel.textColor = Asset.Colors.vulcan.color
        priceLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 14.0)
        
        distanceLabel.textColor = Asset.Colors.trout.color
        distanceLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 10.0)
    }
    
    private func setupBindings() {
        viewModel.priceUpdated
            .drive(onNext: { [weak self] price in
                self?.priceLabel.text = price
            })
            .disposed(by: disposeBag)
    }
    
}

extension SmallAnnotationView: DistanceConfigurable {

    func applyDistance(_ distance: Double) {
        distanceLabel.text = String(Int(distance)) + " " + metersTitle(by: distance)
    }

}
