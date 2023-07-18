//
//  NiblessView.swift
//
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

/// Base View for all custom views used in this module
public class NiblessView: UIView {

    public init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init is not implemented")
    }

}
