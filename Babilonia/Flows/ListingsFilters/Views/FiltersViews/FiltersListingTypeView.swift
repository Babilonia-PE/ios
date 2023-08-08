//
//  FiltersListingTypeView.swift
//  Babilonia
//
//  Created by Alya Filon  on 29.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FiltersListingTypeView: NiblessView {

    private let listingTypeLabel: UILabel = .init()
    private let forSaleButton: UIButton = .init()
    private let forRentButton: UIButton = .init()
    private var propertyTypeInputFieldView: InputFieldView!

    var viewModel: ListingPropertyTypeViewModel! {
        didSet {
            setupBinding()
        }
    }
    private let disposeBag = DisposeBag()

    override init() {
        super.init()

        setupView()
    }

}

extension FiltersListingTypeView {

    private func setupBinding() {
        viewModel.listingTypeObservable.subscribe(onNext: { [weak self] type in
            guard let self = self else { return }
            if type == .sale {
                self.configureButtonState(selectedButton: self.forSaleButton, deselectedButton: self.forRentButton)
            } else if type == .rent {
                self.configureButtonState(selectedButton: self.forRentButton, deselectedButton: self.forSaleButton)
            } else {
                self.forSaleButton.setTitleColor(Asset.Colors.gunmetal.color, for: .normal)
                self.forSaleButton.backgroundColor = Asset.Colors.veryLightBlueTwo.color
                self.forRentButton.setTitleColor(Asset.Colors.gunmetal.color, for: .normal)
                self.forRentButton.backgroundColor = Asset.Colors.veryLightBlueTwo.color
            }
        })
        .disposed(by: disposeBag)

        forSaleButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.viewModel?.listingType.accept(.sale) })
            .disposed(by: disposeBag)

        forRentButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.viewModel?.listingType.accept(.rent) })
            .disposed(by: disposeBag)

        setupProperyType(with: viewModel.propertyTypeViewModel)
    }

    private func setupProperyType(with viewModel: InputFieldViewModel) {
        guard !subviews.contains(where: { $0 is InputFieldView }) else { return }

        propertyTypeInputFieldView = InputFieldView(viewModel: viewModel)

        addSubview(propertyTypeInputFieldView)
        propertyTypeInputFieldView.layout {
            $0.top.equal(to: forSaleButton.bottomAnchor, offsetBy: 24)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.height.equal(to: 56)
        }
    }

    private func setupView() {
        backgroundColor = .white

        setupListingType()
        //configureButtonState(selectedButton: forSaleButton, deselectedButton: forRentButton)
    }

    private func setupListingType() {
        listingTypeLabel.text = L10n.CreateListing.Common.ListingType.title
        listingTypeLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)
        listingTypeLabel.textColor = Asset.Colors.bluishGrey.color

        addSubview(listingTypeLabel)
        listingTypeLabel.layout {
            $0.top.equal(to: topAnchor, offsetBy: 38)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
        }

        forSaleButton.setTitle(L10n.Filters.forSale, for: .normal)
        forSaleButton.titleLabel?.font = FontFamily.AvenirLTStd._85Heavy.font(size: 13)
        forSaleButton.layerCornerRadius = 6

        addSubview(forSaleButton)
        forSaleButton.layout {
            $0.top.equal(to: listingTypeLabel.bottomAnchor, offsetBy: 12)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.height.equal(to: 32)
        }

        forRentButton.setTitle(L10n.Filters.forRent, for: .normal)
        forRentButton.titleLabel?.font = FontFamily.AvenirLTStd._85Heavy.font(size: 13)
        forRentButton.layerCornerRadius = 6

        addSubview(forRentButton)
        forRentButton.layout {
            $0.centerY.equal(to: forSaleButton.centerYAnchor)
            $0.leading.equal(to: forSaleButton.trailingAnchor, offsetBy: 23)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.height.equal(to: 32)
            $0.width.equal(to: forSaleButton.widthAnchor)
        }
    }

    private func configureButtonState(selectedButton: UIButton, deselectedButton: UIButton) {
        selectedButton.setTitleColor(.white, for: .normal)
        deselectedButton.setTitleColor(Asset.Colors.gunmetal.color, for: .normal)
        selectedButton.backgroundColor = Asset.Colors.biscay.color
        deselectedButton.backgroundColor = Asset.Colors.veryLightBlueTwo.color
    }
    
    func showOnlyComponent(for filterType: FilterType) {
        switch filterType {
        case .listingType:
            setupListingType()
            propertyTypeInputFieldView.removeFromSuperview()
        case .propertyType:
            listingTypeLabel.removeFromSuperview()
            forSaleButton.removeFromSuperview()
            forRentButton.removeFromSuperview()
            addSubview(propertyTypeInputFieldView)
            propertyTypeInputFieldView.layout {
                $0.top.equal(to: topAnchor, offsetBy: 38)
                $0.leading.equal(to: leadingAnchor, offsetBy: 16)
                $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
                $0.height.equal(to: 56)
            }
        default:
            break
        }
    }

}
