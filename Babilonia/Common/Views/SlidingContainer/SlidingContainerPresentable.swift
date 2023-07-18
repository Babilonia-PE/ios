//
//  Created by Vitaly Chernysh on 4/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.

import UIKit
import NSObject_Rx

protocol SlidingContainerPresentable: class {
    
    var slidingContainerView: SlidingContainerView! { get set }
    var isSlidingContainerPresenting: Bool { get set }

    ///
    /// Configures a `SlidingContainerView` instance. After all subviews management is done, calls
    /// `slideIn(with: contentView)` on SlidingContainerView instance to present a sliding container.
    ///
    /// - Parameters:
    ///     - contentView: The view which is added to SlidingContainerView instance as a subview.
    ///     - parentView: The parent view on which the whole SlidingContainerView instance is added as a subview.
    ///
    func presentSlidingContainer(with contentView: UIView, showingOn parentView: UIView)
    func hideSlidingContainer(completion: (() -> Void)?)

}

extension SlidingContainerPresentable where Self: HasDisposeBag {

    func presentSlidingContainer(with contentView: UIView, showingOn parentView: UIView) {
        guard !isSlidingContainerPresenting else { return }

        configureSlidingContainerView(with: parentView)
        slidingContainerView?.slideIn(with: contentView)
        isSlidingContainerPresenting = true
    }

    func hideSlidingContainer(completion: (() -> Void)? = nil) {
        if isSlidingContainerPresenting {
            slidingContainerView?.slideOut { [weak self] in
                guard let self = self else { return }

                self.slidingContainerView?.removeFromSuperview()
                self.isSlidingContainerPresenting = false
                completion?()
            }
        } else {
            completion?()
        }
    }

    private func configureSlidingContainerView(with parentView: UIView) {
        slidingContainerView = SlidingContainerView()
        parentView.addSubview(slidingContainerView)

        slidingContainerView.closingRequest.doOnNext { [unowned self] in
            self.hideSlidingContainer()
        }.disposed(by: disposeBag)
    }

}
