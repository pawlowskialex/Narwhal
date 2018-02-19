//
//  Observable.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation

protocol ObservableType {
    associatedtype Element
    
    func subscribe<O: ObserverType>(_ observer: O) -> DisposableType where O.Element == Element
}

class Observable<E> : ObservableType {
    typealias Element = E
    
    func subscribe<O: ObserverType>(_ observer: O) -> DisposableType where O.Element == Element {
        fatalError("not implemented")
    }
    
    static func create(_ subscribe: @escaping (AnyObserver<Element>) throws -> DisposableType) -> Observable<E> {
        return AnonymousObservable(subscribe)
    }
    
    static func value(_ value: E) -> Observable<E> {
        return .create { observer in
            observer.onNext(value)
            observer.onComplete()
            return Disposable()
        }
    }
    
    static func error<ER>(_ error: ER) -> Observable<E> where ER: Error {
        return .create { observer in
            observer.onError(error)
            return Disposable()
        }
    }
}

class AnonymousObservable<E>: Observable<E> {
    private let _subscribe: (AnyObserver<Element>) throws -> DisposableType
    
    init(_ subscribe: @escaping (AnyObserver<Element>) throws -> DisposableType) {
        _subscribe = subscribe
    }
    
    override func subscribe<O: ObserverType>(_ observer: O) -> DisposableType where O.Element == Element {
        do { return try _subscribe(AnyObserver(observer)) }
        catch {
            observer.onError(error)
            return Disposable()
        }
    }
}
