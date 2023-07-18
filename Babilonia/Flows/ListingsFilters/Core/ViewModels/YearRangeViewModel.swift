//
//  YearRangeViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 07.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import RxSwift
import RxCocoa

typealias FilterYearValue = (bound: YearBound, titles: [String], startingIndex: Int)

enum YearBound {
    case fromYear
    case toYear
}

final class YearRangeViewModel {

    let proceedYearPicker: BehaviorRelay<FilterYearValue>
    let fromTextValue = BehaviorRelay<String>(value: "0")
    let toTextValue = BehaviorRelay<String>(value: "0")

    var minAvailableYear: Int {
        values[0]
    }
    
    var maxAvailableYear: Int {
        values[values.count - 1]
    }

    var fromYearTitles: [String] {
        var years = [Int]()
        for (index, value) in values.enumerated() where index <= toSelectedYear {
            years.append(value)
        }

        return years.map { "\($0)" }
    }

    var toYearTitles: [String] {
        var years = [Int]()
        for (index, value) in values.enumerated() where index >= fromSelectedYear {
            years.append(value)
        }

        return years.map { "\($0)" }
    }

    private let values = [Int](1900...Calendar.current.component(.year, from: Date()))
    private var fromSelectedYear: Int = 0
    private var toSelectedYear: Int = 0

    lazy var fromFieldViewModel: InputFieldViewModel = {
        let viewModel = InputFieldViewModel(title: BehaviorRelay(value: L10n.Filters.Range.from),
                                            text: fromTextValue,
                                            validator: nil,
                                            editingMode: .action { [weak self] in
                                                self?.presentYearPicker(bound: .fromYear)
                                            },
                                            image: nil,
                                            placeholder: nil)

        return viewModel
    }()
    lazy var toFieldViewModel: InputFieldViewModel = {
        let viewModel = InputFieldViewModel(title: BehaviorRelay(value: L10n.Filters.Range.to),
                                            text: toTextValue,
                                            validator: nil,
                                            editingMode: .action { [weak self] in
                                                self?.presentYearPicker(bound: .toYear)
                                            },
                                            image: nil,
                                            placeholder: nil)

        return viewModel
    }()

    init(proceedYearPicker: BehaviorRelay<FilterYearValue>) {
        self.proceedYearPicker = proceedYearPicker

        fromSelectedYear = 0
        toSelectedYear = values.count - 1
        fromTextValue.accept(fromYearTitles[0])
        toTextValue.accept(toYearTitles[toYearTitles.count - 1])
    }

    func updateYearRange(for bound: YearBound, yearIndex: Int) {
        switch bound {
        case .fromYear:
            let year = fromYearTitles[yearIndex]
            fromSelectedYear = values.map { "\($0)" }.firstIndex(of: year) ?? yearIndex
            fromTextValue.accept(year)

        case .toYear:
            let year = toYearTitles[yearIndex]
            toSelectedYear = values.map { "\($0)" }.firstIndex(of: year) ?? yearIndex
            toTextValue.accept(year)
        }
    }

    func reset() {
        fromSelectedYear = values[0]
        toSelectedYear = values[values.count - 1]
        fromTextValue.accept("\(fromSelectedYear)")
        toTextValue.accept("\(toSelectedYear)")
    }

    func presetSelectedYears(fromYear: Int?, toYear: Int?) {
        let fromIndex = values.firstIndex(of: fromYear ?? values[0]) ?? 0
        updateYearRange(for: .fromYear, yearIndex: fromIndex)

        let toIndex = toYearTitles.firstIndex(of: "\(toYear ?? values[values.count - 1])") ?? values.count - 1
        updateYearRange(for: .toYear, yearIndex: toIndex)
    }

    private func presentYearPicker(bound: YearBound) {
        let titles = bound == .fromYear ? fromYearTitles : toYearTitles
        let year = bound == .fromYear ? fromTextValue.value : toTextValue.value
        let startingIndex = titles.firstIndex(of: year) ?? 0
        proceedYearPicker.accept((bound: bound, titles: titles, startingIndex: startingIndex))
    }

}
