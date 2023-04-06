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

        navigationItem.title = "contact".localized

        
        let label = UILabel()
        label.text = "contact".localized
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
        
        view.backgroundColor = .systemBackground
    }
    
}
