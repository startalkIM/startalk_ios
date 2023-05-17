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
    
    func showDestructiveConfirmation(title: String, message: String, destructive: @escaping () -> Void){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel)
        alertController.addAction(cancelAction)
        
        let destructiveAction = UIAlertAction(title: title, style: .destructive){_ in
            destructive()
        }
        alertController.addAction(destructiveAction)
        present(alertController, animated: true)
    }
    
    func presentInNavigationController(_ viewController: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil){
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = viewController.modalPresentationStyle
        navigationController.modalTransitionStyle = viewController.modalTransitionStyle
        present(navigationController, animated: true, completion: completion)
    }
}

extension UIViewController{
    
    func showImage(_ image: UIImage){
        
        let previewController = ImagePreviewController()
        previewController.modalTransitionStyle = .crossDissolve
        previewController.modalPresentationStyle = .overFullScreen
        previewController.image = image
        
        present(previewController, animated: true)
    }
}
