//
//  STMessagesView.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import UIKit

class STMessagesView: KeyboardView {
    
    var tableView: UITableView!
    var inputField: UITextField!
    
    var delegate: STMessagesViewDelegate? {
        didSet{
            delegateDidSet(delegate)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGray6
        addElements()
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addElements(){
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.register(STReceiveMessageTableCell.self, forCellReuseIdentifier: STReceiveMessageTableCell.IDENTIFIER)
        tableView.register(STSendMessageTableCell.self, forCellReuseIdentifier: STSendMessageTableCell.IDENTIFIER)

        tableView.keyboardDismissMode = .onDrag
        tableView.allowsSelection = false
        addSubview(tableView)
        
        
        inputField = UITextField()
        inputField.returnKeyType = .send
        inputField.borderStyle = .roundedRect
        inputField.enablesReturnKeyAutomatically = true
        addSubview(inputField)
    }
    
    func layoutElements(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputField.topAnchor, constant: -20),
        ])
        
        inputField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            inputField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            inputField.bottomAnchor.constraint(equalTo: safeKeyboardLayoutGuide.topAnchor, constant: -20),
            inputField.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    func delegateDidSet(_ delegate: STMessagesViewDelegate?){
        tableView.dataSource = delegate
        tableView.delegate = delegate
        inputField.delegate = delegate
    }
    
    override func onKeyboardShow() {
        tableView.scrollsToBottom(animated: false)
    }
}


protocol STMessagesViewDelegate: UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate{
    
}
