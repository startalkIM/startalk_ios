//
//  STMineVC.swift
//  Startalk
//
//  Created by busylei on 2023/1/12.
//

import UIKit

class STMineVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()
        label.text = "Me"
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
        
        view.backgroundColor = .systemBackground
    }
}
