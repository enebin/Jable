//
//  GalleryViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/05/29.
//

import UIKit
import SnapKit
import Then

class SettingViewController: UIViewController {
    private var viewModel: SettingViewModel! = nil
    private var items = [Setting]()
    
    lazy var tableView = UITableView().then {
        $0.backgroundColor = .black
        $0.delegate = self
        $0.dataSource = self
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "settingCell")
    }
    
    // MARK: - Initializers
    init(viewModel: SettingViewModel = SettingViewModel()) {
        super.init(nibName: nil, bundle: nil)
        
        // Update dependencies
        self.viewModel = viewModel
        
        // Update internal vars
        self.items = viewModel.settings
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
    }
    
    private func setLayout() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalToSuperview()
        }
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as UITableViewCell
        
        // Design cell's property
        if #available(iOS 14, *) {
            var content = cell.defaultContentConfiguration()
            content.text = items[indexPath.row].name
            content.textProperties.color = .white
            
            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = .black
            
            cell.contentConfiguration = content
            cell.backgroundConfiguration = background
        } else {
            cell.textLabel?.text = items[indexPath.row].name
            cell.textLabel?.textColor = .white
            
            cell.backgroundColor = .black
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
}
