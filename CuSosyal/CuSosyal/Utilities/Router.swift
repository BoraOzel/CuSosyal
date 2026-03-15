//
//  Router.swift
//  CuSosyal
//
//  Created by Bora Özel on 15/3/26.
//

import Foundation
import UIKit

class Router {
    
    static func presentInitialScreen(window: UIWindow) {
        if AuthManager.shared.isSignedIn {
            switchToApp(window: window)
        }
        else {
            switchToAuth(window: window)
        }
    }
    
    static func switchToApp(window: UIWindow) {
        window.rootViewController = MainTabBarController()
    }
    
    static func switchToAuth(window: UIWindow) {
        window.rootViewController = UINavigationController(rootViewController: LoginViewController(viewModel: LoginViewModel()))
    }
    
}
