//
//  UIViewController+Keyboard.swift
//  CuSosyal
//
//  Created by Bora Özel on 30/5/26.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardGesture))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardGesture() {
        view.endEditing(true)
    }
}

