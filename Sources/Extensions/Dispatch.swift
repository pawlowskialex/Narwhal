//
//  Dispatch.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/17/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation

func executeOnMain(_ action: @escaping @convention(block) () -> ()) {
    if Thread.current.isMainThread { action() }
    else { DispatchQueue.main.async(execute: action) }
}
