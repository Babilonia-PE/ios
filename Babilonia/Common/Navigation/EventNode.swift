//
//  EventNode.swift
//
//  Copyright © 2018 Yalantis. All rights reserved.
//

import Foundation

protocol Event {}

protocol EventDrivenInterface {
    
    func propagate<T: Event>(event: T)
    func raise<T: Event>(event: T)
    func addHandler<T: Event>(_ handler: @escaping (T) -> Void)
    
}

public class EventNode: EventDrivenInterface {
    
    private var parent: EventNode?
    private lazy var children = NSHashTable<EventNode>.weakObjects()
    private var eventHandlerContainers: [String: Any] = [:]
    
    fileprivate let identifier = ProcessInfo.processInfo.globallyUniqueString
    
    init() {}
    
    init(parent: EventNode) {
        parent.addChild(self)
    }
    
    func propagate<T: Event>(event: T) {
        let type = String(describing: T.self)
        guard let handler = eventHandlerContainers[type] as? EventHandlersContainer<T> else {
            children.allObjects.forEach {
                $0.propagate(event: event)
            }
            
            return
        }
        
        handler.propagate(event: event)
    }
    
    func raise<T: Event>(event: T, from sender: EventDrivenInterface) {
        guard let parent = parent else {
            propagate(event: event)
            
            return
        }
        
        let type = String(describing: T.self)
        guard let handler = eventHandlerContainers[type] as? EventHandlersContainer<T> else {
            parent.raise(event: event, from: sender)
            
            return
        }
        
        handler.propagate(event: event)
    }
    
    func raise<T: Event>(event: T) {
        // because we're using event for routing only it would be better to dispatch it directly to main queue
        DispatchQueue.main.async {
            self.raise(event: event, from: self)
        }
    }
    
    func addChild(_ child: EventNode) {
        child.parent = self
        children.add(child)
    }
    
    func removeChild(_ child: EventNode) {
        children.remove(child)
    }
    
    func addHandler<T: Event>(_ handler: @escaping (T) -> Void) {
        let type = String(describing: T.self)
        var container = eventHandlerContainers[type]
        if container == nil {
            container = EventHandlersContainer<T>()
            eventHandlerContainers[type] = container
        }
        if let container = container as? EventHandlersContainer<T> {
            container.add(handler: handler)
        }
    }
    
}

private class EventHandlersContainer<T> {
    
    private var handlers: [(T) -> Void] = []
    private var lastOpenedEventDescription = ""
    private var lastTimeEventOpened: TimeInterval = 0
    
    func add(handler: @escaping (T) -> Void) {
        handlers.append(handler)
    }
    
    func propagate(event: T) {
        // events throtteling
        let now = Date().timeIntervalSince1970
        let currentEventDescription = String(describing: event)
        let shouldSkipEvent = currentEventDescription == lastOpenedEventDescription && (now - lastTimeEventOpened < 1)
        if shouldSkipEvent {
            return
        }
        lastTimeEventOpened = now
        lastOpenedEventDescription = currentEventDescription
        
        for handler in handlers {
            handler(event)
        }
    }
    
}
