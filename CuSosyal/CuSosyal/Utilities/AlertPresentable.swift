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
    func showConfirmationAlert(title: String?,
                               message: String?,
                               confirmText: String,
                               cancelText: String,
                               handler: AlertPresentableHandler?)
    func showTextInputAlert(title: String?,
                            message: String?,
                            placeholder: String,
                            isSecure: Bool,
                            confirmText: String,
                            confirmStyle: UIAlertAction.Style,
                            cancelText: String,
                            handler: ((String?) -> Void)?)
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
    
    func showConfirmationAlert(title: String?,
                               message: String?,
                               confirmText: String = "Evet",
                               cancelText: String = "Hayır",
                               handler: AlertPresentableHandler?) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: confirmText, style: .default) { _ in
            handler?(.ok)
        }
        let cancelAction = UIAlertAction(title: cancelText, style: .cancel) { _ in
            handler?(.cancel)
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func showTextInputAlert(title: String? = nil,
                            message: String? = nil,
                            placeholder: String = "",
                            isSecure: Bool = false,
                            confirmText: String = "Tamam",
                            confirmStyle: UIAlertAction.Style = .default,
                            cancelText: String = "İptal",
                            handler: ((String?) -> Void)? = nil) {

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.isSecureTextEntry = isSecure
        }

        let confirmAction = UIAlertAction(title: confirmText, style: confirmStyle) { [weak alert] _ in
            handler?(alert?.textFields?.first?.text)
        }
        let cancelAction = UIAlertAction(title: cancelText, style: .cancel) { _ in
            handler?(nil)
        }

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
}

