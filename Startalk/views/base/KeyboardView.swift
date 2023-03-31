//
//  KeyboardView.swift
//  Startalk
//
//  Created by lei on 2023/3/31.
//

import UIKit

class KeyboardView: UIView {
    
    private(set) var theKeyboardLayoutGuide: UILayoutGuide
    private(set) var safeKeyboardLayoutGuide: UILayoutGuide
    private var theTopConstraint: NSLayoutConstraint!
    private var safeTopConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        theKeyboardLayoutGuide = UILayoutGuide()
        safeKeyboardLayoutGuide = UILayoutGuide()
        super.init(frame: frame)

        addLayoutGuide(theKeyboardLayoutGuide)
        addLayoutGuide(safeKeyboardLayoutGuide)
        
        theTopConstraint = bottomAnchor.constraint(equalTo: theKeyboardLayoutGuide.topAnchor)
        theTopConstraint.isActive = true
        safeTopConstraint = bottomAnchor.constraint(equalTo: safeKeyboardLayoutGuide.topAnchor)
        safeTopConstraint.priority = .defaultHigh
        safeTopConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            theKeyboardLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            theKeyboardLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            theKeyboardLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            safeKeyboardLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            safeKeyboardLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            safeKeyboardLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            safeKeyboardLayoutGuide.topAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor),
            
        ])
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit{
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func keyboardWillShow(_ notification: Notification){
        let infos = takeInfo(notification)
        guard let infos = infos else { return }
        let (options, duration, frame) = infos
        UIView.animate(withDuration: duration, delay: 0, options: options) { [self] in
            theTopConstraint.constant = frame.height
            safeTopConstraint.constant = frame.height
            layoutIfNeeded()
            onKeyboardShow()
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: Notification){
        let infos = takeInfo(notification)
        guard let infos = infos else { return }
        let (options, duration, _) = infos
        UIView.animate(withDuration: duration, delay: 0, options: options) { [self] in
            theTopConstraint.constant = 0
            safeTopConstraint.constant = safeAreaInsets.bottom
            layoutIfNeeded()
            onKeyboardHide()
        }
    }
    
    func takeInfo(_ notification: Notification) -> (UIView.AnimationOptions, Double, CGRect)?{
        let userInfo = notification.userInfo
        guard let userInfo = userInfo else { return nil}
        let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]
        let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]
        guard let animationCurve = animationCurve as? UInt, let duration = duration as? Double, let frame = frame as? CGRect else{
            return nil
        }
        
        let animationOptions = UIView.AnimationOptions(rawValue: animationCurve << 16)
        return (animationOptions, duration, frame)
    }
    
    func onKeyboardShow(){
        
    }
    
    func onKeyboardHide(){
        
    }
}
