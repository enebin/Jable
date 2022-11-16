//
//  SceneDelegate.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/05/29.
//

import UIKit
import StoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        
        window?.overrideUserInterfaceStyle = .light // Disable darkmode
        window?.windowScene = windowScene
        window?.rootViewController = VideoRecorderViewController()
        window?.makeKeyAndVisible()
        
        let isAppOpenedCount = appOpenedCount(true)
        if isAppOpenedCount == 2 || isAppOpenedCount == 5 || isAppOpenedCount == 8 {
            SKStoreReviewController.requestReview()
            print("@@", isAppOpenedCount)
        }
        
    }
}

extension SceneDelegate {
    func appOpenedCount(_ add: Bool) -> Int {
        let count = UserDefaults.standard.integer(forKey: "isAppOpenedCount")
        if add {
            UserDefaults.standard.set(count + 1, forKey: "isAppOpenedCount")
        }
        
        return count
    }
}

