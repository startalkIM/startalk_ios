//
//  STMessagesVController.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import UIKit
import XMPPClient

class STMessagesVController: STEditableViewController2, STMessagesViewDelegate {
    var messageManager = STKit.shared.messageManager
    var notificationCenter = STKit.shared.notificationCenter

    let chat: STChat
    let messageSource: STMessageDataSource
    
    var tableView: UITableView!
    var inputBar: STMessageInputBar!
    
    init(_ chat: STChat){
        self.chat = chat
        messageSource = messageManager.makeMessageDataSource(chatId: chat.id)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = STMessagesView()
        view.delegate = self
        tableView = view.tableView
        inputBar = view.inputBar
        tableView.dataSource = self
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = chat.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationCenter.observeMessagesAppended(self) { [self] messages in
            receive(messages)
        }
        notificationCenter.observeMessageStateChanged(self) { [self] idState in
            updateMessageState(idState)
        }
        loadData(animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.unobserveMessagesAppended(self)
        notificationCenter.unobserveMessageStateChanged(self)
    }
    
    func loadData(animated: Bool){
        messageSource.reload()
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
            let indexPath = IndexPath(row: messageSource.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    func receive(_ messages: [STMessage]){
        let contains = messages.contains { message in
            message.xmppId == chat.id
        }
        if contains{
            loadData(animated: true)
        }else{
        }
    }
    
    func updateMessageState(_ idState: STMessageIdState){
        DispatchQueue.main.async { [self] in
            if let indexPaths = tableView.indexPathsForVisibleRows{
                var updateIndexPaths: [IndexPath] = []
                for indexPath in indexPaths {
                    let index = indexPath.row
                    let message = messageSource.message(at: index)
                    if message.id == idState.id{
                        updateIndexPaths.append(indexPath)
                    }
                }
                tableView.reloadRows(at: updateIndexPaths, with: .fade)
            }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: STReceiveMessageTableCell.IDENTIFIER, for: indexPath) as! STReceiveMessageTableCell
            cell.setMessage(message)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: STSendMessageTableCell.IDENTIFIER, for: indexPath) as! STSendMessageTableCell
            cell.setMessage(message)
            return cell

        }
        
    }
}

extension STMessagesVController{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text
        guard var text = text else{ return true}
        textField.text = nil

        text = text.trimmingCharacters(in: .whitespaces)
        if !text.isEmpty{
            messageManager.sendTextMessage(to: chat.id, content: text)
        }
        return true
    }
}
