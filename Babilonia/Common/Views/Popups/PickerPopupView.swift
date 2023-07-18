//
//  PickerPopupView.swift
//  Babilonia
//
//  Created by Denis on 6/6/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PickerPopupView: FadeInPopupView {
    
    private var buttonsView: UIView!
    private var pickerView: UIPickerView!
    private var titleLabel: UILabel!
    private var doneButton: UIButton!
    
    private let itemTitles: [String]
    private let title: String?
    private let startingIndex: Int
    private var doneAction: (() -> Void)?
    private var selectionUpdated: ((Int) -> Void)?
    
    private var containerBottomConstraint: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    private var actionsDisposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init(itemTitles: [String], title: String?, startingIndex: Int = 0) {
        self.itemTitles = itemTitles
        self.title = title
        self.startingIndex = startingIndex
        
        super.init()
        
        layout()
        setupViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(
        with doneAction: (() -> Void)?,
        selectionUpdated: ((Int) -> Void)?
    ) {
        actionsDisposeBag = DisposeBag()
        
        self.doneAction = doneAction
        self.selectionUpdated = selectionUpdated
        
        if let doneAction = doneAction {
            doneButton.rx.tap
                .bind(onNext: doneAction)
                .disposed(by: actionsDisposeBag)
        }
        if let selectionUpdated = selectionUpdated {
            pickerView.rx.itemSelected
                .map { $0.row }
                .bind(onNext: selectionUpdated)
                .disposed(by: actionsDisposeBag)
        }
        
        pickerView.selectRow(startingIndex, inComponent: 0, animated: false)
    }
    
    override func animateContainerView(isShowing: Bool, withDelay: Bool = false, completion: (() -> Void)? = nil) {
        let duration: TimeInterval = 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + (withDelay ? duration : 0.0)) {
            self.containerBottomConstraint.constant = isShowing ? 0.0 : self.containerView.frame.height
            UIView.animate(
                withDuration: duration,
                animations: {
                    self.layoutIfNeeded()
                },
                completion: { _ in
                    completion?()
                }
            )
        }
    }
    
    // MARK: - private
    
    private func layout() {
        let buttonsViewHeight: CGFloat = 44.0
        let pickerViewHeight: CGFloat = 216.0
        
        containerView = UIView()
        addSubview(containerView)
        containerView.layout {
            containerBottomConstraint = $0.bottom == bottomAnchor + (buttonsViewHeight + pickerViewHeight)
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
        }
        
        buttonsView = UIView()
        containerView.addSubview(buttonsView)
        buttonsView.layout {
            $0.top == containerView.topAnchor
            $0.leading == containerView.leadingAnchor
            $0.trailing == containerView.trailingAnchor
            $0.height == buttonsViewHeight
        }
        
        doneButton = UIButton()
        buttonsView.addSubview(doneButton)
        doneButton.layout {
            $0.trailing == buttonsView.trailingAnchor - 8.0
            $0.top == buttonsView.topAnchor
            $0.bottom == buttonsView.bottomAnchor
        }
        
        titleLabel = UILabel()
        buttonsView.addSubview(titleLabel)
        titleLabel.layout {
            $0.centerX == buttonsView.centerXAnchor
            $0.top == buttonsView.topAnchor
            $0.bottom == buttonsView.bottomAnchor
        }
        
        pickerView = UIPickerView()
        containerView.addSubview(pickerView)
        pickerView.layout {
            $0.top == buttonsView.bottomAnchor
            $0.leading == containerView.leadingAnchor
            $0.trailing == containerView.trailingAnchor
            $0.bottom == containerView.bottomAnchor
            $0.height == pickerViewHeight
        }
    }
    
    private func setupViews() {
        buttonsView.backgroundColor = Asset.Colors.grayNurse.color
        
        doneButton.setTitleColor(Asset.Colors.blue.color, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        doneButton.setTitle(L10n.Buttons.Done.title, for: .normal)
        
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        titleLabel.text = title
        
        pickerView.backgroundColor = .white
    }
    
    private func setupBindings() {
        Observable.just(itemTitles)
            .bind(to: pickerView.rx.itemTitles) { _, item in
                return item
            }
            .disposed(by: disposeBag)
    }
    
}
