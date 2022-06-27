//
//  SettingOptionsViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/25.
//

import UIKit

class SettingOfVideoQualityViewController: UIViewController {
    // Dependencies
    var viewModel: SettingOfVideoQualityViewModel! = nil
    
    // UI comps.
    lazy var tableView = UITableView().then {
        $0.backgroundColor = .black
        $0.delegate = self
        $0.dataSource = self
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "VQCell")
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = .black
        
        navigationItem.largeTitleDisplayMode = .never
        
        self.viewModel = SettingOfVideoQualityViewModel()
        self.setLayout()
    }
    
    func setLayout() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalToSuperview()
        }
    }
}

extension SettingOfVideoQualityViewController: UITableViewDelegate {}

extension SettingOfVideoQualityViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "화질"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "VQCell", for: indexPath) as UITableViewCell
        
        if #available(iOS 14, *) {
            var content = cell.defaultContentConfiguration()
            content.text = viewModel.options[indexPath.row]
            content.textProperties.color = .white
            
            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = .systemGray6
            
            cell.contentConfiguration = content
            cell.backgroundConfiguration = background
        } else {
            cell.textLabel?.text = viewModel.options[indexPath.row]
            cell.textLabel?.textColor = .white
            
            cell.backgroundColor = .black
        }
        
        return cell
    }
}
