//
//  STNavigationQrCodeVController.swift
//  Startalk
//
//  Created by lei on 2023/3/6.
//

import UIKit

class STNavigationQrCodeVController: UIViewController {

    var location: STNavigationLocation = .empty
    
    var nameLabel: UILabel!
    var imageView: UIImageView!
    
    override func loadView() {
        let codeView = STNavigationQrCodeView()
        nameLabel = codeView.nameLabel
        imageView = codeView.imageView
        
        view = codeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = location.name
        
        imageView.image = STQrCodeUtil.makeImage(location.location, size: 280)
        
        navigationItem.title = "navigation_qr_code".localized
    }


}
