//
//  ImagePreviewController.swift
//  Startalk
//
//  Created by lei on 2023/5/17.
//

import UIKit

class ImagePreviewController: UIViewController {
    var image: UIImage!
    
//    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
//    var leadingConstraint: NSLayoutConstraint!
//    var trailingConstraint: NSLayoutConstraint!
//    var topConstraint: NSLayoutConstraint!
//    var bottomContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addElements()
        layoutElements()

        addGestureRecognizer()
    }
    
    func addElements(){
//        scrollView = UIScrollView()
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.minimumZoomScale = 0.125
//        scrollView.maximumZoomScale = 8
//        scrollView.backgroundColor = .black
//        view.addSubview(scrollView)
//        scrollView.delegate = self
        
        view.backgroundColor = .black
        imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
    }
    
    func layoutElements(){
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
//
//        let contentLayout = scrollView.contentLayoutGuide
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
//        leadingConstraint = imageView.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor)
//        trailingConstraint = imageView.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor)
//        topConstraint = imageView.topAnchor.constraint(equalTo: contentLayout.topAnchor)
//        bottomContraint = imageView.bottomAnchor.constraint(equalTo: contentLayout.bottomAnchor)
//
//        NSLayoutConstraint.activate([
//            leadingConstraint, trailingConstraint, topConstraint, bottomContraint
//        ])
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor)
        ])
    }
    
    func addGestureRecognizer(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss_))
        view.addGestureRecognizer(tap)
    }
    
    @objc
    func dismiss_(){
        dismiss(animated: true)
    }
}

extension ImagePreviewController: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?{
        return imageView
    }
}
