//
//  STMainVController.swift
//  Startalk
//
//  Created by lei on 2023/1/11.
//

import UIKit

class STMainVController: UINavigationController {
    let contentVController = STContentVController()
    var isLoggedin = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(rootViewController: contentVController)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if !isLoggedin{
//            let loginVController = STLoginVController()
//            loginVController.modalPresentationStyle = .fullScreen
//            present(loginVController, animated: false)
//        }
        
        let navigationController = STNavigationVController()
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: false)
    }


}

