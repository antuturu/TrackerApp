//
//  AppDelegate.swift
//  TrackerApp
//
//  Created by Александр Акимов on 13.02.2024.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow()
        let onboardingViewController = OnboardingViewController()
        let tabBarController = TabBarController()
        var initialViewController: UIViewController
        if UserDefaults.standard.string(forKey: "Logined") == "true" {
            initialViewController = tabBarController
        } else {
            initialViewController = onboardingViewController
        }
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        return true
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
