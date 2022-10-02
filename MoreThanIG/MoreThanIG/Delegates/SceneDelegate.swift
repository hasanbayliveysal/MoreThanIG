//
//  SceneDelegate.swift
//  MoreThanIG
//
//  Created by Veysal on 13.09.22.
//

import UIKit
import Firebase
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      
        let currentUser = Auth.auth().currentUser
        if currentUser != nil {
            let board = UIStoryboard(name: "Main", bundle: nil)
            let tabBar = board.instantiateViewController(withIdentifier: "toHomeVC")
            self.window?.rootViewController = tabBar
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
     
    }

    func sceneWillResignActive(_ scene: UIScene) {
       
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
       
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

