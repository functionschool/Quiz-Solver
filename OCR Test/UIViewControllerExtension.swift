//
//  UIViewControllerExtension.swift
//  OCR Test
//
//  Created by Kousei Richeson on 5/4/18.
//  Copyright © 2018 Kousei Richeson. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
