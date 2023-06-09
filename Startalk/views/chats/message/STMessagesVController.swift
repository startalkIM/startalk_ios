//
//  STMessagesVController.swift
//  Startalk
//
//  Created by lei on 2023/3/20.
//

import UIKit
import XMPPClient

class STMessagesVController: STEditableViewController2{
    static let RETURN_KEY = "\n"
    
    let logger = STLogger(STMessagesVController.self)
    
    let messageManager = STKit.shared.messageManager
    let notificationCenter = STKit.shared.notificationCenter
    let userManager = STKit.shared.userManager
    let fileUploaderClient = STKit.shared.fileUploadClient
    let fileStorage = STKit.shared.filesManager.storage

    let chat: STChat
    let messageSource: STMessageDataSource
    
    var tableView: UITableView!
    var inputBar: STMessageInputBar!
    
    var messagesView: STMessagesView{
        view as! STMessagesView
    }
    
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
        tableView.scrollsToBottom(animated: false) // fix navigation bar hiding problem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationCenter.observeMessagesAppended(self) { [self] messages in
            receive(messages)
        }
        notificationCenter.observeMessageStateChanged(self) { [self] idState in
            updateMessageState(idState)
        }
        notificationCenter.observeMessageResend(self) { [self] id in
            messageResent(id: id)
        }
        messageSource.reload()
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
            tableView.scrollsToBottom(animated: false)
        }
        
        messageManager.setMessagesRead(chat)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.unobserveMessagesAppended(self)
        notificationCenter.unobserveMessageStateChanged(self)
        notificationCenter.unobserveMessageResend(self)
    }
    
    func receive(_ messages: [STMessage]){
        let messages = messages.filter { message in
            message.chatId == chat.id
        }
        if messages.count > 0{
            let curentCount = messageSource.count
            messageSource.reload()
            let count = messageSource.count
            if count > curentCount{
                let indexPaths = (curentCount..<count).map{ IndexPath(row: $0, section: 0)}
                DispatchQueue.main.async { [self] in
                    tableView.insertRows(at: indexPaths, with: .none)
                    tableView.scrollsToBottom(animated: true)
                }
            }
        }else{
        }
    }
    
    func updateMessageState(_ idState: STMessageIdState){
        if let index = messageSource.index(of: idState.id){
            messageSource.reload(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            DispatchQueue.main.async { [self] in
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func messageResent(id: String){
        messageSource.reload()
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
        }
    }
    
    override func endEditing() {
        let state = messagesView.inputState
        if state != .idle && state != .voice{
            messagesView.changeState(to: .idle)
        }
    }
}

extension STMessagesVController: UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageSource.message(at: indexPath.row)
        let user = userManager.fetchUser(jid: message.from)
        let cell: BaseMessageCell
        
        if message.content is XCImageMessageContent{
            let identifier = ImageMessageCell.makeIdentifier(message: message)
            let reusingCell = tableView.dequeueReusableCell(withIdentifier: identifier)
            if let reusingCell = reusingCell as? ImageMessageCell{
                cell = reusingCell
            }else{
                cell = ImageMessageCell(style: .default, reuseIdentifier: identifier)
            }
        }else{
            let identifier = TextMessageCell.makeIdentifier(message: message)
            let resuingCell = tableView.dequeueReusableCell(withIdentifier: identifier)
            if let resuingCell = resuingCell as? TextMessageCell{
                cell = resuingCell
            }else{
                cell = TextMessageCell(style: .default, reuseIdentifier: identifier)
            }
        }
        cell.delegate = self
        cell.setMessage(message, user: user)
        return cell
    }
}

extension STMessagesVController: STMessagesViewDelegate{
    
    func imageTapped(_ image: UIImage) {
        showImage(image)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == Self.RETURN_KEY{
            let inputText = textView.text
            if let inputText = StringUtil.validContent(inputText){
                messageManager.sendTextMessage(to: chat, text: inputText)
            }
            textView.text = ""
            return false
        }else{
            return true
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        messagesView.changeState(to: .text(true))
        return true
    }
    
    func voiceButtonTapped() {
        let state: STMessageInputState
        if messagesView.inputState == .voice{
            state = .text(false)
        }else{
            state = .voice
        }
        messagesView.changeState(to: state)
    }
    
    func stickerButtonTapped() {
        let state: STMessageInputState
        if messagesView.inputState == .sticker{
            state = .text(false)
        }else{
            state = .sticker
        }
        messagesView.changeState(to: state)
    }
    
    func moreButtonTapped() {
        let state: STMessageInputState
        if messagesView.inputState  == .more{
            state = .text(false)
        }else{
            state = .more
        }
        messagesView.changeState(to: state)
    }
    
    func inputVoiceButtonTouchDown() {
        
    }
    
    func inputVoiceButtonTouchUpInside() {
        
    }
    
    func inputVoiceButtonTouchUpOutside() {
        
    }
    
   
}

extension STMessagesVController: InputFunctionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func sendImage() {
        showImagePicker(delegate: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[.originalImage] as? UIImage{
            messageManager.sendImageMessage(to: chat, image: image)
        }
        dismiss(animated: true)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true)
    }
    
}

extension STMessagesVController: UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endEditing()
    }
}


extension STMessagesVController: BaseMessageCellDelegate{
    func resend(id: String) {
        messageManager.resend(id: id)
    }
}
