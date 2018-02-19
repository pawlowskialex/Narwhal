//
//  Optional+Ext.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/18/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation

extension Optional {
    func get(or else: @autoclosure () throws -> (Wrapped)) rethrows -> Wrapped {
        return try self ?? `else`()
    }
}
