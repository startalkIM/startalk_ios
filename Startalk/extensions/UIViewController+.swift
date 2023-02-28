//
//  UIViewController+.swift
//  Startalk
//
//  Created by lei on 2023/2/27.
//

import UIKit

extension UIViewController{
    
    func showLoadingView(_ labelText: String? = nil){
        view.endEditing(true)
        
        let loadingVController = STLoaingVController()
        loadingVController.modalTransitionStyle = .crossDissolve
        loadingVController.modalPresentationStyle = .overFullScreen
        loadingVController.labelText = labelText
        
        present(loadingVController, animated: true)
    }
    
    func hideLoadingView(completion: (() -> Void)? = nil){
        dismiss(animated: true, completion: completion)
    }
}


extension UIViewController{
    
    func showAlert(title: String? = nil, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localized, style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
