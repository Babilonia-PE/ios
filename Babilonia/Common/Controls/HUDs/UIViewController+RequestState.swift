//
//  UIViewController+RequestState.swift
//
//  Copyright © 2018 Yalantis. All rights reserved.
//

import UIKit
import RxSwift

extension AlertApplicable where Self: UIViewController {
    
    func bind(requestState observable: Observable<RequestState>) {
        observable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.handle(state)
            })
            .disposed(by: disposeBag)
    }
    
    func handle(_ state: RequestState) {
        switch state {
        case .failed(let error):
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let error = error {
                showDefaultAlert(with: .error, message: error.localizedDescription)
            }

        case .failedMessage(let message):
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            showDefaultAlert(with: .error, message: message)

        case .inProgress:
            break

        case .started:
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

        case .finished:
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

        case .success(let message):
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            showDefaultAlert(with: .success, message: message ?? "")
        }
    }
    
}
