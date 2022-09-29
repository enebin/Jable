//
//  SceneDelegate.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/05/29.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        
        window?.overrideUserInterfaceStyle = .light // Disable darkmode
        window?.windowScene = windowScene
        window?.rootViewController = VideoRecorderViewController()
        window?.makeKeyAndVisible()
    }
}

