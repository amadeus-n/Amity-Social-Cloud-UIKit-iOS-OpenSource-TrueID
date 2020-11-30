//
//  UINavigationController+Extension.swift
//  UpstraUIKit
//
//  Created by Sarawoot Khunsri on 14/7/2563 BE.
//  Copyright © 2563 Eko Communication. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func setBackgroundColor(with color: UIColor, shadow: Bool = false) {
        if !shadow {
            navigationBar.shadowImage = UIImage()
        }
    }
    
    func reset() {
        navigationBar.backgroundColor = nil
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = nil
    }
    
}