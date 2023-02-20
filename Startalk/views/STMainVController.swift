//
//  STMainVController.swift
//  Startalk
//
//  Created by lei on 2023/1/11.
//

import UIKit

class STMainVController: UINavigationController {
    let contentVController = STContentVController()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(rootViewController: contentVController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

