//
//  STMessagesVController.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import UIKit
import XMPPClient

class STMessagesVController: UIViewController {
    var messageManager = STKit.shared.messageManager
    var notificationCenter = STKit.shared.notificationCenter

    let chat: STChat
    let messageSource: STMessageDataSource
    var tableView: UITableView!
    
    init(_ chat: STChat){
        self.chat = chat
        messageSource = messageManager.makeMessageDataSource(chatId: chat.id)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = chat.title

        let textField = UITextField()
        textField.borderStyle = .line
        textField.returnKeyType = .send
        textField.delegate = self
        view.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            textField.widthAnchor.constraint(equalToConstant: 300),
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(ReceivedCell.self, forCellReuseIdentifier: "receive")
        tableView.register(SendCell.self, forCellReuseIdentifier: "send")

        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        notificationCenter.observeMessagesAppended(self) { [self] _ in
            reloadData()
        }
    }

   
    func reloadData(){
        messageSource.reload()
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
        }
    }
}

extension STMessagesVController: UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageSource.message(at: indexPath.row)
        if message.direction == .receive{
            let cell = tableView.dequeueReusableCell(withIdentifier: "receive", for: indexPath) as! ReceivedCell
            cell.label.text = message.content.value
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "send", for: indexPath) as! SendCell
            cell.label.text = message.content.value
            return cell

        }
        
    }
}

extension STMessagesVController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text
        guard let text = text else{ return }
        textField.text = nil

        messageManager.sendTextMessage(to: chat.id, content: text)
    }
}

class ReceivedCell: UITableViewCell{
    var label: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label = UILabel()
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        label.textColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SendCell: UITableViewCell{
    var label: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label = UILabel()
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        label.textColor = .systemGreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
