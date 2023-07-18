import Foundation
import Swinject
import SwinjectAutoregistration

extension Resolver {

    public func autoresolve<T>() -> T! {
        return resolve(T.self)
    }

    public func autoresolve<T>(name: String) -> T! {
        return resolve(T.self, name: name)
    }

    public func autoresolve<T, Arg1>(argument: Arg1) -> T! {
        return resolve(T.self, argument: argument)
    }
}
