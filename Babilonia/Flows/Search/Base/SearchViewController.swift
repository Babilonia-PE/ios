//
//  SearchViewController.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    
    private var searchContainerView: UIView!
    private var searchBackgroundView: UIView!
    private var searchShadowLayer: CALayer!
    private var tagsContainerView: UIView!
    private var tagsHeightConstraint: NSLayoutConstraint!
    private var filtersView: FiltersView!
    private var listingsFoundLabel: UILabel!
    private var filtersTipLabel: UILabel!
    private var logoImageView: UIImageView!
    private var filtersButton: UIButton!
    private var searchBar: UISearchBar!
    private var searchBarBackgroundView: UIView!
    private var contentContainerView: UIView!
    private var switchFlowButton: UIButton!
    private var switchFlowShadowView: UIView!
    private var switchFlowShadowLayer: CALayer!
    private var arButton: SearchActionButton!
    private var arShadowView: UIView!
    private var arShadowLayer: CALayer!
    
    private let viewModel: SearchViewModel
    
    private var viewControllersMap = [SearchMode: UIViewController]()
    private weak var currentViewController: UIViewController?
    private var canOpenLocationSearch = true
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupShadows()
    }

    private func layout() {
        layoutSearchView()
        
        contentContainerView = UIView()
        view.insertSubview(contentContainerView, belowSubview: searchBackgroundView)
        contentContainerView.layout {
            $0.top == searchContainerView.bottomAnchor - 13.0
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.safeAreaLayoutGuide.bottomAnchor
        }
        
        switchFlowButton = SearchActionButton()
        switchFlowButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.addSubview(switchFlowButton)
        switchFlowButton.layout {
            $0.trailing == view.trailingAnchor - 16.0
            $0.bottom == view.safeAreaLayoutGuide.bottomAnchor - 40.0
            $0.width == 56.0
            $0.height == 56.0
        }
        
        switchFlowShadowView = UIView()
        view.insertSubview(switchFlowShadowView, belowSubview: switchFlowButton)
        switchFlowShadowView.layout {
            $0.top == switchFlowButton.topAnchor
            $0.leading == switchFlowButton.leadingAnchor
            $0.trailing == switchFlowButton.trailingAnchor
            $0.bottom == switchFlowButton.bottomAnchor
        }
        
        arButton = SearchActionButton()
        view.addSubview(arButton)
        arButton.layout {
            $0.trailing == view.trailingAnchor - 16.0
            $0.bottom == switchFlowButton.topAnchor - 16.0
            $0.width == 56.0
            $0.height == 56.0
        }

        arButton.layoutIfNeeded()
        arButton.makeViewRound()

        if viewModel.shouldShowARPopUp {
            arButton.setupGradient()
        }

        arShadowView = UIView()
        view.insertSubview(arShadowView, belowSubview: arButton)
        arShadowView.layout {
            $0.top == arButton.topAnchor
            $0.leading == arButton.leadingAnchor
            $0.trailing == arButton.trailingAnchor
            $0.bottom == arButton.bottomAnchor
        }
    }
    
    //swiftlint:disable:next function_body_length
    private func layoutSearchView() {
        searchContainerView = UIView()
        view.addSubview(searchContainerView)
        searchContainerView.layout {
            $0.top == view.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
        
        searchBackgroundView = UIView()

        view.insertSubview(searchBackgroundView, belowSubview: searchContainerView)
        searchBackgroundView.layout {
            $0.top == searchContainerView.topAnchor
            $0.leading == searchContainerView.leadingAnchor
            $0.trailing == searchContainerView.trailingAnchor
            $0.bottom == searchContainerView.bottomAnchor
        }
        
        logoImageView = UIImageView()
        searchContainerView.addSubview(logoImageView)
        logoImageView.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor + 16.0
            $0.leading == searchContainerView.leadingAnchor + 16.0
            $0.width == 32.0
            $0.height == 32.0
        }
        
        filtersButton = UIButton()
        searchContainerView.addSubview(filtersButton)
        filtersButton.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor + 4.0
            $0.trailing == searchContainerView.trailingAnchor
            $0.width == 56.0
            $0.height == 56.0
        }
        
        searchBar = UISearchBar()
        searchContainerView.addSubview(searchBar)
        searchBar.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor + 3.0
            $0.leading == logoImageView.trailingAnchor + 10.0
            $0.trailing == filtersButton.leadingAnchor - 1.0
        }
        
        searchBarBackgroundView = UIView()
        searchContainerView.insertSubview(searchBarBackgroundView, belowSubview: searchBar)
        searchBarBackgroundView.layout {
            $0.top == searchBar.topAnchor + 8.0
            $0.bottom == searchBar.bottomAnchor - 8.0
            $0.leading == searchBar.leadingAnchor + 4.0
            $0.trailing == searchBar.trailingAnchor - 4.0
        }
        
        tagsContainerView = UIView()
        searchContainerView.addSubview(tagsContainerView)
        tagsContainerView.layout {
            $0.top == searchBar.bottomAnchor - 2.0
            $0.leading == searchContainerView.leadingAnchor
            $0.trailing == searchContainerView.trailingAnchor
            $0.bottom == searchContainerView.bottomAnchor
            tagsHeightConstraint = $0.height == 0.0
        }
        
        filtersView = FiltersView()
        tagsContainerView.addSubview(filtersView)
        filtersView.layout {
            $0.top == tagsContainerView.topAnchor + 6.0
            $0.leading == tagsContainerView.leadingAnchor
            $0.trailing == tagsContainerView.trailingAnchor
        }
        
        listingsFoundLabel = UILabel()
        tagsContainerView.addSubview(listingsFoundLabel)
        listingsFoundLabel.layout {
            $0.top == filtersView.bottomAnchor + 9.0
            $0.leading == tagsContainerView.leadingAnchor + 16.0
            $0.height == 16.0
        }
        
        filtersTipLabel = UILabel()
        tagsContainerView.addSubview(filtersTipLabel)
        filtersTipLabel.layout {
            $0.top == filtersView.bottomAnchor + 9.0
            $0.leading == listingsFoundLabel.trailingAnchor + 16.0
            $0.height == 16.0
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        searchContainerView.backgroundColor = .white
        searchContainerView.addCornerRadius(13.0, corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner])

        logoImageView.image = Asset.Search.logoIcon.image
        
        filtersButton.setImage(Asset.Search.filterIcon.image.withRenderingMode(.alwaysTemplate),
                               for: .normal)
        filtersButton.setImage(Asset.Search.filterIconSelected.image, for: .selected)

        searchBar.placeholder = L10n.ListingSearch.SearchBar.placeholder

        searchBar.barTintColor = .clear
        searchBar.backgroundColor = .clear
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.tintColor = Asset.Colors.hippieBlue.color
        searchBar.delegate = self
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .black
        textFieldInsideSearchBar?.backgroundColor = .clear
        
        searchBarBackgroundView.backgroundColor = .white
        searchBarBackgroundView.layerCornerRadius = 6.0
        searchBarBackgroundView.layerBorderWidth = 1.0
        searchBarBackgroundView.layerBorderColor = Asset.Colors.whiteLilac.color
        searchBarBackgroundView.makeShadow(Asset.Colors.almostBlack.color,
                                           offset: CGSize(width: 0, height: 3),
                                           radius: 3,
                                           opacity: 0.1)

        searchBackgroundView.backgroundColor = .white
        searchBackgroundView.clipsToBounds = false
        searchBackgroundView.layerCornerRadius = 13.0
        searchBackgroundView.makeShadow(Asset.Colors.vulcan.color,
                                        offset: CGSize(width: 0, height: 2),
                                        radius: 3,
                                        opacity: 0.15)

        contentContainerView.backgroundColor = .white
        
        arButton.setImage(Asset.Search.arModeIcon.image, for: .normal)
        
        listingsFoundLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12.0)
        listingsFoundLabel.textColor = Asset.Colors.osloGray.color
        
        filtersTipLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12.0)
        filtersTipLabel.textColor = Asset.Colors.osloGray.color
        filtersTipLabel.text = L10n.Search.Bar.FiltersTip.text

        filtersView.removedFilterClosure = { [weak self] index in
            self?.viewModel.removeFilter(at: index)
        }
    }
    
    private func setupShadows() {
        if switchFlowShadowLayer == nil {
            switchFlowButton.makeViewRound()
            switchFlowShadowLayer = switchFlowShadowView.layer.addShadowLayer(
                color: Asset.Colors.vulcan.color.cgColor,
                offset: CGSize(width: 0.0, height: 4.0),
                radius: 6.0,
                opacity: 0.25,
                cornerRadius: switchFlowShadowView.frame.width / 2.0
            )
        }
        if arShadowLayer == nil {
            arShadowLayer = arShadowView.layer.addShadowLayer(
                color: Asset.Colors.vulcan.color.cgColor,
                offset: CGSize(width: 0.0, height: 4.0),
                radius: 6.0,
                opacity: 0.25,
                cornerRadius: arShadowView.frame.width / 2.0
            )
        }
    }
    
    private func setupBindings() {
        arButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.presentARPopupIfNeeded()
            })
            .disposed(by: disposeBag)
        
        switchFlowButton.rx.tap
            .bind(onNext: viewModel.switchMode)
            .disposed(by: disposeBag)

        searchBar.rx.text
            .skip(1)
            .subscribe(onNext: { [weak self] text in
                self?.canOpenLocationSearch = !(text?.isEmpty == true)
                if text?.isEmpty == true { self?.viewModel.removeSearchAddress() }
            })
            .disposed(by: disposeBag)

        filtersButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.presentListingsFilters()
            })
            .disposed(by: disposeBag)
        
        viewModel.switchButtonImageUpdated
            .drive(onNext: { [weak self] image in
                self?.switchFlowButton.setImage(image, for: .normal)
            })
            .disposed(by: disposeBag)
        
        viewModel.arButtonAvailable
            .map { !$0 }
            .drive(onNext: { [weak self] value in
                guard let self = self else { return }
                self.arButton.isHidden = value
                self.arShadowView.isHidden = value
            })
            .disposed(by: disposeBag)
        
        viewModel.modeUpdated
            .drive(onNext: { [weak self] mode in
                self?.updatePresentedMode(mode)
            })
            .disposed(by: disposeBag)
        
        viewModel.searchAssressObservable
            .subscribe(onNext: { [weak self] address in
                self?.searchBar.text = address
            })
            .disposed(by: disposeBag)

        viewModel.filtersApplied
            .subscribe(onNext: { [weak self] isApplied in
                self?.filtersButton.tintColor = isApplied ? Asset.Colors.watermelon.color :
                    Asset.Colors.almostBlack.color
                self?.tagsHeightConstraint.constant = isApplied ? 66.0 : 4.0
            })
            .disposed(by: disposeBag)

        viewModel.listingsFoundCount
            .map { L10n.Search.Bar.ListingsFound.text($0) }
            .bind(to: listingsFoundLabel.rx.text )
            .disposed(by: disposeBag)

        viewModel.appliedFilters
            .subscribe(onNext: { [weak self] filterInfos in
                self?.filtersView.setup(with: filterInfos)
            })
            .disposed(by: disposeBag)
    }
    
    private func viewController(for mode: SearchMode) -> UIViewController {
        if let viewController = viewControllersMap[mode] {
            return viewController
        } else {
            let viewController: UIViewController
            switch mode {
            case .list:
                guard let viewModel = viewModel.viewModel(for: mode) as? SearchListViewModel else {
                    fatalError("Can't cast to \(SearchListViewModel.self)")
                }
                
                viewController = SearchListViewController(viewModel: viewModel)
            case .map:
                guard let viewModel = viewModel.viewModel(for: mode) as? SearchMapViewModel else {
                    fatalError("Can't cast to \(SearchMapViewModel.self)")
                }
                viewController = SearchMapViewController(viewModel: viewModel)
            }
            viewControllersMap[mode] = viewController
            
            return viewController
        }
    }
    
    private func updatePresentedMode(_ mode: SearchMode) {
        if let currentViewController = currentViewController {
            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
        }
        
        let newViewController = viewController(for: mode)
        addChild(newViewController)
        contentContainerView.addSubview(newViewController.view)
        newViewController.view.layout {
            $0.top == contentContainerView.topAnchor
            $0.leading == contentContainerView.leadingAnchor
            $0.trailing == contentContainerView.trailingAnchor
            $0.bottom == contentContainerView.bottomAnchor
        }
        newViewController.didMove(toParent: self)
        currentViewController = newViewController
    }

    private func presentARPopupIfNeeded() {

        guard viewModel.shouldShowARPopUp else {
            viewModel.requestAugmentedRealityPresentation()
            return
        }

        guard let window = UIApplication.shared.delegate?.window, let presentingView = window else { return }
        let popupView = LocationPermissionPopupView(popupViewType: .arView)

        let doneAction = { [weak self] in
            self?.viewModel.shouldShowARPopUp = false
            popupView.hide()
            self?.viewModel.requestAugmentedRealityPresentation()
            self?.arButton.removeGradient()
        }

        popupView.setup(with: doneAction)
        popupView.show(in: presentingView)
    }
    
}

extension SearchViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if canOpenLocationSearch {
            viewModel.openLocationSearch(searchTerm: searchBar.text ?? "")
        }
        canOpenLocationSearch = true

        return false
    }

}
