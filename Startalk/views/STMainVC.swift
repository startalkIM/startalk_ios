//
//  ViewController.swift
//  Startalk
//
//  Created by lei on 2023/1/11.
//

import UIKit

class STMainVC: UINavigationController {
    let contentVC = STContentVC()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(rootViewController: contentVC)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

