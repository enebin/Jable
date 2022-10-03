//
//  SettingToolBarViewController.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/03.
//

import UIKit

import SnapKit
import Then
import RxCocoa
import RxSwift

class SettingToolBarViewController: UIViewController {
    private let bag = DisposeBag()
    
    lazy var settingButton = SettingButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        bindButtons()
    }
    
    func setLayout() {
        view.addSubview(settingButton)
        settingButton.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.center.equalToSuperview()
        }
    }
    
    func bindButtons() {
        settingButton.rx.tap
            .bind { _ in
                print("Tapped")
            }
            .disposed(by: bag)
    }
}
