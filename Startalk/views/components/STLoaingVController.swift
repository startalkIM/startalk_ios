//
//  STLoaingVController.swift
//  Startalk
//
//  Created by lei on 2023/2/27.
//

import UIKit

class STLoaingVController: UIViewController {
    
    var labelText: String?
    var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
     
        addBackground()
        addIndicator()
    }
    
    func addBackground(){
        let background = UIView()
        background.backgroundColor = .black.withAlphaComponent(0.7)
        background.layer.cornerRadius = 10
        background.layer.masksToBounds = true
        view.addSubview(background)
                
        background.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            background.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            background.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            background.widthAnchor.constraint(equalToConstant: 120),
            background.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        
        if let labelText = labelText{
            let label = UILabel()
            label.text = labelText
            label.font = .systemFont(ofSize: 12)
            label.textColor = .white
            view.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -12)
            ])
        }
    }
    
    func addIndicator(){
        indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        view.addSubview(indicator)

        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indicator.startAnimating()
    }
}
