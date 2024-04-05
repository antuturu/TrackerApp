//
//  TabBarController.swift
//  TrackerApp
//
//  Created by Александр Акимов on 05.04.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let trackersNavigationController = storyboard.instantiateViewController(withIdentifier: "TrackersView")
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "TrackerLogoTabBar.png"),
            selectedImage: nil)
        
        let statisticsViewController = storyboard.instantiateViewController(withIdentifier: "StatisticView")
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "StatisticLogoTabBar.png"),
            selectedImage: nil)
        
        self.viewControllers = [trackersNavigationController, statisticsViewController]
    }
}
