//
//  FieldsValidationApplicable.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa

protocol FieldsValidationApplicable {
    
    var fieldsAreValidUpdated: Driver<Bool> { get }
    
}
