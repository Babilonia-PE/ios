//
//  DateFormatter.swift
//  Babilonia
//
//  Created by Alya Filon  on 25.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation

extension Date {

    func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"

        return formatter.string(from: self)
    }

    func daysLeft(endDate: Date) -> String {
        let daysLeft = daysLeftCount(endDate: endDate)

        if daysLeft <= 0 {
            return ""
        } else {
            return L10n.MyListings.daysLeft(daysLeft) 
        }
    }

    func daysLeftCount(endDate: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard let fromDate = formatter.date(from: formatter.string(from: self)),
              let endDate = formatter.date(from: formatter.string(from: endDate)),
              let currentDate = formatter.date(from: formatter.string(from: Date())) else { return 0 }

        if endDate == currentDate {
            return 1
        }

        let daysDifference = Calendar.current.dateComponents([.day], from: fromDate, to: endDate)
        let daysPassedDifference = Calendar.current.dateComponents([.day], from: fromDate, to: currentDate)

        if let days = daysDifference.day,
           let daysPassed = daysPassedDifference.day {
            return days - daysPassed
        } else {
            return 0
        }
    }

}
