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
    // Common constants
    private var commonConfiguration: VideoRecorderConfiguration
    
    // Dependencies
    private var viewModel: SettingViewModel! = nil
    private var items = [Setting]()
    
    lazy var tableView = UITableView().then {
        $0.backgroundColor = .black
        $0.delegate = self
        $0.dataSource = self
        $0.register(SettingDropdownCell.self, forCellReuseIdentifier: "settingCell")
    }
    
    private func showMenu() {
        self.moreActionTapped()
    }
    
    @objc func moreActionTapped() {
        let alert = UIAlertController(title: nil, message: "I18N.actionsheetMessage", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "I18N.modify", style: .default, handler: { _ in })
        let saveAction = UIAlertAction(title: "I18N.delete", style: .destructive, handler: { _ in })
        
        alert.addAction(deleteAction)
        alert.addAction(saveAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Initializers
    init(viewModel: SettingViewModel = SettingViewModel(),
         videoConfig: VideoRecorderConfiguration) {
        // Update dependencies
        self.viewModel = viewModel
        
        // Update internal vars
        self.items = viewModel.settings
        
        //
        self.commonConfiguration = videoConfig
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let largeTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = largeTitleAttributes
        
        
        let smallTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = smallTitleAttributes
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "녹화"
        
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

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = SettingOfVideoQualityViewController()
        
        self.showMenu()
    }
}

extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->  UITableViewCell {
        let cell: SettingDropdownCell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingDropdownCell
        
        cell.setCellItem(nil)
        cell.setCellItem(SettingCellItem(title: "화질", image: UIImage(systemName: "person")!, actionType: .dropdown, action: {}))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
}
