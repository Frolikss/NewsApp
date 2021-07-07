//
//  SceneDelegate.swift
//  NewsApp
//
//  Created by Dima on 04.06.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate),
              let tabBarVC = window?.rootViewController as? UITabBarController,
              let navBarVC = tabBarVC.viewControllers?[2] as? UINavigationController,
              let vc = navBarVC.topViewController as? FavoritesViewController else { return }
        vc.context = appDelegate.persistentContainer.viewContext
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

