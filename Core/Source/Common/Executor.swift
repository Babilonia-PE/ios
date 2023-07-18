import Foundation

public struct Executor {
    
    private let executionBlock: (@escaping () -> Void) -> Void
    
    public init(_ executionBlock: @escaping (@escaping () -> Void) -> Void) {
        self.executionBlock = executionBlock
    }
    
    public func execute(_ work: @escaping () -> Void) {
        executionBlock(work)
    }
}

extension Executor {
    
    public static var immediate: Executor {
        return Executor { $0() }
    }
    
    public static var main: Executor {
        return queue(.main)
    }
    
    public static var mainSync: Executor {
        return queueSync(.main)
    }
    
    public static func queue(_ queue: DispatchQueue) -> Executor {
        return Executor { work in
            queue.async(execute: work)
        }
    }
    
    public static func queueSync(_ queue: DispatchQueue) -> Executor {
        return Executor { work in
            queue.sync(execute: work)
        }
    }
    
    public static func defaultSerial(labeled label: String) -> Executor {
        let queue = DispatchQueue(
            label: IDGen.make(for: label),
            qos: .userInitiated,
            autoreleaseFrequency: .workItem
        )
        return Executor.queue(queue)
    }
    
    public static func defaultSerialSync(labeled label: String) -> Executor {
        let queue = DispatchQueue(
            label: IDGen.make(for: label),
            qos: .userInitiated,
            autoreleaseFrequency: .workItem
        )
        
        return Executor.queueSync(queue)
    }
    
}
