//
//  Observer.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation

protocol ObserverType {
    associatedtype Element
    
    func onNext(_ element: Element)
    func onComplete()
    func onError(_ error: Error)
}

final class AnyObserver<E>: ObserverType {
    typealias Element = E
    
    private let _onNext: (Element) -> Void
    private let _onComplete: () -> Void
    private let _onError: (Error) -> Void
    
    init<O: ObserverType>(_ observer: O) where O.Element == Element {
        _onNext = observer.onNext
        _onComplete = observer.onComplete
        _onError = observer.onError
    }
    
    func onNext(_ element: Element) {
        return _onNext(element)
    }
    
    func onComplete() {
        return _onComplete()
    }
    
    func onError(_ error: Error) {
        return _onError(error)
    }
}

final class Observer<E>: ObserverType {
    typealias Element = E
    
    private let _onNext: ((Element) -> Void)?
    private let _onComplete: (() -> Void)?
    private let _onError: ((Error) -> Void)?
    
    init(onNext: ((Element) -> ())? = nil, onComplete: (() -> ())? = nil, onError: ((Error) -> ())? = nil) {
        _onNext = onNext
        _onComplete = onComplete
        _onError = onError
    }
    
    func onNext(_ element: Element) {
        _onNext?(element)
    }
    
    func onComplete() {
        _onComplete?()
    }
    
    func onError(_ error: Error) {
        _onError?(error)
    }
}
