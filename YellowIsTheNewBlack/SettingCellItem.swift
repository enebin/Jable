//
//  SettingCellItem.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/21.
//

import UIKit

struct SettingCellItem: CellItem {
    typealias Action = () -> Void
    
    var title: String?
    var image: UIImage?
    
    var actionType: ActionType?
    var action: Action?
}

enum ActionType  {
    case toggle
    case dropdown
}
