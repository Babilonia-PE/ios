//
//  UITableView+Rx.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public extension Reactive where Base: UITableView {

    /// Binds sequences of elements to table view rows. Reusable identified is set to the same as class name.
    ///
    /// - Parameter cellType: Type of table view cell.
    /// - Returns: Disposable object that can be used to unbind.
    func items<S: Sequence, Cell: UITableViewCell, O: ObservableType>
        (cellType: Cell.Type)
        -> (_ source: O)
        -> (_ configureCell: @escaping (Int, S.Iterator.Element, Cell) -> Void)
        -> Disposable where O.Element == S {
            return items(cellIdentifier: String(describing: cellType), cellType: cellType)
    }
}
