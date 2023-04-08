//
//  STServicesView.swift
//  Startalk
//
//  Created by lei on 2023/2/24.
//

import UIKit

class STServicesView: UIView {
    var tableView: UITableView!
    var button: UIButton!
    
    var delegate: STServicesViewDelegate?{
        didSet{
            delegateDidSet(delegate)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubViews()
       
        layoutTableView()
        layoutButton()
    }
    
    func addSubViews(){
        tableView = UITableView()
        tableView.register(STServieTableCell.self, forCellReuseIdentifier: STServieTableCell.IDENTIFIER)
        addSubview(tableView)
        
        button = makeButton()
        addSubview(button)
    }
    
    func layoutTableView(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let safeLayout = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeLayout.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeLayout.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeLayout.topAnchor),
        ])
        
        tableView.rowHeight = STServieTableCell.CELL_HEIGHT
        tableView.separatorStyle = .none
    }
    
    func layoutButton(){
        let safeLayout = safeAreaLayoutGuide
        let buttonLayout = UILayoutGuide()
        addLayoutGuide(buttonLayout)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: buttonLayout.topAnchor),
            
            buttonLayout.leadingAnchor.constraint(equalTo: safeLayout.leadingAnchor),
            buttonLayout.trailingAnchor.constraint(equalTo: safeLayout.trailingAnchor),
            buttonLayout.bottomAnchor.constraint(equalTo: safeLayout.bottomAnchor),
            buttonLayout.heightAnchor.constraint(equalToConstant: 80),
            
            button.centerXAnchor.constraint(equalTo: buttonLayout.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: buttonLayout.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 280),
            button.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func makeButton() -> UIButton{
        let button = UIButton()
        button.setTitle("ok".localized, for: .normal)
        button.setTitleColor(.make(0x00CABE), for: .normal)
        button.setTitleColor(.systemGray3, for: .highlighted)
        
        button.layer.borderColor = UIColor.make(0x00CABE).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        return button
    }
    
    func delegateDidSet(_ delegate: STServicesViewDelegate?){
        tableView.dataSource = delegate
        tableView.delegate = delegate
        
        if let delegate = delegate{
            button.addTarget(delegate, action: #selector(delegate.confirmButtonTapped), for: .touchUpInside)
        }else{
            button.removeTarget(nil, action: nil, for: .touchUpInside)
        }
    }
}


@objc
protocol STServicesViewDelegate: UITableViewDataSource, UITableViewDelegate{
    
    func confirmButtonTapped()
    
}
