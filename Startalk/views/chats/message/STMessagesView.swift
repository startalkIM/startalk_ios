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
    var stickersView: STMessageStickersView!
    var functionsView: STMessageInputFunctionsView!
    
    var stickersHideTopConstraint: NSLayoutConstraint!
    var stickersShowTopConstraint: NSLayoutConstraint!
    
    var functionsHideTopConstraint: NSLayoutConstraint!
    var functionsShowTopConstraint: NSLayoutConstraint!
    
    weak var delegate: STMessagesViewDelegate? {
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

        tableView.allowsSelection = false
        addSubview(tableView)
        
        
        inputBar = STMessageInputBar()
        addSubview(inputBar)
        
        stickersView = STMessageStickersView()
        addSubview(stickersView)
        
        functionsView = STMessageInputFunctionsView()
        addSubview(functionsView)
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
        
        stickersView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stickersView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stickersView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            stickersView.topAnchor.constraint(greaterThanOrEqualTo: inputBar.bottomAnchor),
        ])
        stickersHideTopConstraint = stickersView.topAnchor.constraint(equalTo: bottomAnchor)
        stickersShowTopConstraint = stickersView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        stickersHideTopConstraint.isActive = true
        
        functionsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            functionsView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            functionsView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            functionsView.topAnchor.constraint(greaterThanOrEqualTo: inputBar.bottomAnchor),
        ])
        functionsHideTopConstraint = functionsView.topAnchor.constraint(equalTo: bottomAnchor)
        functionsShowTopConstraint = functionsView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        functionsHideTopConstraint.isActive = true
    }
    
    func setStickersViewVisible(_ visible: Bool){
        if visible{
            stickersHideTopConstraint.isActive = false
            stickersShowTopConstraint.isActive = true
        }else{
            stickersShowTopConstraint.isActive = false
            stickersHideTopConstraint.isActive = true
        }
    }
    
    func setFunctionsViewVisible(_ visible: Bool){
        if visible{
            functionsHideTopConstraint.isActive = false
            functionsShowTopConstraint.isActive = true
        }else{
            functionsShowTopConstraint.isActive = false
            functionsHideTopConstraint.isActive = true
        }
        
    }
    
    func delegateDidSet(_ delegate: STMessagesViewDelegate?){
        tableView.delegate = delegate
        inputBar.delegate = delegate
    }
}

extension STMessagesView{
    func changeState(to state: STMessageInputState){
        switch state{
        case .idle, .voice:
            if inputState == .sticker || inputState == .more {
                setStickersViewVisible(false)
                setFunctionsViewVisible(false)
                animate {
                    self.layoutIfNeeded()
                }
            }
        case .text(_):
            addAnimation{ [self] in
                setStickersViewVisible(false)
                setFunctionsViewVisible(false)
            } after: { [self] in
                tableView.scrollsToBottom(animated: false)
            }
        case .sticker:
            setStickersViewVisible(true)
            if inputState == .idle || inputState == .voice{
                animate { [self] in
                    layoutIfNeeded()
                    tableView.scrollsToBottom(animated: false)
                }
            }else if inputState == .more {
                functionsView.isHidden = true
                setFunctionsViewVisible(false)
                animate { [self] in
                    layoutIfNeeded()
                    tableView.scrollsToBottom(animated: false)
                } completion: { _ in
                    self.functionsView.isHidden = false
                }
            }
        case .more:
            setFunctionsViewVisible(true)
            if inputState == .idle || inputState == .voice{
                animate { [self] in
                    layoutIfNeeded()
                    tableView.scrollsToBottom(animated: false)
                }
            }else if inputState == .sticker {
                stickersView.isHidden = true
                setStickersViewVisible(false)
                animate { [self] in
                    layoutIfNeeded()
                    tableView.scrollsToBottom(animated: false)
                } completion: { _ in
                    self.stickersView.isHidden = false
                }
            }
            
        }
        inputBar.setState(state)
        inputState = state
    }
}


protocol STMessagesViewDelegate: STMessageInputBarDelegate, UITableViewDelegate{
    
}
