//
//  UIImage+Ext.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let aspect = self.size.width / self.size.height
        let rect: CGRect
        if targetSize.width / aspect > targetSize.height {
            let height = targetSize.width / aspect
            rect = CGRect(x: 0.0, y: (targetSize.height - height) / 2.0,
                          width: targetSize.width, height: height)
        } else {
            let width = targetSize.height * aspect
            rect = CGRect(x: (targetSize.width - width) / 2.0, y: 0.0,
                          width: width, height: targetSize.height)
        }
        
        UIGraphicsBeginImageContextWithOptions(targetSize, true, UIScreen.main.scale)
        
        guard let _ = UIGraphicsGetCurrentContext()
            else { return self }
        
        self.draw(in: rect)
        
        guard let resized = UIGraphicsGetImageFromCurrentImageContext()
            else { return self }
        
        UIGraphicsEndImageContext()
        
        return resized
    }
}
