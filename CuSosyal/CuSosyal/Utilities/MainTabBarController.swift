//
//  MainTabBarController.swift
//  CuSosyal
//
//  Created by Bora Özel on 3/3/26.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [createHomeNC()]
        configureTabBarAppearance()
    }
    
    func createHomeNC() -> UINavigationController {
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        return UINavigationController(rootViewController: homeVC)
    }
    
    func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        tabBar.tintColor = UIColor.accent
        tabBar.unselectedItemTintColor = UIColor.darkGray
    }
    
}
