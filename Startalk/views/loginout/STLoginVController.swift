//
//  STLoginVController.swift
//  Startalk
//
//  Created by lei on 2023/2/20.
//

import UIKit

class STLoginVController: UIViewController, STLoginViewDelegate{
    
    override func loadView() {
        let loginView = STLoginView()
        loginView.delegate = self
        
        view = loginView
    }
    
    func scanButtonClicked() {
        
    }
}
