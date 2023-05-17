//
//  ImageMessageCell.swift
//  Startalk
//
//  Created by lei on 2023/5/15.
//

import UIKit
import XMPPClient

class MessageCellImageContent: UIView {
    
    var imageView: UIImageView!
    var indicatorView: UIActivityIndicatorView!
        
    var widthConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    
    weak var delegate: MessageCellImageContentDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addElements()
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addElements(){
        imageView = UIImageView()
        imageView.clipsToBounds = true
        addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.color = .systemGray
        addSubview(indicatorView)
    }
    
    func layoutElements(){
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        widthConstraint = widthAnchor.constraint(equalToConstant: 128)
        heightConstraint = heightAnchor.constraint(equalToConstant: 128)
        widthConstraint.isActive = true
        heightConstraint.isActive = true
    }
    
    func setContent(_ content: XCImageMessageContent){
        indicatorView.startAnimating()
        let source = content.source
        let loader = STKit.shared.filesManager.loader
        loader.load(url: source, object: self) { data in
            DispatchQueue.main.async { [self] in
                indicatorView.stopAnimating()
                if let data = data{
                    imageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    @objc
    func imageTapped(){
        if let image = imageView.image{
            delegate?.imageTapped(image)
        }
    }
}

@objc
protocol MessageCellImageContentDelegate: AnyObject{
    
    func imageTapped(_ image: UIImage)

}
