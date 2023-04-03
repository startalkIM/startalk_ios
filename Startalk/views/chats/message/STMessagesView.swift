//
//  STMessagesView.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import UIKit

class STMessagesView: KeyboardView {
    
    var inputState: STMessageInputState = .idle

    var tableView: UITableView!
    var inputBar: STMessageInputBar!
    
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
        
        
        inputBar = STMessageInputBar()
        addSubview(inputBar)
    }
    
    func layoutElements(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor, constant: -20),
        ])
        
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            inputBar.bottomAnchor.constraint(equalTo: safeKeyboardLayoutGuide.topAnchor),
        ])
    }
    
    func delegateDidSet(_ delegate: STMessagesViewDelegate?){
        tableView.delegate = delegate
        inputBar.delegate = delegate
    }
    
    override func onKeyboardShow() {
        tableView.scrollsToBottom(animated: false)
    }
}

extension STMessagesView{
    func setState(_ state: STMessageInputState){
        self.inputState = state
        inputBar.setState(state)
    }
}


protocol STMessagesViewDelegate: STMessageInputBarDelegate, UITableViewDelegate{
    
}
