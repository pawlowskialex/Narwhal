//
//  Disposable.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation

protocol DisposableType {
    func dispose()
}

extension DisposableType {
    func disposed(by disposeBag: DisposeBag) {
        disposeBag.add(self)
    }
    
    func unsubcribedOnDeinit() -> DisposableType {
        return DeinitDisposable(self)
    }
}

struct Disposable: DisposableType {
    private let _dispose: (() -> Void)?
    
    init(_ dispose: (() -> Void)? = nil) {
        _dispose = dispose
    }
    
    func dispose() {
        _dispose?()
    }
}

class DeinitDisposable: DisposableType {
    private let disposable: DisposableType
    
    init(_ disposable: DisposableType) {
        self.disposable = disposable
    }
    
    func dispose() {
        self.disposable.dispose()
    }
    
    deinit {
        self.dispose()
    }
}

class DisposeBag {
    private var lock = Lock()
    private var disposables: [DisposableType] = []
    
    func add(_ disposable: DisposableType) {
        lock.lock()
        disposables.append(disposable)
        lock.unlock()
    }
    
    deinit {
        lock.lock()
        for disposable in disposables { disposable.dispose() }
        lock.unlock()
    }
}
