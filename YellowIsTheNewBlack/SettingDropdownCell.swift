//
//  SettingDropdownCell.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/21.
//

import UIKit
import SnapKit
import Then

class SettingDropdownCell: UITableViewCell {
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
    
    private func setLayout() {
        let cell = self
        
        if #available(iOS 14, *) {
            var content = cell.defaultContentConfiguration()
            content.textProperties.color = .white
            
            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = .gray.withAlphaComponent(0.2)
            
            cell.contentConfiguration = content
            cell.backgroundConfiguration = background
        } else {
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .gray.withAlphaComponent(0.2)
        }
    }
    
    private func setLayout(with cellItem: SettingCellItem) {
        let cell = self
        let text = cellItem.title
        
        if #available(iOS 14, *) {
            var configuration = cell.contentConfiguration as! UIListContentConfiguration
            
            configuration.text = cellItem.title
            configuration.image = cellItem.image
            
            cell.contentConfiguration = configuration
        } else {
            cell.textLabel?.text = text
        }
    }
}
