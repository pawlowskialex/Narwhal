//
//  Observable+Operators.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation

extension Observable {
    func retry(count: Int) -> Observable<Element> {
        return RetryObservable(retryCount: count, wrappedObservable: self)
    }
    
    func retry() -> Observable<Element> {
        return RetryObservable(retryCount: nil, wrappedObservable: self)
    }
    
    func map<R>(transform: @escaping (Element) throws -> (R)) -> Observable<R> {
        return MappedObservable(transform: transform, wrappedObservable: self)
    }
    
    func observe(on queue: DispatchQueue = .main) -> Observable<Element> {
        return DispatchedObservable(queue: queue, wrappedObservable: self)
    }
    
    func subscribe(onNext: ((Element) -> ())? = nil,
                   onComplete: (() -> ())? = nil,
                   onError: ((Error) -> ())? = nil) -> DisposableType {
        
        return subscribe(Observer(onNext: onNext,
                                  onComplete: onComplete,
                                  onError: onError))
    }
    
    func subscribe<T>(target: T,
                      onNext: ((T, Element) -> ())? = nil,
                      onComplete: ((T) -> ())? = nil,
                      onError: ((T, Error) -> ())? = nil) -> DisposableType where T: AnyObject {
        
        func weak<A>(nonvoid: ((T, A) -> ())?) -> ((A) -> ()) {
            return { [weak target] element in
                if let target = target, let action = nonvoid {
                    action(target, element)
                }
            }
        }
        
        func weak(void: ((T) -> ())?) -> (() -> ()) {
            return { weak(nonvoid: { (t: T, _: ()) in void?(t) })(()) }
        }
        
        return subscribe(onNext: weak(nonvoid: onNext),
                         onComplete: weak(void: onComplete),
                         onError: weak(nonvoid: onError))
    }
}

class MappedObservable<A, R>: Observable<R> {
    private let transform: (A) throws -> (R)
    private let wrappedObservable: Observable<A>
    
    init(transform: @escaping (A) throws -> (R), wrappedObservable: Observable<A>) {
        self.transform = transform
        self.wrappedObservable = wrappedObservable
    }
    
    override func subscribe<O>(_ observer: O) -> DisposableType where R == O.Element, O : ObserverType {
        let transform = self.transform
        let handler = Observer<A>(
            onNext: { next in
                do { try observer.onNext(transform(next)) }
                catch { observer.onError(error) }
            },
            onComplete: observer.onComplete,
            onError: observer.onError
        )
        
        return wrappedObservable.subscribe(handler)
    }
}

class DispatchedObservable<E>: Observable<E> {
    private let queue: DispatchQueue
    private let wrappedObservable: Observable<E>
    
    init(queue: DispatchQueue, wrappedObservable: Observable<E>) {
        self.queue = queue
        self.wrappedObservable = wrappedObservable
    }
    
    override func subscribe<O>(_ observer: O) -> DisposableType where E == O.Element, O : ObserverType {
        let queue = self.queue
        let handler = Observer<E>(
            onNext: { next in queue.async { observer.onNext(next) }},
            onComplete: { queue.async { observer.onComplete() }},
            onError: { error in queue.async { observer.onError(error) }}
        )
        
        return wrappedObservable.subscribe(handler)
    }
}

class RetryObservable<E>: Observable<E> {
    private var retryCount: Int?
    private let wrappedObservable: Observable<E>
    
    init(retryCount: Int?, wrappedObservable: Observable<E>) {
        self.retryCount = retryCount
        self.wrappedObservable = wrappedObservable
    }
    
    override func subscribe<O: ObserverType>(_ observer: O) -> DisposableType where O.Element == Element {
        var subscription: DisposableType!
        var handler: Observer<E>!
        
        handler = Observer<E>(
            onNext: observer.onNext,
            onComplete: observer.onComplete,
            onError: { error in
                if let retryCount = self.retryCount {
                    guard retryCount > 0
                        else { return observer.onError(error) }
                    
                    self.retryCount = retryCount - 1
                }

                print("retry error: \(error)")
                
                subscription?.dispose()
                subscription = self.wrappedObservable.subscribe(handler)
        })
        
        subscription = wrappedObservable.subscribe(handler)
        
        return Disposable {
            subscription?.dispose()
        }
    }
}
