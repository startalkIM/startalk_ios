//
//  STMessageInputBar.swift
//  Startalk
//
//  Created by lei on 2023/4/2.
//

import UIKit

class STMessageInputBar: UIView{
    static let UNIT_SIZE: CGFloat = 40
    static let TEXT_MAX_HEIGHT: CGFloat = 108
    
    var state: STMessageInputState = .idle
    
    var voiceButton: UIButton!
    var inputTextView: UITextView!
    var inputVoiceButton: UIButton!
    var stickerButton: UIButton!
    var moreButton: UIButton!
    
    var inputTextTopConstraint: NSLayoutConstraint!
    var inputVoiceTopConstraint: NSLayoutConstraint!
    
    var delegate: STMessageInputBarDelegate?{
        didSet{
            delegateDidSet(delegate)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        tintColor = .label
        addElements()
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addElements(){
        let voiceImage = UIImage(named: "chat/voice")
        let keyboardImage = UIImage(named: "chat/keyboard")
        let stickerIamge = UIImage(named: "chat/sticker")
        let moreImage = UIImage(named: "chat/more")
        
        voiceButton = UIButton(type: .custom)
        voiceButton.setImage(voiceImage, for: .normal)
        voiceButton.setImage(keyboardImage, for: .selected)
        addSubview(voiceButton)
        
        inputTextView = UITextView()
        inputTextView.isEditable = true
        inputTextView.returnKeyType = .send
        inputTextView.enablesReturnKeyAutomatically = true
        inputTextView.clipsToBounds = true
        inputTextView.font = .systemFont(ofSize: 16)
        inputTextView.backgroundColor = .systemBackground
        addSubview(inputTextView)
        
        inputVoiceButton = UIButton(type: .custom)
        inputVoiceButton.setTitle("chat_hold_talk".localized, for: .normal)
        inputVoiceButton.setTitle("chat_release_send".localized, for: .highlighted)
        inputVoiceButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .black)
        inputVoiceButton.setTitleColor(.label, for: .normal)
        inputVoiceButton.backgroundColor = .systemBackground
        inputVoiceButton.isHidden = true
        addSubview(inputVoiceButton)
        
        stickerButton = UIButton(type: .custom)
        stickerButton.setImage(stickerIamge, for: .normal)
        stickerButton.setImage(keyboardImage, for: .selected)
        addSubview(stickerButton)
        
        moreButton = UIButton(type: .custom)
        moreButton.setImage(moreImage, for: .normal)
        addSubview(moreButton)
    }
    
    func layoutElements(){
        let unitSize = Self.UNIT_SIZE
        inputTextTopConstraint = layoutMarginsGuide.topAnchor.constraint(equalTo: inputTextView.topAnchor)
        inputVoiceTopConstraint = layoutMarginsGuide.topAnchor.constraint(equalTo: inputVoiceButton.topAnchor)
        inputTextTopConstraint.isActive = true
        
        
        voiceButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            voiceButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            voiceButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            voiceButton.widthAnchor.constraint(equalToConstant: unitSize),
            voiceButton.heightAnchor.constraint(equalToConstant: unitSize),
        ])
        
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputTextView.leadingAnchor.constraint(equalTo: voiceButton.trailingAnchor),
            inputTextView.trailingAnchor.constraint(equalTo: stickerButton.leadingAnchor),
            inputTextView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            inputTextView.heightAnchor.constraint(equalToConstant: unitSize, priority: .defaultHigh),
//            inputTextView.heightAnchor.constraint(lessThanOrEqualToConstant: Self.TEXT_MAX_HEIGHT),
        ])
        inputTextView.layer.cornerRadius = 5
        
        inputVoiceButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputVoiceButton.leadingAnchor.constraint(equalTo: voiceButton.trailingAnchor),
            inputVoiceButton.trailingAnchor.constraint(equalTo: stickerButton.leadingAnchor),
            inputVoiceButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            inputVoiceButton.heightAnchor.constraint(equalToConstant: unitSize)
        ])
        inputVoiceButton.layer.cornerRadius = 5
        
        stickerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stickerButton.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor),
            stickerButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            stickerButton.widthAnchor.constraint(equalToConstant: unitSize),
            stickerButton.heightAnchor.constraint(equalToConstant: unitSize),
        ])
        
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            moreButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            moreButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            moreButton.widthAnchor.constraint(equalToConstant: unitSize),
            moreButton.heightAnchor.constraint(equalToConstant: unitSize)
        ])
    }
    
    func setState(_ state: STMessageInputState){
        
        voiceButton.isSelected = false
        stickerButton.isSelected = false
        moreButton.isSelected = false
        
        inputTextView.isHidden = false
        inputVoiceButton.isHidden = true
        inputTextTopConstraint.isActive = true
        inputVoiceTopConstraint.isActive = false
        
        if state != .text{
            inputTextView.resignFirstResponder()
        }
        
        switch state{
        case .idle:
            break
        case .voice:
            voiceButton.isSelected = true
            inputTextView.isHidden = true
            inputVoiceButton.isHidden = false
            inputTextTopConstraint.isActive = false
            inputVoiceTopConstraint.isActive = true
        case .text:
            inputTextView.becomeFirstResponder()
        case .sticker:
            stickerButton.isSelected = true
        case .more:
            moreButton.isSelected = true
        }
    }
    
    func delegateDidSet(_ delegate: STMessageInputBarDelegate?){
        inputTextView.delegate = delegate
        if let delegate = delegate{
            voiceButton.addTarget(delegate, action: #selector(STMessageInputBarDelegate.voiceButtonTapped), for: .touchUpInside)
            stickerButton.addTarget(delegate, action: #selector(STMessageInputBarDelegate.stickerButtonTapped), for: .touchUpInside)
            moreButton.addTarget(delegate, action: #selector(STMessageInputBarDelegate.moreButtonTapped), for: .touchUpInside)
            
            inputVoiceButton.addTarget(delegate, action: #selector(STMessageInputBarDelegate.inputVoiceButtonTouchDown), for: .touchDown)
            inputVoiceButton.addTarget(delegate, action: #selector(STMessageInputBarDelegate.inputVoiceButtonTouchUpInside), for: .touchUpInside)
            inputVoiceButton.addTarget(delegate, action: #selector(STMessageInputBarDelegate.inputVoiceButtonTouchUpOutside), for: .touchUpOutside)
        }else{
            voiceButton.removeTarget(nil, action: nil, for: .touchUpInside)
            stickerButton.removeTarget(nil, action: nil, for: .touchUpInside)
            moreButton.removeTarget(nil, action: nil, for: .touchUpInside)
            
            inputVoiceButton.removeTarget(nil, action: nil, for: .allEvents)
        }
    }
}

@objc
protocol STMessageInputBarDelegate: UITextViewDelegate{
    
    func voiceButtonTapped()
    
    func stickerButtonTapped()
    
    func moreButtonTapped()
    
    func inputVoiceButtonTouchDown()
    
    func inputVoiceButtonTouchUpInside()
    
    func inputVoiceButtonTouchUpOutside()
}
