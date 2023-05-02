//
//  ToolBaritem.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/10.
//

import UIKit

protocol ToolbarItem: UIViewController {
    typealias Action = () -> Void
    typealias SettingAction = (Setting) -> Void

    var backButtonAction: Action? { get set }
    func onBackButtonTapped(_ action: @escaping Action)

    var elementButtonAction: SettingAction? { get set }
    func onElementButtonTapped(_ action: @escaping SettingAction)
}
