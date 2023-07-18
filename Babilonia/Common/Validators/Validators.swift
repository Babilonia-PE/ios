//
//  Validators.swift
//  Babilonia
//
//  Created by Denis on 6/5/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

public enum ValidationCheckResult {
    case success, failure(String)
}

public protocol Validator {
    
    // perform validation of input string and return error if any
    func check(_ string: String) -> ValidationCheckResult
    
}

struct NotEmptyValidator: Validator {
    
    func check(_ string: String) -> ValidationCheckResult {
        if string.isEmpty {
            return .failure(L10n.Validation.Empty.Error.text)
        } else {
            return .success
        }
    }
    
}

struct NumbersValidator: Validator {
    
    let numberTest = NSPredicate(format: "SELF MATCHES %@", "[0-9,]+")
    var validationRange = 1...999_999_999
    
    func check(_ string: String) -> ValidationCheckResult {
        guard
            numberTest.evaluate(with: string),
            let intValue = Int(string.replacingOccurrences(of: ",", with: "")),
            validationRange ~= intValue
        else {
            return .failure(
                L10n.Validation.Numbers.RangeError.text(validationRange.lowerBound, validationRange.upperBound)
            )
        }
        
        return .success
    }
    
}

struct EmptyNumbersValidator: Validator {

    let numberTest = NSPredicate(format: "SELF MATCHES %@", "[0-9,]+")
    var validationRange = 1...999_999_999

    func check(_ string: String) -> ValidationCheckResult {
        guard !string.isEmpty else { return .success }
        
        guard
            numberTest.evaluate(with: string),
            let intValue = Int(string.replacingOccurrences(of: ",", with: "")),
            validationRange ~= intValue
        else {
            return .failure(
                L10n.Validation.Numbers.RangeError.text(validationRange.lowerBound, validationRange.upperBound)
            )
        }

        return .success
    }

}

protocol CharactersCountValidator: Validator {
    
    var minimumCount: UInt { get }
    var maximumCount: UInt { get }
    var minimumCountFailureString: String { get }
    var maximumCountFailureString: String { get }
    
}

extension CharactersCountValidator {
    
    func check(_ string: String) -> ValidationCheckResult {
        let count = string.trimmingCharacters(in: .whitespacesAndNewlines).count
        if count < minimumCount {
            return .failure(minimumCountFailureString)
        } else if count > maximumCount {
            return .failure(maximumCountFailureString)
        }
        
        return .success
    }
    
}

struct ListingDescriptionValidator: CharactersCountValidator {
    
    var minimumCount: UInt { return 1 }
    var maximumCount: UInt { return 2000 }
    var minimumCountFailureString: String { return L10n.CreateListing.Common.Description.emptyErrorText }
    var maximumCountFailureString: String {
        return L10n.CreateListing.Common.Description.largeErrorText(Int(maximumCount))
    }
    
}

struct EmailValidator: Validator {
    
    let emailTest = NSPredicate(
        format: "SELF MATCHES %@",
        "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    )
    
    func check(_ string: String) -> ValidationCheckResult {
        if emailTest.evaluate(with: string) {
            return .success
        }

        let errorMessage = string.isEmpty ? L10n.Validation.Empty.Error.text : L10n.Validation.Email.Error.text
        
        return .failure(errorMessage)
    }
    
}

struct CVCValidator: Validator {

    let cvcTest = NSPredicate(
        format: "SELF MATCHES %@", "[0-9]{3}"
    )

    func check(_ string: String) -> ValidationCheckResult {
        if cvcTest.evaluate(with: string) {
            return .success
        }

        return .failure(L10n.Validation.Email.Error.text)
    }

}

struct CardNameValidator: Validator {

    let cardNameTest = NSPredicate(
        format: "SELF MATCHES %@", "[A-Za-z ]+"
    )

    func check(_ string: String) -> ValidationCheckResult {
        if cardNameTest.evaluate(with: string) {
            return .success
        }

        return .failure(L10n.Validation.Email.Error.text)
    }

}

struct CardExpirationDateValidator: Validator {

    let cardNameTest = NSPredicate(
        format: "SELF MATCHES %@", "[0-9 /]{7}"
    )

    func check(_ string: String) -> ValidationCheckResult {
        if cardNameTest.evaluate(with: string) {
            return isExpirationDateValid(for: string) ? .success : .failure("")
        }

        return .failure("")
    }

    private func isExpirationDateValid(for string: String) -> Bool {
        let dateFormatter = DateFormatter()
        let dateComponents = string.components(separatedBy: " / ")

        dateFormatter.dateFormat = "MM / yy"
        guard dateFormatter.date(from: string) != nil else { return false }

        let currentDateStringComponents = dateFormatter.string(from: Date()).components(separatedBy: " / ")
        let maxStripeValidationYear = 70

        guard let month = Int(dateComponents.first ?? ""),
              let year = Int(dateComponents.last ?? ""),
              let currentMonth = Int(currentDateStringComponents.first ?? ""),
              let currentYear = Int(currentDateStringComponents.last ?? "") else { return false }

        switch year {
        case 0..<currentYear:
            return false

        case currentYear:
            return month >= currentMonth

        case (currentYear + 1)...maxStripeValidationYear:
            return true

        default:
            return false
        }
    }

}

struct ProfileNameValidator: CharactersCountValidator {
    
    var minimumCount: UInt { return 1 }
    var maximumCount: UInt { return 20 }
    var minimumCountFailureString: String { return L10n.Validation.Empty.Error.text }
    var maximumCountFailureString: String {
        return L10n.Validation.LargeError.text(Int(maximumCount))
    }
}
