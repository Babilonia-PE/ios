//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ___VARIABLE_moduleName___ViewController: UIViewController {
    
    private let viewModel: ___VARIABLE_moduleName___ViewModel
    
    init(viewModel: ___VARIABLE_moduleName___ViewModel) {
         self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
        
    }
    
    private func setupBindings() {
        
    }
}
