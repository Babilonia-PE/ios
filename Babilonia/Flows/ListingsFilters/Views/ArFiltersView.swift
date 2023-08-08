//
//  ArFiltersView.swift
//  Babilonia
//
//  Created by Owson on 29/12/21.
//  Copyright © 2021 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ArFiltersView: NiblessView {
    let listingTypeView: FiltersListingTypeView = .init()
    
    var applyButton: AppDescriptionButton = .init()

    private let stackView: UIStackView = .init()
    private let scrollView: UIScrollView = .init()
    private let contentView: UIView = .init()
    
    private var stackHeightConstraint: NSLayoutConstraint?
    
    private let facilitiesTopOffset: CGFloat = 48
    private var filterViewTypes = [FilterViewType]()
    
    override init() {
        super.init()

        applyButton.removeDescription()
        setupView()
    }
    
    func setupView(with filterViewTypes: [FilterViewType]) {
        self.filterViewTypes = filterViewTypes
        setupFiltersViews(with: filterViewTypes)
    }
    
    func updateUI(for filterType: FilterType)  {
        listingTypeView.showOnlyComponent(for: filterType)
    }
}
    
extension ArFiltersView {
    private func setupView() {
        backgroundColor = .white

        setupScrollView()
        stackView.axis = .vertical
        stackView.distribution = .fill

        contentView.addSubview(stackView)
        stackView.layout {
            $0.top.equal(to: contentView.safeAreaLayoutGuide.topAnchor)
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
            $0.bottom.equal(to: contentView.bottomAnchor, offsetBy: -120)
            stackHeightConstraint = $0.height.equal(to: 0)
        }

        applyButton.title = L10n.Filters.applyFilters.uppercased()
        addSubview(applyButton)
        applyButton.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.height.equal(to: 56)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -35)
        }

        setupContentView()

//        facilitiesView.facilitiesHeightUpdated = { [weak self] height in
//            guard let self = self, let constant = self.facilitiesHeightConstraint?.constant else { return }
//            if self.filterViewTypes.contains(.facilities) {
//                let estimatedHeight = height - self.facilitiesTopOffset - constant
//                self.facilitiesHeightConstraint?.constant = estimatedHeight
//                self.recalculateStackHeight(with: estimatedHeight)
//                self.facilitiesView.isHidden = height == 0
//            }
//        }
//        counterView.countersHeightUpdated = { [weak self] height in
//            guard self?.filterViewTypes
//                .contains(where: { FilterViewType.counterFilters.contains($0) }) == true else { return }
//            self?.countersHeightConstraint?.constant = height
//            self?.recalculateStackHeight(with: height)
//        }
//        checkmarksView.checkmarksHeightUpdated = { [weak self] height in
//            guard self?.filterViewTypes
//                .contains(where: { FilterViewType.checkmarksFilters.contains($0) }) == true else { return }
//            self?.checkmarksHeightConstraint?.constant = height
//            self?.recalculateStackHeight(with: height)
//        }
    }
    
    private func recalculateStackHeight(with height: CGFloat) {
        guard let stackHeight = stackHeightConstraint?.constant else { return }
        stackHeightConstraint?.constant = stackHeight + height
    }
    
    private func setupFiltersViews(with filterViewTypes: [FilterViewType]) {
        clearView()

        for viewType in filterViewTypes {
            switch viewType {
            case .listingType:
                stackView.addArrangedSubview(listingTypeView)
                listingTypeView.layout {
                    $0.height.equal(to: 184, priority: UILayoutPriority(rawValue: 999))
                }

            case .priceRange:
                break
//                stackView.addArrangedSubview(histogramView)
//                histogramView.layout {
//                    $0.height.equal(to: 144, priority: UILayoutPriority(rawValue: 999))
//                }
//
            case .totalArea:
                break
//                stackView.addArrangedSubview(totalAreaRangeView)
//                totalAreaRangeView.layout {
//                    $0.height.equal(to: 180, priority: UILayoutPriority(rawValue: 999))
//                }
//
            case .builtArea:
                break
//                stackView.addArrangedSubview(builtAreaRangeView)
//                builtAreaRangeView.layout {
//                    $0.height.equal(to: 180, priority: UILayoutPriority(rawValue: 999))
//                }
//
            case .yearOfConstruction:
                break
//                stackView.addArrangedSubview(yearRangeView)
//                yearRangeView.layout {
//                    $0.height.equal(to: 128, priority: UILayoutPriority(rawValue: 999))
//                }
//
            case .bedrooms, .bathrooms, .totalFloors, .floorNumber, .parkingSlots:
                break
//                if !stackView.arrangedSubviews.contains(counterView) {
//                    stackView.addArrangedSubview(counterView)
//
//                    counterView.layout {
//                        countersHeightConstraint = $0.height.equal(to: 0, priority: UILayoutPriority(rawValue: 999))
//                    }
//                }
//
            case .parkingForVisitors:
                break
//                if !stackView.arrangedSubviews.contains(checkmarksView) {
//                    stackView.addArrangedSubview(checkmarksView)
//
//                    checkmarksView.layout {
//                        checkmarksHeightConstraint = $0.height.equal(to: 0, priority: UILayoutPriority(rawValue: 999))
//                    }
//                }
//
            case .facilities:
                break
//                facilitiesView.clearView()
//                stackView.addArrangedSubview(facilitiesView)
//                facilitiesView.layout {
//                    facilitiesHeightConstraint = $0.height.equal(to: 0, priority: UILayoutPriority(rawValue: 999))
//                }
            }
        }

        stackHeightConstraint?.constant = calculateStackHeight(for: filterViewTypes)
    }

    private func clearView() {
        stackHeightConstraint?.constant = 0
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        counterView.clearView()
    }
    
    private func calculateStackHeight(for types: [FilterViewType]) -> CGFloat {
        var height: CGFloat = types.contains(.facilities) ? facilitiesTopOffset : 0
        types.forEach { height += $0.sectionViewHeight }

        return height
    }
    
    private func setupContentView() {
        contentView.layout {
            $0.width.equal(to: UIConstants.screenWidth, priority: UILayoutPriority(rawValue: 999))
            $0.top.equal(to: scrollView.topAnchor)
            $0.leading.equal(to: scrollView.leadingAnchor)
            $0.trailing.equal(to: scrollView.trailingAnchor)
            $0.bottom.equal(to: scrollView.bottomAnchor)
        }
    }
    
    private func setupScrollView() {
        scrollView.keyboardDismissMode = .interactive
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.top.equal(to: safeAreaLayoutGuide.topAnchor, priority: UILayoutPriority(rawValue: 999))
            $0.bottom.equal(to: layoutMarginsGuide.bottomAnchor, priority: UILayoutPriority(rawValue: 999))
        }
    }
}
