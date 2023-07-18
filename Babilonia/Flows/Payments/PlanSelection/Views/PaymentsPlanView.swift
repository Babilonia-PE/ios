//
//  PaymentsPlanView.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class PaymentsPlanView: NiblessView {

    let selectProfileButton: ConfirmationButton = .init()
    var planCollectionView: UICollectionView!
    let itemsTableView: UITableView = .init()
    private let titleLabel: UILabel = .init()
    private let dotsView: PlanDotsView = .init()
    private let scrollView: UIScrollView = .init()
    private let contentView: UIView = .init()

    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var contentSizeObserver: NSKeyValueObservation?

    override init() {
        super.init()

        setupView()
    }

    func setCurrentPlanDot(at index: Int) {
        dotsView.setCurrentDot(at: index)
    }

}

extension PaymentsPlanView {

    private func setupView() {
        backgroundColor = .white

        setupScrollView()

        titleLabel.text = L10n.Payments.PlanSelection.description
        titleLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 14)
        titleLabel.textColor = Asset.Colors.gunmetal.color
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        contentView.addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: contentView.topAnchor, offsetBy: 8)
            $0.leading.equal(to: contentView.leadingAnchor, offsetBy: 38)
            $0.trailing.equal(to: contentView.trailingAnchor, offsetBy: -38)
        }

        selectProfileButton.setTitle(L10n.Payments.PlanSelection.button.uppercased(), for: .normal)
        selectProfileButton.setTitleColor(.white, for: .normal)
        selectProfileButton.titleLabel?.font = FontFamily.SamsungSharpSans.bold.font(size: 16)

        addSubview(selectProfileButton)
        selectProfileButton.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.bottom.equal(to: safeAreaLayoutGuide.bottomAnchor, offsetBy: -24)
            $0.height.equal(to: 56)
        }

        setupCollectionView()
        setupTableView()
        setupContentView()
    }

    private func setupCollectionView() {
        let layout = PaymentPlanFlowLayout()

        planCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        planCollectionView.showsHorizontalScrollIndicator = false
        planCollectionView.clipsToBounds = false
        planCollectionView.backgroundColor = .clear
        planCollectionView.registerReusableCell(cellType: PaymentPlanCell.self)

        contentView.addSubview(planCollectionView)
        planCollectionView.layout {
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 24)
            $0.height.equal(to: 140)
        }

        dotsView.setCurrentDot(at: 1)
        contentView.addSubview(dotsView)
        dotsView.layout {
            $0.top.equal(to: planCollectionView.bottomAnchor, offsetBy: 24)
            $0.height.equal(to: 8)
            $0.centerX.equal(to: contentView.centerXAnchor)
        }

    }

    private func setupTableView() {
        itemsTableView.separatorStyle = .none
        itemsTableView.bounces = false
        itemsTableView.isScrollEnabled = false
        itemsTableView.registerReusableCell(cellType: PaymentPlanItemCell.self)
        itemsTableView.rowHeight = 45

        contentView.addSubview(itemsTableView)
        itemsTableView.layout {
            $0.top.equal(to: planCollectionView.bottomAnchor, offsetBy: 56)
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
            tableViewHeightConstraint = $0.height.equal(to: 0)
            $0.bottom.equal(to: contentView.bottomAnchor, offsetBy: -95)
        }

        contentSizeObserver = itemsTableView.observe(\.contentSize) { [weak self] (_, _) in
            guard let self = self else { return }

            self.tableViewHeightConstraint?.constant = self.itemsTableView.contentSize.height
        }
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

final class PlanDotsView: NiblessView {

    private let stackView: UIStackView = .init()
    private var dotsViews = [UIView]()
    private var sideConstraints = [(NSLayoutConstraint?, NSLayoutConstraint?)]()

    override init() {
        super.init()

        setupView()
    }

    func setCurrentDot(at index: Int) {
        for (dotIndex, dotView) in dotsViews.enumerated() {
            let isCurrent = index == dotIndex
            let color = isCurrent ? Asset.Colors.veryLightBlueTwo.color : Asset.Colors.antiFlashWhite.color
            let cornerRadius: CGFloat = isCurrent ? 4 : 3
            let side: CGFloat = isCurrent ? 8 : 6
            let constraints = sideConstraints[dotIndex]

            dotView.layerCornerRadius = cornerRadius
            dotView.backgroundColor = color
            constraints.0?.constant = side
            constraints.1?.constant = side
        }
    }

}

extension PlanDotsView {

    private func setupView() {
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center

        addSubview(stackView)
        stackView.pinEdges(to: self)

        for _ in 0..<3 {
            let dotView = UIView()
            dotView.backgroundColor = Asset.Colors.antiFlashWhite.color
            dotView.layerCornerRadius = 3

            dotView.frame.size = CGSize(width: 6, height: 6)

            var heightConstraint: NSLayoutConstraint?
            var widthConstraint: NSLayoutConstraint?

            dotView.layout {
                heightConstraint = $0.height.equal(to: 6)
                widthConstraint = $0.width.equal(to: 6)
            }

            stackView.addArrangedSubview(dotView)
            dotsViews.append(dotView)
            sideConstraints.append((heightConstraint, widthConstraint))
        }
    }

}
