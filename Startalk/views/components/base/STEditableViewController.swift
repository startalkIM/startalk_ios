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
