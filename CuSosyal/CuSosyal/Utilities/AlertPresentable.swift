//
//  AlertPresentable.swift
//  CuSosyal
//
//  Created by Bora Özel on 15/3/26.
//

import Foundation

import Foundation
import UIKit

public enum AlertActionType {
    case ok
    case cancel
    case retry
}

public typealias AlertPresentableHandler = ((AlertActionType) -> Void)

public protocol AlertPresentable {
    func showAlert(title: String?,
                   message: String?,
                   buttonText: String?,
                   handler: AlertPresentableHandler?)
}

extension AlertPresentable where Self: UIViewController {
    
    func showAlert(title: String? = nil,
                   message: String? = nil,
                   buttonText: String? = nil,
                   handler: AlertPresentableHandler? = nil) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: buttonText,
                                        style: .default) { _ in
            handler?(.retry)
        }
        
        alert.addAction(retryAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

