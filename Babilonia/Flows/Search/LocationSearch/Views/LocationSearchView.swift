//
//  LocationSearchView.swift
//  Babilonia
//
//  Created by Alya Filon  on 17.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum LocationSearchViewType {
    case empty
    case locations
    case recentSearches
    case notFound(recentSearchesNotEmpty: Bool)
}

final class LocationSearchView: NiblessView {

    var searchButtonSelected: ((String) -> Void)?

    var searchBar: UISearchBar = .init()
    var cancelButton: UIButton = .init()
    var currentLocationButton: UIButton = .init()
    var tableView = UITableView(frame: .zero, style: .grouped)

    private var logoImageView: UIImageView = .init()
    private var filtersImageView: UIImageView = .init()
    private var searchBarBackgroundView: UIView = .init()
    private var searchContainerView: UIView = .init()

    private var currentLocationView: UIView = .init()
    private var currentLocationIcon: UIImageView = .init()
    private var currentLocationLabel: UILabel = .init()

    private var notFoundView: UIView = .init()
    private var notFoundSearchTermLabel: UILabel = .init()

    private var topTableViewConstraint: NSLayoutConstraint?
    private var heightTableViewConstraint: NSLayoutConstraint?
    private var searchBarLeadingConstraint: NSLayoutConstraint?
    private var searchBarTrailingConstraint: NSLayoutConstraint?

    private var tableViewContentSizeObserver: NSKeyValueObservation?
    private let bag = DisposeBag()
    private let tableTopGapOffset: CGFloat = 35

    var viewType: LocationSearchViewType = .empty {
        didSet {
            setupViewType()
        }
    }
    var animationOnDisappearHandler: (() -> Void)?
    var shouldShowRecentSearches: Bool {
        switch viewType {
        case .recentSearches: return true
        case .notFound(let recentSearchesNotEmpty): return recentSearchesNotEmpty
        default: return false
        }
    }

    lazy var recentSearchesHeader: UIView = {
        let recentSearchesHeader = UIView()
        recentSearchesHeader.backgroundColor = .white
        let label = UILabel()
        label.text = L10n.SearchByLocation.recentSearches.uppercased()
        label.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)
        label.textColor = Asset.Colors.bluishGrey.color

        recentSearchesHeader.addSubview(label)
        label.layout {
            $0.top.equal(to: recentSearchesHeader.topAnchor, offsetBy: 14)
            $0.leading.equal(to: recentSearchesHeader.leadingAnchor, offsetBy: 48)
        }

        return recentSearchesHeader
    }()

    override init() {
        super.init()

        setupView()
    }

    func setNotFoundView(isHidden: Bool) {
        notFoundView.isHidden = isHidden
        topTableViewConstraint?.constant = isHidden ? -tableTopGapOffset : 53 - tableTopGapOffset
    }

    func setupViewType() {
        switch viewType {
        case .empty:
            setNotFoundView(isHidden: true)
            tableView.isHidden = true

        case .locations:
            setNotFoundView(isHidden: true)
            setTableViewHeader(isRecentSearches: false)
            tableView.isHidden = false

        case .recentSearches:
            setNotFoundView(isHidden: true)
            setTableViewHeader(isRecentSearches: true)
            tableView.isHidden = false

        case .notFound(let recentSearchesNotEmpty):
            setNotFoundView(isHidden: false)
            setTableViewHeader(isRecentSearches: true)
            tableView.isHidden = !recentSearchesNotEmpty
        }
    }

    func setTableViewHeader(isRecentSearches: Bool) {
        tableView.sectionHeaderHeight = isRecentSearches ? 29 : 0
    }

    func animateSearchBar(onAppear: Bool) {
        let leadingConstant: CGFloat = onAppear ? 16 : 58
        let trailingConstant: CGFloat = onAppear ? -88 : -57
        let alpha: CGFloat = onAppear ? 1 : 0
        searchBarLeadingConstraint?.constant = leadingConstant
        searchBarTrailingConstraint?.constant = trailingConstant

        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
            self.cancelButton.alpha = alpha
            self.logoImageView.alpha = 1 - alpha
            self.filtersImageView.alpha = 1 - alpha
        }, completion: { _ in
            if !onAppear {
                self.animationOnDisappearHandler?()
            }
        })
    }

}

extension LocationSearchView {

    private func setupView() {
        backgroundColor = Asset.Colors.almostBlack.color.withAlphaComponent(0.5)

        setupSearchBarContainer()
        setupCurrentLocation()
        setupNotFoundView()
        setupTableView()

        setupBindings()
    }

    private func setupBindings() {
        searchBar.rx.text
            .subscribe(onNext: { [weak self] text in
                self?.notFoundSearchTermLabel.text = self?.searchBar.text
                if text?.isEmpty == true {
                    self?.setNotFoundView(isHidden: true)
                }
            })
            .disposed(by: bag)
    }

    private func setupSearchBarContainer() {
        searchContainerView.backgroundColor = .white
        addSubview(searchContainerView)
        searchContainerView.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.height.equal(to: 135 + UIConstants.safeLayoutTop)
        }

        logoImageView.image = Asset.Search.logoIcon.image
        logoImageView.alpha = 0.9
        searchContainerView.addSubview(logoImageView)
        logoImageView.layout {
            $0.top == safeAreaLayoutGuide.topAnchor + 16.0
            $0.leading == searchContainerView.leadingAnchor + 16.0
            $0.width.equal(to: 32)
            $0.height.equal(to: 32)
        }

        setupSearchBar()

        filtersImageView.image = Asset.Search.filterIcon.image
        filtersImageView.alpha = 0.9
        searchContainerView.addSubview(filtersImageView)
        filtersImageView.layout {
            $0.top == safeAreaLayoutGuide.topAnchor + 20
            $0.trailing == searchContainerView.trailingAnchor - 16.0
            $0.width.equal(to: 24)
            $0.height.equal(to: 24)
        }

        cancelButton.setTitle(L10n.Buttons.Cancel.title, for: .normal)
        cancelButton.setTitleColor(Asset.Colors.hippieBlue.color, for: .normal)
        cancelButton.titleLabel?.font = FontFamily.AvenirLTStd._85Heavy.font(size: 16)
        cancelButton.alpha = 0

        searchContainerView.addSubview(cancelButton)
        cancelButton.layout {
            $0.trailing.equal(to: searchContainerView.trailingAnchor, offsetBy: -16)
            $0.centerY.equal(to: searchBar.centerYAnchor)
        }

        let separatorView = UIView()
        separatorView.backgroundColor = Asset.Colors.veryLightBlueTwo.color
        searchContainerView.addSubview(separatorView)
        separatorView.layout {
            $0.leading.equal(to: searchContainerView.leadingAnchor)
            $0.height.equal(to: 1)
            $0.trailing.equal(to: searchContainerView.trailingAnchor)
            $0.bottom.equal(to: searchContainerView.bottomAnchor)
        }
    }

    private func setupSearchBar() {
        searchBar.barTintColor = .clear
        searchBar.backgroundColor = .clear
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.tintColor = Asset.Colors.hippieBlue.color
        searchBar.delegate = self

        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .black
        textFieldInsideSearchBar?.backgroundColor = .clear

        searchContainerView.addSubview(searchBar)
        searchBar.layout {
            $0.bottom.equal(to: searchContainerView.bottomAnchor, offsetBy: -55)
            searchBarLeadingConstraint = $0.leading.equal(to: searchContainerView.leadingAnchor, offsetBy: 58)
            searchBarTrailingConstraint = $0.trailing.equal(to: searchContainerView.trailingAnchor, offsetBy: -57)
        }

        searchBarBackgroundView.backgroundColor = .white
        searchBarBackgroundView.layerCornerRadius = 6.0
        searchBarBackgroundView.layerBorderWidth = 1.0
        searchBarBackgroundView.layerBorderColor = Asset.Colors.hippieBlue.color
        searchBarBackgroundView.makeShadow(Asset.Colors.hippieBlue.color,
                                           offset: CGSize(width: 0, height: 1),
                                           radius: 2,
                                           opacity: 0.3)

        searchContainerView.insertSubview(searchBarBackgroundView, belowSubview: searchBar)
        searchBarBackgroundView.layout {
            $0.top == searchBar.topAnchor + 8.0
            $0.bottom == searchBar.bottomAnchor - 8.0
            $0.leading == searchBar.leadingAnchor + 4.0
            $0.trailing == searchBar.trailingAnchor - 4.0
        }
    }

    private func setupCurrentLocation() {
        currentLocationView.backgroundColor = Asset.Colors.aquaSpring.color
        currentLocationView.layer.cornerRadius = 6

        searchContainerView.addSubview(currentLocationView)
        currentLocationView.layout {
            $0.leading.equal(to: searchContainerView.leadingAnchor, offsetBy: 16)
            $0.top.equal(to: searchBarBackgroundView.bottomAnchor, offsetBy: 16)
            $0.height.equal(to: 32)
        }

        currentLocationIcon.image = Asset.Search.currentLocationIcon.image
        currentLocationIcon.contentMode = .scaleAspectFit

        currentLocationView.addSubview(currentLocationIcon)
        currentLocationIcon.layout {
            $0.leading.equal(to: currentLocationView.leadingAnchor, offsetBy: 12)
            $0.top.equal(to: currentLocationView.topAnchor, offsetBy: 8)
            $0.bottom.equal(to: currentLocationView.bottomAnchor, offsetBy: -8)
            $0.width.equal(to: 16)
            $0.height.equal(to: 16)
        }

        currentLocationLabel.text = L10n.SearchByLocation.currentLocation
        currentLocationLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 14)
        currentLocationLabel.textColor = Asset.Colors.biscay.color

        currentLocationView.addSubview(currentLocationLabel)
        currentLocationLabel.layout {
            $0.leading.equal(to: currentLocationIcon.trailingAnchor, offsetBy: 12)
            $0.centerY.equal(to: currentLocationView.centerYAnchor)
            $0.trailing.equal(to: currentLocationView.trailingAnchor, offsetBy: -13)
        }

        currentLocationView.addSubview(currentLocationButton)
        currentLocationButton.pinEdges(to: currentLocationView)
    }

    private func setupNotFoundView() {
        notFoundView.backgroundColor = .white
        notFoundView.isHidden = true
        
        addSubview(notFoundView)
        notFoundView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.top.equal(to: searchContainerView.bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }

        let separatorView1 = UIView()
        separatorView1.backgroundColor = Asset.Colors.veryLightBlueTwo.color
        notFoundView.addSubview(separatorView1)
        separatorView1.layout {
            $0.leading.equal(to: notFoundView.leadingAnchor)
            $0.height.equal(to: 1)
            $0.trailing.equal(to: notFoundView.trailingAnchor)
            $0.top.equal(to: notFoundView.topAnchor)
        }

        let separatorView2 = UIView()
        separatorView2.backgroundColor = Asset.Colors.veryLightBlueTwo.color
        notFoundView.addSubview(separatorView2)
        separatorView2.layout {
            $0.leading.equal(to: notFoundView.leadingAnchor)
            $0.height.equal(to: 1)
            $0.trailing.equal(to: notFoundView.trailingAnchor)
            $0.bottom.equal(to: notFoundView.bottomAnchor)
        }

        notFoundSearchTermLabel.textColor = Asset.Colors.almostBlack.color
        notFoundSearchTermLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)
        notFoundSearchTermLabel.numberOfLines = 2
        notFoundSearchTermLabel.minimumScaleFactor = 0.5
        notFoundSearchTermLabel.adjustsFontSizeToFitWidth = true

        notFoundView.addSubview(notFoundSearchTermLabel)
        notFoundSearchTermLabel.layout {
            $0.leading.equal(to: notFoundView.leadingAnchor, offsetBy: 48)
            $0.top.equal(to: notFoundView.topAnchor, offsetBy: 13)
            $0.trailing.equal(to: notFoundView.trailingAnchor, offsetBy: -16)
        }

        let notFoundLabel = UILabel()
        notFoundLabel.text = L10n.SearchByLocation.locationNotFound
        notFoundLabel.textColor = Asset.Colors.bluishGrey.color
        notFoundLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12)

        notFoundView.addSubview(notFoundLabel)
        notFoundLabel.layout {
            $0.leading.equal(to: notFoundView.leadingAnchor, offsetBy: 48)
            $0.top.equal(to: notFoundSearchTermLabel.bottomAnchor, offsetBy: 4)
            $0.bottom.equal(to: notFoundView.bottomAnchor, offsetBy: -12)
            $0.trailing.equal(to: notFoundView.trailingAnchor, offsetBy: -16)
        }
    }

    private func setupTableView() {
        tableView.registerReusableCell(cellType: LocationSearchCell.self)
        tableView.separatorStyle = .none
        tableView.isHidden = true
        tableView.sectionHeaderHeight = 0
        tableView.backgroundColor = .white

        insertSubview(tableView, belowSubview: searchContainerView)
        tableView.layout {
            $0.leading.equal(to: leadingAnchor)
            topTableViewConstraint = $0.top.equal(to: searchContainerView.bottomAnchor, offsetBy: -tableTopGapOffset)
            heightTableViewConstraint = $0.height.equal(to: 0)
            $0.trailing.equal(to: trailingAnchor)
        }

        tableViewContentSizeObserver = tableView.observe(\.contentSize) { [weak self] (_, _) in
            guard let self = self else { return }
            let maxHeight = UIConstants.screenHeight - self.tableView.frame.minY - UIConstants.defaultKeyboardHeight
            let estimatedHeight = self.tableView.contentSize.height
            self.heightTableViewConstraint?.constant = estimatedHeight > maxHeight ? maxHeight : estimatedHeight
        }
    }

}

extension LocationSearchView: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        searchButtonSelected?(text)
    }

}
