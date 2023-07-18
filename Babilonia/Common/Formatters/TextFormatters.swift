//
//  TextFormatters.swift
//  Babilonia
//
//  Created by Denis on 7/4/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import PhoneNumberKit

public protocol TextFormatter {
    
    func formatted(_ string: String) -> String
    func initial(_ string: String) -> String
    
}

struct LargeIntegerTextFormatter: TextFormatter {
    
    func formatted(_ string: String) -> String {
        // adopted from this one https://stackoverflow.com/a/39848719
        if string == "0" || string.isEmpty {
            return string
        }
        
        let characterSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let filtered = string.components(separatedBy: characterSet)
        let component = filtered.joined()
        let numbersString = component
        
        let formatter = NumberFormatter.integerFormatter
        let number = formatter.number(from: numbersString)
        if let number = number {
            return formatter.string(from: number) ?? ""
        } else {
            return ""
        }
    }
    
    func initial(_ string: String) -> String {
        let characterSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let filtered = string.components(separatedBy: characterSet)
        let component = filtered.joined()
        
        return component
    }
    
}

struct PhoneNumberTextFormatter: TextFormatter {
    
    private let phoneNumberKit = PhoneNumberKit()
    
    func formatted(_ string: String) -> String {
        do {
            return try phoneNumberKit.format(phoneNumberKit.parse(string), toType: .international)
        } catch {
            return string
        }
    }
    
    func initial(_ string: String) -> String {
        do {
            return try phoneNumberKit.format(phoneNumberKit.parse(string), toType: .e164)
        } catch {
            return string
        }
    }
    
}
