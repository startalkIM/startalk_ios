//
//  STMainVController.swift
//  Startalk
//
//  Created by lei on 2023/1/11.
//

import UIKit
import Combine

class STMainVController: UINavigationController {
    let loginManager = STKit.shared.loginManager
    
    let contentVController = STContentVController()
    
    var loginSubscription: AnyCancellable?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(rootViewController: contentVController)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loginSubscription = loginManager.$isLoggedIn.sink{ [self] isLoggedIn in
            loginStateChanged(isLoggedIn)
        }
    }

    func showLoginView(){
        let loginVController = STLoginVController()
        loginVController.modalPresentationStyle = .fullScreen
        present(loginVController, animated: true)
    }
    
    func hideLoginView(){
        dismiss(animated: true)
    }
    
    func loginStateChanged(_ value: Bool){
        DispatchQueue.main.async { [self] in
            if value{
                hideLoginView()
            }else{
                showLoginView()
            }
        }
    }

}

