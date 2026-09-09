//
//  MainTabBarController.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 04/09/26.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        tabBar.tintColor = .accent
    }
    
    private func setupView() {
        let homeVC = HomeViewController()
        let searchVC = SearchViewController()
        let libraryVC = LibraryViewController()
        
        let homeNav = UINavigationController(rootViewController: homeVC)
        let searchNav = UINavigationController(rootViewController: searchVC)
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "house"), tag: 0)
        searchNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "magnifyingglass"), tag: 1)
        libraryNav.tabBarItem = UITabBarItem(title: "Library", image: UIImage(named: "line.3.horizontal"), tag: 2)
        
        setViewControllers([homeNav, searchNav, libraryNav], animated: false)
    }
}
