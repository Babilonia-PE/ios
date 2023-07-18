//
//  NotificationsViewController.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationsViewController: NiblessViewController, HasCustomView {

    typealias CustomView = NotificationsView

    private let viewModel: NotificationsViewModel

    override func loadView() {
        let customView = CustomView()
        view = customView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    init(viewModel: NotificationsViewModel) {
        self.viewModel = viewModel

        super.init()

        setupBindings()
    }

    private func setupBindings() {
        
    }
}
