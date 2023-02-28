//
//  STSwitchController.swift
//  Startalk
//
//  Created by lei on 2023/2/28.
//

import UIKit

class STSwitchController: UIViewController {
    
    var viewController: UIViewController?

    func setViewController(_ viewController: UIViewController){
        if let currentViewController = self.viewController{
            removeViewController(currentViewController)
        }
        addChild(viewController)
        let contentView = viewController.view!
        contentView.frame = view.bounds
        view.addSubview(contentView)
        viewController.didMove(toParent: self)
    }
    
    private func removeViewController(_ viewController: UIViewController){
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}
