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
    
    var name: String = ""
    var locaiton: String = ""
    
    override func loadView() {
        let view = STNavigationEditorView()
        nameTextField = view.nameTextField
        locationTextField = view.locationTextField
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.text = name
        locationTextField.text = locaiton
    }
    

}
