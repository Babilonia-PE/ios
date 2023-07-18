//
//  StaticCaretTextField.swift
//  Babilonia
//
//  Created by Denis on 7/4/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

class StaticCaretTextField: UITextField {
    
    override func closestPosition(to point: CGPoint) -> UITextPosition? {
        let beginning = self.beginningOfDocument
        let end = self.position(from: beginning, offset: self.text?.count ?? 0)
        return end
    }
    
}
