import Foundation
import Swinject
import SwinjectAutoregistration

extension Resolver {
    
    public func autoresolve<T, Arg1: EventNode>(argument: Arg1) -> T! {
        return resolve(T.self, argument: argument as EventNode)
    }
    
    public func autoresolve<T, Arg1: EventNode, Arg2>(arguments arg1: Arg1, _ arg2: Arg2) -> T! {
        return resolve(T.self, arguments: arg1 as EventNode, arg2)
    }
    
    public func autoresolve<T, Arg1: EventNode, Arg2, Arg3>(
        arguments arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3
        ) -> T! {
        return resolve(T.self, arguments: arg1 as EventNode, arg2, arg3)
    }
    
    public func autoresolve<T, Arg1: EventNode, Arg2, Arg3, Arg4>(
        arguments arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4
        ) -> T! {
        return resolve(T.self, arguments: arg1 as EventNode, arg2, arg3, arg4)
    }
    
    public func autoresolve<T, Arg1, Arg2: EventNode>(arguments arg1: Arg1, _ arg2: Arg2) -> T! {
        return resolve(T.self, arguments: arg1, arg2 as EventNode)
    }
}
