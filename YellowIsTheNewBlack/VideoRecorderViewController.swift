//
//  VideoRecorderViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import UIKit
import Then
import SnapKit

class VideoRecorderViewController: UIViewController {
    // Dependencies
    var viewModel: VideoRecoderViewModel! = nil
    
    // Internal vars and const
    var errorMessage = "알 수 없는 오류"
    
    // View components
    lazy var alert = UIAlertController(title: "오류", message: self.errorMessage, preferredStyle: UIAlertController.Style.alert).then {
        $0.addAction(UIAlertAction(title: "Ok",
                                   style: UIAlertAction.Style.default,
                                   handler: nil))
    }
    
    lazy var previewLayer = viewModel.getPreviewLayer.then {
        $0.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        $0.position = CGPoint(x: self.view.bounds.midX,
                              y: self.view.bounds.midY)
        $0.videoGravity = .resizeAspectFill
    }
    
    lazy var recordButton = UIButton().then {
        $0.backgroundColor = .white
        $0.sizeToFit()
    }

    // Life cycle related methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.addSublayer(previewLayer)
        self.setLayout()
        
        do {
            try viewModel.setupSession()
        }
        catch VideoRecorderError.notConfigured {
            fatalError("비디오 세션이 제대로 초기화되지 않았음")
        }
        catch let error {
            self.errorMessage = error.localizedDescription
            self.present(self.alert, animated: true, completion: nil)
        }
        
        viewModel.startRunningCamera()
    }
    
    private func setLayout() {
        self.view.addSubview(recordButton)
        self.recordButton.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.center.equalToSuperview()
        }
    }
    
    // Initializers
    init(viewModel: VideoRecoderViewModel = VideoRecoderViewModel()) {
        super.init(nibName: nil, bundle: nil)
        
        // Update dependencies
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
