//
//  STSwitchController.swift
//  Startalk
//
//  Created by lei on 2023/2/28.
//

import UIKit

class STSwitchController: UIViewController {
    
    var viewController: UIViewController?

    func show(_ viewController: UIViewController){
        removeViewController()
     
        if presentedViewController != nil{
            dismiss(animated: false){ [self] in
                addViewController(viewController)
            }
        }else{
            addViewController(viewController)
        }
        
    }
    private func addViewController(_ viewController: UIViewController){
        addChild(viewController)
        
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        
        viewController.didMove(toParent: self)
        
        self.viewController = viewController
    }
    private func removeViewController(){
        if let viewController = self.viewController{
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
        self.viewController = nil
    }
    
    override var prefersStatusBarHidden: Bool {
        return viewController?.prefersStatusBarHidden ?? false
    }
}
