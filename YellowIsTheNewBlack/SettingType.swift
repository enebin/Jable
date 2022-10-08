//
//  SettingType.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/26.
//

import UIKit

protocol SettingType {
    var title: String { get }
    var icon: UIImage { get }
    var options: [SettingOption] { get }
}

extension SettingType {
    func toActionSheet() -> UIAlertController {
        let alertController = UIAlertController()
        
        for option in self.options {
            let alertAction = UIAlertAction(title: option.title, style: .default) { _ in
                option.action()
            }

            alertController.addAction(alertAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        return alertController
    }
}

struct SettingOption {
    let title: String
    let action: () -> Void
}


