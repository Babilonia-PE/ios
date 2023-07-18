import Swinject
import SwinjectAutoregistration

extension Container {
    
    @discardableResult
    public func autoregister<Service, Arg1>(
        argument arg1: Arg1.Type,
        initializer: @escaping (Arg1, Resolver) -> Service
    ) -> Swinject.ServiceEntry<Service> {
        return register(Service.self, factory: { (resolver: Resolver, argument: Arg1) -> Service in
            return initializer(argument, resolver)
        })
    }
    
    @discardableResult
    public func autoregister<Service>(initializer: @escaping () -> Service) -> Swinject.ServiceEntry<Service> {
        return register(Service.self, factory: { _ -> Service in
            return initializer()
        })
    }
    
    @discardableResult
    public func autoregister<Service, Arg1>(
        initializer: @escaping (Arg1, Resolver) -> Service
    ) -> Swinject.ServiceEntry<Service> {
        return register(Service.self, factory: { (resolver, argument) -> Service in
            return initializer(argument, resolver)
        })
    }
    
}
