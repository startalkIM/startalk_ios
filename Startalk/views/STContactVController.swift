//
//  STContactVController.swift
//  Startalk
//
//  Created by busylei on 2023/1/12.
//

import UIKit

class STContactVController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Contact"

        
        let label = UILabel()
        label.text = "Contact"
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
        
        view.backgroundColor = .systemBackground
    }
    
}
