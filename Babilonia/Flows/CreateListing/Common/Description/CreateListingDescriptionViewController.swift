//
//  CreateListingDescriptionViewController.swift
//  Babilonia
//
//  Created by Denis on 6/7/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateListingDescriptionViewController: UIViewController {
    
    private let viewModel: CreateListingDescriptionViewModel
    
    private var titleLabel: UILabel!
    private var countLabel: UILabel!
    private var textView: UITextView!
    private var backButtonItem: UIBarButtonItem!
    private var doneButtonItem: UIBarButtonItem!
    private let shadowView: UIView = .init()

    private let keyboardAnimationController = KeyboardAnimationController()

    init(viewModel: CreateListingDescriptionViewModel) {
         self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
        setupKeyboardAnimationController()
        setupNavigationItem()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardAnimationController.beginTracking()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(false)
        keyboardAnimationController.endTracking()

        super.viewWillDisappear(animated)
    }

    // MARK: - private
    
    private func layout() {
        shadowView.backgroundColor = .white
        shadowView.makeShadow(Asset.Colors.almostBlack.color, offset: CGSize(width: 0, height: 2),
                              radius: 2,
                              opacity: 0.3)
        view.addSubview(shadowView)
        shadowView.layout {
            $0.top.equal(to: view.topAnchor, offsetBy: 0)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.height.equal(to: 1)
        }

        titleLabel = UILabel()
        view.addSubview(titleLabel)
        titleLabel.layout {
            $0.top == view.topAnchor + 22.0
            $0.leading == view.leadingAnchor + 16.0
            $0.height >= 24.0
        }
        
        countLabel = UILabel()
        view.addSubview(countLabel)
        countLabel.layout {
            $0.top == view.topAnchor + 26.0
            $0.leading == titleLabel.trailingAnchor + 8.0
            $0.trailing <= view.trailingAnchor - 16.0
            $0.height == 19.0
        }
        
        textView = UITextView()
        textView.delegate = self
        view.addSubview(textView)
        textView.layout {
            $0.top == titleLabel.bottomAnchor + 15.0
            $0.leading == view.leadingAnchor + 16.0
            $0.trailing == view.trailingAnchor - 16.0
            $0.bottom == view.bottomAnchor
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        titleLabel.numberOfLines = 0
        titleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 16.0)
        titleLabel.textColor = Asset.Colors.vulcan.color
        titleLabel.text = L10n.CreateListing.Common.Description.placeholder
        
        countLabel.numberOfLines = 1
        countLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 14.0)
        countLabel.textColor = Asset.Colors.battleshipGray.color
        
        textView.contentInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.tintColor = Asset.Colors.hippieBlue.color
        textView.textColor = Asset.Colors.vulcan.color
        textView.font = FontFamily.AvenirLTStd._55Roman.font(size: 16.0)
        textView.attributedText = viewModel.initialText.toAttributed(
            with: FontFamily.AvenirLTStd._55Roman.font(size: 16.0),
            lineSpacing: 8.0,
            alignment: .left,
            color: Asset.Colors.almostBlack.color,
            kern: 0.0
        )
    }
    
    private func setupNavigationItem() {
        navigationItem.title = L10n.CreateListing.Common.Description.Edit.title
        backButtonItem = UIBarButtonItem(
            image: Asset.Common.backIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.leftBarButtonItem = backButtonItem
        
        doneButtonItem = UIBarButtonItem(
            title: L10n.Buttons.Done.title,
            style: .done,
            target: nil,
            action: nil
        )
        doneButtonItem.apply(style: .action)
        navigationItem.rightBarButtonItem = doneButtonItem
    }
    
    private func setupKeyboardAnimationController() {
        keyboardAnimationController.willAnimatedKeyboardPresentation = { [unowned self] frame in
            self.textView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: frame.height, right: 0.0)
        }
        keyboardAnimationController.willAnimatedKeyboardFrameChange = { [unowned self] frame in
            self.textView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: frame.height, right: 0.0)
        }
        keyboardAnimationController.willAnimatedKeyboardDismissal = { [unowned self] _ in
            self.textView.contentInset = .zero
        }
    }
    
    private func setupBindings() {
        textView.rx.text
            .map { $0 ?? "" }
            .bind(onNext: viewModel.updateText)
            .disposed(by: disposeBag)
        backButtonItem.rx.tap
            .bind(onNext: viewModel.back)
            .disposed(by: disposeBag)
        doneButtonItem.rx.tap
            .bind(onNext: viewModel.done)
            .disposed(by: disposeBag)
        
        viewModel.countText
            .drive(countLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
}

extension CreateListingDescriptionViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        textView.attributedText = textView.text?.toAttributed(
            with: FontFamily.AvenirLTStd._55Roman.font(size: 16.0),
            lineSpacing: 8.0,
            alignment: .left,
            color: Asset.Colors.almostBlack.color,
            kern: 0.0
        )
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        return textView.text.count + text.count <= viewModel.maxSymbolsCount
    }

}
