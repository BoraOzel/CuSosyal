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
        viewControllers = [createHomeNC(), createCommunityNC(), createFavouriteClubsNC(), createEventsNC(), createAiChatNC()]
        configureTabBarAppearance()
    }
    
    func createHomeNC() -> UINavigationController {
        let homeVC = HomeViewController(viewModel: HomeViewModel())
        homeVC.tabBarItem = UITabBarItem(title: "Anasayfa", image: UIImage(systemName: "house.fill"), tag: 0)
        return UINavigationController(rootViewController: homeVC)
    }
    
    func createCommunityNC() -> UINavigationController {
        let communityVC = CommunitiesViewController()
        communityVC.tabBarItem = UITabBarItem(title: "Kulüpler", image: UIImage(systemName: "graduationcap.fill"), tag: 1)
        return UINavigationController(rootViewController: communityVC)
    }
    
    func createFavouriteClubsNC() -> UINavigationController {
        let favouriteClubsVC = FavouriteClubsViewController()
        favouriteClubsVC.tabBarItem = UITabBarItem(title: "Favoriler", image: UIImage(systemName: "star.fill"), tag: 2)
        return UINavigationController(rootViewController: favouriteClubsVC)
    }
    
    func createEventsNC() -> UINavigationController {
        let eventsVC = EventsViewController(viewModel: EventsViewModel())
        eventsVC.tabBarItem = UITabBarItem(title: "Etkinlikler", image: UIImage(systemName: "calendar"), tag: 3)
        return UINavigationController(rootViewController: eventsVC)
    }
    
    func createAiChatNC() -> UINavigationController {
        let aiChatVC = AIChatViewController(viewModel: AIChatViewModel())
        aiChatVC.tabBarItem = UITabBarItem(title: "AI Asistan", image: UIImage(systemName: "sparkles"), tag: 4)
        return UINavigationController(rootViewController: aiChatVC)
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
