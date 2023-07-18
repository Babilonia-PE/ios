//
//  UIViewController+RxLifecycle.swift
//
//  Copyright © 2018 Yalantis. All rights reserved.
//

import UIKit
import RxSwift

extension Reactive where Base: UIViewController {
    
    public var viewDidLoad: Observable<Void> {
        return sentMessage(#selector(Base.viewDidLoad)).map { _ in Void() }
    }
    
    public var viewDidAppear: Observable<Void> {
        return sentMessage(#selector(Base.viewDidAppear(_:))).map { _ in Void() }
    }
    
    public var viewWillAppear: Observable<Void> {
        return sentMessage(#selector(Base.viewWillAppear(_:))).map { _ in Void() }
    }
    
    public var viewWillDisappear: Observable<Void> {
        return sentMessage(#selector(Base.viewWillDisappear(_:))).map { _ in Void() }
    }
    
}
