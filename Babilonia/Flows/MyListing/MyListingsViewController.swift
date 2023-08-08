//
//  MyListingsViewController.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 6/26/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Core

final class MyListingsViewController: UIViewController, AlertApplicable, SpinnerApplicable {
    
    enum SegmentType: Int {
        case published, notPublished
    }
    
    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    
    private let viewModel: MyListingsViewModel
    
    private var titleLabel: UILabel!
    private var topView: UIView!
    private var scrollableView: ScrollableView!
    private var segmentControlView: SegmentControlView!
    private var addListingButton: UIButton!
    private var publishedTableView: UITableView!
    private var notPublishedTableView: UITableView!
    private var emptyStateView: MyListingEmptyView!

    // MARK: - lifecycle
    
    init(viewModel: MyListingsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        layoutTopView()
        setupViews()
        setupBindings()
        setupTableView()
        segmentControlView.selectIndex(SegmentType.published.rawValue, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.fetchListings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - private

    private func layout() {
        scrollableView = ScrollableView(direction: .horizontal)
        view.addSubview(scrollableView)
        
        topView = UIView()
        view.addSubview(topView)
        
        scrollableView.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == topView.bottomAnchor
            $0.bottom == view.layoutMarginsGuide.bottomAnchor
        }
        
        publishedTableView = UITableView()
        scrollableView.contentView.addSubview(publishedTableView)
        publishedTableView.layout {
            $0.leading == scrollableView.contentView.leadingAnchor
            $0.top == scrollableView.contentView.topAnchor
            $0.bottom == scrollableView.contentView.bottomAnchor
            $0.width == scrollableView.widthAnchor
        }
        
        notPublishedTableView = UITableView()
        scrollableView.contentView.addSubview(notPublishedTableView)
        notPublishedTableView.layout {
            $0.trailing == scrollableView.contentView.trailingAnchor
            $0.top == scrollableView.contentView.topAnchor
            $0.bottom == scrollableView.contentView.bottomAnchor
            $0.leading == publishedTableView.trailingAnchor
            $0.width == scrollableView.widthAnchor
        }
    }
    
    private func layoutTopView() {
        topView.layout {
            $0.top == view.layoutMarginsGuide.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.height == 84
        }
        
        addListingButton = UIButton()
        topView.addSubview(addListingButton)
        addListingButton.layout {
            $0.top == topView.topAnchor + 23.0
            $0.trailing == topView.trailingAnchor - 16.0
            $0.height == 40.0
            $0.width >= 138.0
        }
        
        titleLabel = UILabel()
        topView.addSubview(titleLabel)
        titleLabel.layout {
            $0.top == topView.topAnchor + 27.0
            $0.leading == topView.leadingAnchor + 14.0
            $0.trailing <= addListingButton.leadingAnchor - 6.0
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        segmentControlView = SegmentControlView()
        topView.addSubview(segmentControlView)
        segmentControlView.layout {
            $0.top == titleLabel.bottomAnchor + 25.0
            $0.leading == topView.leadingAnchor
            $0.trailing == topView.trailingAnchor
            $0.height == 40
        }
        
        emptyStateView = MyListingEmptyView(type: .all)
        view.addSubview(emptyStateView)
        emptyStateView.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == topView.bottomAnchor
            $0.bottom == view.layoutMarginsGuide.bottomAnchor
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        topView.backgroundColor = .white
        emptyStateView.backgroundColor = .white
        
        scrollableView.scrollView.isPagingEnabled = true
        scrollableView.scrollView.delegate = self
        scrollableView.scrollView.backgroundColor = Asset.Colors.veryLightBlueTwo.color
        
        titleLabel.numberOfLines = 0
        titleLabel.text = L10n.MyListings.title
        titleLabel.textColor = Asset.Colors.vulcan.color
        titleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 26.0)
        
        let addButtonTitle = L10n.MyListings.AddButton.text.toAttributed(
            with: FontFamily.AvenirLTStd._85Heavy.font(size: 12.0),
            lineSpacing: 0.0,
            alignment: .center,
            color: .white,
            kern: 0
        )
        addListingButton.layerCornerRadius = 20
        addListingButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        addListingButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        addListingButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        addListingButton.setAttributedTitle(addButtonTitle, for: .normal)
        addListingButton.titleEdgeInsets = UIEdgeInsets(top: 3.0, left: 17.0, bottom: 0.0, right: 9.0)
        addListingButton.backgroundColor = Asset.Colors.watermelon.color
        addListingButton.setImage(Asset.Common.plusIcon.image.withRenderingMode(.alwaysTemplate), for: .normal)
        addListingButton.tintColor = .white
        addListingButton.imageEdgeInsets = UIEdgeInsets(top: 8.0, left: 9.0, bottom: 8.0, right: 12.0)
        addListingButton.makeShadow(Asset.Colors.watermelon.color)
        
        segmentControlView.configure(with: .init(items: [
            (SegmentType.published.rawValue, SegmentType.published.title),
            (SegmentType.notPublished.rawValue, SegmentType.notPublished.title)
        ]))
        segmentControlView.makeShadow(Asset.Colors.almostBlack.color,
                                      offset: CGSize(width: 0, height: 5),
                                      radius: 2,
                                      opacity: 0.07)
        segmentControlView.backgroundColor = .white

        segmentControlView.itemSelected = { [unowned self] id in
            guard let segment = SegmentType(rawValue: id) else { return }
            
            self.scrollableView.scrollView.setContentOffset(
                CGPoint(x: segment == .published ? 0 : self.view.frame.width, y: 0),
                animated: true
            )
        }
    }
    
    private func setupBindings() {
        bind(requestState: viewModel.requestState)
        
        viewModel.requestState.isLoading
            .bind { [weak self] value in
                self?.updateLoadingState(value)
            }
            .disposed(by: disposeBag)
        
        viewModel.showWarning
            .subscribe(onNext: { [weak self] _ in
                self?.presentWarning()
            })
            .disposed(by: disposeBag)
        
        viewModel.listingsUpdated
            .drive(onNext: { [weak self] in
                self?.updateViewState()
            })
            .disposed(by: disposeBag)
        
        viewModel.emptyStateNeeded
            .drive(onNext: { [weak self] isEmpty in
                if isEmpty {
                    self?.emptyStateView.isHidden = false
                    self?.scrollableView.isHidden = true
                    self?.addListingButton.isHidden = true
                    self?.segmentControlView.isHidden = true
                    self?.topView.layout.height?.constant = 84
                } else {
                    self?.emptyStateView.isHidden = true
                    self?.scrollableView.isHidden = false
                    self?.addListingButton.isHidden = false
                    self?.segmentControlView.isHidden = false
                    self?.topView.layout.height?.constant = 124
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.shouldShowAddListingButton
            .map { !$0 }
            .drive(addListingButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        addListingButton.rx.tap
            .bind(onNext: viewModel.createListing)
            .disposed(by: disposeBag)
        
        emptyStateView.emptyStateButton.rx.tap
            .bind(onNext: viewModel.createListing)
            .disposed(by: disposeBag)
    }
    
    private func updateViewState() {
        if viewModel.publishedListingsCount == 0 {
            publishedTableView.backgroundView = MyListingEmptyView(type: .published)
        } else {
            publishedTableView.backgroundView = nil
        }
        
        if viewModel.notPublishedListingsCount == 0 {
            notPublishedTableView.backgroundView = MyListingEmptyView(type: .notPublished)
        } else {
            notPublishedTableView.backgroundView = nil
        }
        
        publishedTableView.reloadData()
        notPublishedTableView.reloadData()
        view.layoutIfNeeded()
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            spinner.show(on: view, text: nil, blockUI: false)
        } else {
            spinner.hide(from: view)
        }
    }
    
    private func setupTableView() {
        [publishedTableView, notPublishedTableView].forEach {
            $0?.dataSource = self
            $0?.delegate = self
            $0?.registerReusableCell(cellType: MyListingTableViewCell.self)
            $0?.separatorStyle = .none
            $0?.rowHeight = 256
        }
    }
    
    private func showOptionsPopup(_ listingId: ListingId, options: [MyListingOptions]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        options.forEach {
            alert.addAction(self.action(for: listingId, option: $0))
        }
        alert.addAction(UIAlertAction(title: L10n.Buttons.Cancel.title, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func action(for listingId: ListingId, option: MyListingOptions) -> UIAlertAction {
        return UIAlertAction(
            title: option.title,
            style: option.style
        ) { [weak self] _ in
            guard let self = self else { return }
            
            switch option {
            case .open: self.viewModel.openListing(with: listingId)
            case .edit: self.viewModel.editListing(with: listingId)
            case .publish:
                if self.viewModel.isListingNotPurchased(at: listingId) {
                    self.viewModel.publishListing(with: listingId)
                } else {
                    if self.viewModel.isListingRealtor(at: listingId) {
                        self.presentWarning()
                    } else {
                        self.presentPublishActionAlert(for: listingId, isPublish: true)
                    }
                    
                }
            case .unpublish: self.presentPublishActionAlert(for: listingId, isPublish: false)
            case .delete: self.presentDeleteAlert(for: listingId)
            case .share: self.showShare(for: listingId)
            }
        }
    }
    
    private func showShare(for listingId: ListingId) {
        let text = L10n.Common.share
        let url = URL(string: "\(Environment.default.webSiteURL ?? "")listings/\(listingId)")!
        let items: [Any] = [text, url]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.airDrop
        ]

        self.present(activityViewController, animated: true, completion: nil)
    }

    private func presentPublishActionAlert(for listingId: ListingId,
                                           isPublish: Bool) {
        
        let title = isPublish ? nil : L10n.Popups.UnpublishListing.title
        let message = isPublish ? L10n.Popups.PublishListing.text : L10n.Popups.UnpublishListing.text
        let actionTitle = isPublish ? L10n.MyListings.Options.Publish.title : L10n.MyListings.Options.Unpublish.title
        
        SystemAlert.present(on: self,
                            title: title,
                            message: message,
                            confirmTitle: actionTitle,
                            confirm: { [weak self] in
                                if isPublish {
                                    self?.viewModel.publishListing(with: listingId)
                                } else {
                                    self?.viewModel.unpublishListing(with: listingId)
                                }
                              })
    }

    private func presentDeleteAlert(for listingId: ListingId) {
        SystemAlert.presentDestructive(on: self,
                                       title: L10n.Popups.DeleteDraftListing.title,
                                       message: L10n.Popups.DeleteDraftListing.text,
                                       destructTitle: L10n.MyListings.Options.Delete.title,
                                       destruct: { [weak self] in
                                            self?.viewModel.deleteListing(with: listingId)
                                       })
    }
    
    private func presentWarning() {
        let message = L10n.Errors.actionMustBeDoneFromWeb
        SystemAlert.present(on: self,
                            message: message)
    }

}

extension MyListingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == publishedTableView ? viewModel.publishedListingsCount : viewModel.notPublishedListingsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath) as MyListingTableViewCell
        cell.setup(with: viewModel.listingViewModel(at: indexPath.row, isPublished: tableView == publishedTableView))
        cell.optionsSelected = { [weak self] in
            guard let self = self else { return }
            let optionsInfo = self.viewModel.listingOptionsSelected(
                at: indexPath.row,
                isPublished: tableView == self.publishedTableView
            )
            self.showOptionsPopup(optionsInfo.0, options: optionsInfo.1)
        }
//        cell.shareSelected = { [weak self] in
//            guard let self = self else { return }
//            let optionsInfo = self.viewModel.listingOptionsSelected(
//                at: indexPath.row,
//                isPublished: tableView == self.publishedTableView
//            )
//            self.showShare(optionsInfo.0)
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.listingSelected(at: indexPath.row, isPublished: tableView == publishedTableView)
    }
}

private extension MyListingOptions {
    
    var title: String {
        switch self {
        case .open: return L10n.MyListings.Options.Open.title
        case .edit: return L10n.MyListings.Options.Edit.title
        case .publish: return L10n.MyListings.Options.Publish.title
        case .unpublish: return L10n.MyListings.Options.Unpublish.title
        case .delete: return L10n.MyListings.Options.Delete.title
        case .share: return L10n.MyListings.Options.Share.title
        }
    }
    
    var style: UIAlertAction.Style {
        switch self {
        case .open, .edit, .publish, .share: return .default
        case .delete, .unpublish: return .destructive
        }
    }
}

extension MyListingsViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == scrollableView.scrollView else { return }
        
        let index = Int(scrollView.contentOffset.x / scrollView.frame.width)
        segmentControlView.selectIndex(index, animated: false)
    }
}

extension MyListingsViewController.SegmentType {
    
    var title: String {
        switch self {
        case .published: return L10n.MyListings.Segment.published
        case .notPublished: return L10n.MyListings.Segment.notPublished
        }
    }
}
