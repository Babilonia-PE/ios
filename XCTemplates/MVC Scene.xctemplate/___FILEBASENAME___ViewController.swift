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
    
    private let model: ___VARIABLE_moduleName___Model
    
    init(model: ___VARIABLE_moduleName___Model) {
        self.model = model
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
    }
}
