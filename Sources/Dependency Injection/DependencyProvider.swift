//
//  DependencyProvider.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/18/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation
import UIKit

struct DependencyList {
    init() {
        self.dependencies = [:]
    }
    
    fileprivate init(dependencies: [String: Any]) {
        self.dependencies = dependencies
    }
    
    fileprivate let dependencies: [String: Any]
    
    func with<T>(type: T.Type, instance: T) -> DependencyList {
        var deps = dependencies
        deps["\(type)"] = instance
        return DependencyList(dependencies: deps)
    }
    
    func find<T>(type: T.Type) -> T? {
        return dependencies["\(type)"].flatMap { $0 as? T }
    }
}

protocol DependencyProvider {
    var dependencyList: DependencyList { get }
}

func inject<T>(type: T.Type,
               responder: UIResponder,
               fallback: @autoclosure () -> (T)) -> T {
    let target =
        responder.target(forAction: Selector(("dependencyProvider")), withSender: nil) ??
        UIApplication.shared.target(forAction: Selector(("dependencyProvider")), withSender: nil)
    
    let provider = target.flatMap { $0 as? DependencyProvider }
    let dependency = provider.flatMap { $0.dependencyList.find(type: type) }
    
    return dependency ?? fallback()
}
