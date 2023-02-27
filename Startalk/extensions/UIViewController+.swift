//
//  UIViewController+.swift
//  Startalk
//
//  Created by lei on 2023/2/27.
//

import UIKit

extension UIViewController{
    
    func showLoadingView(){
        let loadingVController = STLoaingVController()
        loadingVController.modalPresentationStyle = .overFullScreen
        
        present(loadingVController, animated: true)
    }
    
    func hideLoadingView(){
        dismiss(animated: true)
    }
}
