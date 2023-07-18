import RxSwift
import RxCocoa

extension ObservableType {
    
    public func doOnNext(_ onNext: ((Self.Element) -> Swift.Void)?) -> Disposable {
        return subscribe(onNext: onNext, onError: nil, onCompleted: nil, onDisposed: nil)
    }
    
}

extension SubjectType {
    
    public func doOnNext(_ onNext: ((Self.Element) -> Swift.Void)?) -> Disposable {
        return asObservable().doOnNext(onNext)
    }
    
}

extension SharedSequence {
    
    public func doOnNext(_ onNext: ((Element) -> Swift.Void)?) -> Disposable {
        return asObservable().doOnNext(onNext)
    }
    
}
