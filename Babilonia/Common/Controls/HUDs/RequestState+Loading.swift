import RxSwift

extension Observable where Element == RequestState {
    
    var isLoading: Observable<Bool> {
        return map {
            if case .started = $0 {
                return true
            } else {
                return false
            }
        }
    }
    
}
