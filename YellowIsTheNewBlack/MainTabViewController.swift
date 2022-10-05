//
//  ViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/05/29.
//

import UIKit
import Then

class MainTabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .yellow
        tabBar.backgroundColor = .black
        tabBar.unselectedItemTintColor = .white
        
        let firstVC = VideoRecorderViewController()
        firstVC.tabBarItem = UITabBarItem(title: "녹화", image: UIImage(systemName: "record.circle"), tag: 0)
        
        let secondVC = GalleryViewController()
        secondVC.tabBarItem = UITabBarItem(title: "앨범", image: UIImage(systemName: "rectangle.stack"), tag: 1)
        
        var tabs = [firstVC, secondVC]
        tabs = tabs.map { vc in
            UINavigationController(rootViewController: vc)
        }
        
//        self.setViewControllers(tabs, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        present(VideoRecorderViewController(), animated: false)
    }
}

