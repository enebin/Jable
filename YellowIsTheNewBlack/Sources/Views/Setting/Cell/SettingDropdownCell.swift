//
//  SettingDropdownCell.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/21.
//

import UIKit
import SnapKit
import Then

class SettingDropdownCell: UITableViewCell, CustomCell {
    typealias Item = SettingCellItem

    private var cellItem: SettingCellItem? {
        didSet {
            if let cellItem = cellItem {
                setLayout(with: cellItem)
            } else {
                let emptyCellItem = SettingCellItem()
                setLayout(with: emptyCellItem)
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setCellItem(_ cellItem: SettingCellItem?) {
        self.cellItem = cellItem
    }
}
