//
//  Lock.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/17/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation

struct Lock {
    private var _lock = os_unfair_lock()
    
    mutating func lock() {
        os_unfair_lock_lock(&_lock)
    }
    
    mutating func unlock() {
        os_unfair_lock_unlock(&_lock)
    }
}
