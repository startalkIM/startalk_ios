//
//  STEditableViewController.swift
//  Startalk
//
//  Created by lei on 2023/3/6.
//

import UIKit

class STEditableViewController: UIViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

class STEditableViewController2: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc
    func hideKeyboard(){
        view.endEditing(true)
    }
    
}
