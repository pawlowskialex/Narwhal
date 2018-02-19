//
//  BehaviorSubject.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/17/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation

class BehaviorSubject<E>: Observable<E>, ObserverType, DisposableType {
    typealias Element = E
    
    private var _value: E?
    private var observers: [Int : AnyObserver<E>] = [:]
    private var lock = Lock()
    
    init(value: E? = nil) {
        self._value = value
    }
    
    var value: E? {
        return synchronized { _value }
    }
    
    func onNext(_ element: E) {
        synchronized {
            _value = element
            send { $0.onNext(element) }
        }
    }
    
    func onComplete() {
        synchronized {
            _value = nil
            send { $0.onComplete() }
        }
    }
    
    func onError(_ error: Error) {
        synchronized {
            _value = nil
            send { $0.onError(error) }
        }
    }
    
    override func subscribe<O>(_ observer: O) -> DisposableType where E == O.Element, O : ObserverType {
        return synchronized {
            let key = Int(arc4random())
            let wrappedObserver = AnyObserver(observer)
            
            if let value = _value {
                wrappedObserver.onNext(value)
            }
            
            observers[key] = wrappedObserver
            
            return Disposable { [weak self] in
                guard let strongSelf = self
                    else { return }
                
                strongSelf.synchronized {
                    _ = strongSelf.observers.removeValue(forKey: key)
                }
            }
        }
    }
    
    private func send(action: (AnyObserver<E>) -> ()) {
        for (_, observer) in observers {
            action(observer)
        }
    }
    
    private func synchronized<T>(action: () -> (T)) -> T {
        lock.lock()
        defer { lock.unlock() }
        return action()
    }
    
    func dispose() {
        synchronized {
            self.observers = [:]
            self._value = nil
        }
    }
}
