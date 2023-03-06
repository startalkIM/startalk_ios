//
//  STNavigationEditorVController.swift
//  Startalk
//
//  Created by lei on 2023/2/25.
//

import UIKit

class STNavigationEditorVController: UIViewController {
    
    var editorView: STNavigationEditorView{
        view as! STNavigationEditorView
    }
    var nameTextField: UITextField!
    var locationTextField: UITextField!
    
    var type: EditorType = .add
    var location: STNavigationLocation = .empty
    
    override func loadView() {
        let view = STNavigationEditorView()
        nameTextField = view.nameTextField
        locationTextField = view.locationTextField
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .black
        if type == .add{
            navigationItem.title = "navigation_editor_add".localized
        }else{
            navigationItem.title = "navigation_editor_edit".localized
        }
        
        if self == navigationController?.viewControllers.first {
            let cancelBarItem = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: #selector(cancelItemTapped))
            navigationItem.leftBarButtonItem = cancelBarItem
        }
        
        nameTextField.text = location.name
        locationTextField.text = location.location
    }
    
    @objc
    func cancelItemTapped(){
        dismiss(animated: true)
    }
    
    
    enum EditorType{
        case add
        case edit
        
    }
}
