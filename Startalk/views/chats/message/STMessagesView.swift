//
//  STMessagesView.swift
//  Startalk
//
//  Created by lei on 2023/3/27.
//

import UIKit

class STMessagesView: UIView {
    
    var tableView: UITableView!
    var inputField: UITextField!
    var bottomConstaint: NSLayoutConstraint!
    var bottomSpace: CGFloat = 10
    
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
    
        addKeyboardObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addKeyboardObserver(){
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addElements(){
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.register(STReceiveMessageTableCell.self, forCellReuseIdentifier: STReceiveMessageTableCell.IDENTIFIER)
        tableView.register(STSendMessageTableCell.self, forCellReuseIdentifier: STSendMessageTableCell.IDENTIFIER)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = (STReceiveMessageTableCell.ESTIMATED_HEIGHT + STSendMessageTableCell.ESTIMATED_HEIGHT) / 2
        
        tableView.allowsSelection = false
        addSubview(tableView)
        
        
        inputField = UITextField()
        inputField.returnKeyType = .send
        inputField.clipsToBounds = true
        inputField.backgroundColor = .white
        addSubview(inputField)
    }
    
    func layoutElements(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
        ])
        
        inputField.translatesAutoresizingMaskIntoConstraints = false
        bottomConstaint = inputField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -bottomSpace)
        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            inputField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            inputField.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            inputField.heightAnchor.constraint(equalToConstant: 40),
            bottomConstaint,
        ])
        inputField.layer.cornerRadius = 5
    }
    
    func delegateDidSet(_ delegate: STMessagesViewDelegate?){
        tableView.dataSource = delegate
        tableView.delegate = delegate
        inputField.delegate = delegate
    }
    
    @objc
    func keyboardWillAppear(_ notification: Notification){
        let userInfo = notification.userInfo
        guard let userInfo = userInfo else { return }
        let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let frameValue = frameValue else{ return }
        
        let frame = frameValue.cgRectValue
        let height = frame.size.height
        DispatchQueue.main.async { [self] in
            bottomConstaint.constant = -(bottomSpace + height)
            layoutIfNeeded()
            
            let count = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0)
            if let count = count{
                let indexPath = IndexPath(row: count - 1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

            }
        }
    }
    
    @objc
    func keyboardWillDisappear(_ notification: Notification){
        DispatchQueue.main.async { [self] in
            bottomConstaint.constant = -bottomSpace
            layoutIfNeeded()
        }
    }
}


protocol STMessagesViewDelegate: UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate{
    
}
