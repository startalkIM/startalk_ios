//
//  STMineVController.swift
//  Startalk
//
//  Created by busylei on 2023/1/12.
//

import UIKit

class STMineVController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "mine".localized
        
        let label = UILabel()
        label.text = "mine".localized
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
        
        view.backgroundColor = .systemBackground
    }
}
