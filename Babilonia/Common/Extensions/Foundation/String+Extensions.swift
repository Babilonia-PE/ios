//
//  NumberConverter.swift
//  Babilonia
//
//  Created by Alya Filon  on 06.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation

extension String {

    func commaConverted() -> String {
        var convertedString = ""
        let positionCount: Double = 3
        var partCount = 0

        for (index, char) in self.enumerated().reversed() {
            if index != self.count - 1,
                partCount == Int(positionCount),
                Double(self.count - (index + 1)).remainder(dividingBy: positionCount) == 0 {
                convertedString += ",\(char)"
                partCount = 1
            } else {
                convertedString += "\(char)"
                partCount += 1
            }
        }

        return String(convertedString.reversed())
    }

    func clearCommaConverting() -> String {
        self.replacingOccurrences(of: ",", with: "")
    }

    func shortPriceConverting(isHistogramPrice: Bool = true) -> String {
        let saleMaxPrice = "1000000"
        let rentMaxPrice = "10000"

        if isHistogramPrice && (self == saleMaxPrice || self == rentMaxPrice) {
            if self == rentMaxPrice { return "\(self.commaConverted())+" }
            if self == saleMaxPrice { return "1M+" }
        }

        return self.commaConverted()
    }

    func cardExpirationDateFormatted() -> String {
        switch self.count {
        case 2:
            let formattedText = "\(self) / "

            return formattedText
        case 4:
            let formattedText = String(self.replacingOccurrences(of: " /", with: "").dropLast())

            return formattedText

        default:
            return self
        }
    }

    func expirationMonth() -> String {
        self.components(separatedBy: " / ").first ?? ""
    }

    func expirationYear() -> String {
        self.components(separatedBy: " / ").last ?? ""
    }

    func priceSufixConverted() -> String {
        var convertedPrice = self
        let components = convertedPrice.components(separatedBy: ".")

        if components.count == 2, components[1].count == 1 {
            convertedPrice.append("0")
        }

        return convertedPrice
    }

}

extension Int {

    func shortPriceFormatted() -> String {
        let numbersCount = "\(self)".count

        var formattedNumber = ""

        func roundNumber(_ number: Double, places: Int) -> Int {
            let divisor = pow(10.0, Double(places))

            return Int(round(number / divisor))
        }

        switch numbersCount {
        case 0...3:
            formattedNumber = "\(self)"

        case 4...6:
            var roundedNumber = "\(roundNumber(Double(self), places: 2))"
            if roundedNumber.last == "0" {
                roundedNumber = String(roundedNumber.dropLast())
            }

            let dottedCount = numbersCount - 2
            let offset = dottedCount - 1
            if roundedNumber.count == dottedCount, roundedNumber.last != "0" {
                let index = roundedNumber.index(roundedNumber.startIndex, offsetBy: offset)
                roundedNumber.insert(".", at: index)
            }

            if roundedNumber.count == 4 && roundedNumber.filter({ $0 == "0" }).count == 3 {
                roundedNumber = roundedNumber.replacingOccurrences(of: "0", with: "")
                formattedNumber = "\(roundedNumber)M"
            } else {
                formattedNumber = "\(roundedNumber)K"
            }

        case 7...9:
            var roundedNumber = "\(roundNumber(Double(self), places: 5))"
            if roundedNumber.last == "0" {
                roundedNumber = String(roundedNumber.dropLast())
            }

            let dottedCount = numbersCount - 5
            let offset = dottedCount - 1
            if roundedNumber.count == dottedCount, roundedNumber.last != "0" {
                let index = roundedNumber.index(roundedNumber.startIndex, offsetBy: offset)
                roundedNumber.insert(".", at: index)
            }
            formattedNumber = "\(roundedNumber)M"

        default:
            formattedNumber = "\(self)"
        }

        return formattedNumber
    }

}
