//
//  STContactVController.swift
//  Startalk
//
//  Created by busylei on 2023/1/12.
//

import UIKit

class STDiscoverVController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "discover".localized
        
        let label = UILabel()
        label.text = "discover".localized
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
        
        view.backgroundColor = .systemBackground    }
}
