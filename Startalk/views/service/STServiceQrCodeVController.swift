//
//  STServiceQrCodeVController.swift
//  Startalk
//
//  Created by lei on 2023/3/6.
//

import UIKit

class STServiceQrCodeVController: UIViewController {

    var service: STService = .empty
    
    var nameLabel: UILabel!
    var imageView: UIImageView!
    
    override func loadView() {
        let codeView = STServiceQrCodeView()
        nameLabel = codeView.nameLabel
        imageView = codeView.imageView
        
        view = codeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = service.name
        
        imageView.image = STQrCodeUtil.makeImage(service.location, size: 280)
        
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "service_qr_code".localized
    }


}
