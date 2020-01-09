//
//  ProjectsEditItemCellView.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 19/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectEditCellView: NSTableCellView, NSTextFieldDelegate {

    var delegate: ProjectsEditItemCellDelegate?
    var newProjectParent: ProjectGroup?
    var editingObject: NSManagedObject? {
        didSet {
            if let project = editingObject as? Project {
                editTextField.stringValue = project.name ?? ""
            }
            
            if let group = editingObject as? ProjectGroup {
                editTextField.stringValue = group.name ?? ""
            }
        }
    }
    
    @IBOutlet weak var editTextField: NSTextField!
    
    override func awakeFromNib() {
        editTextField.delegate = self
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        delegate?.projectEditItem(endEditing: self, text: editTextField.stringValue)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        editTextField.selectText(self)
    }
    
}

protocol ProjectsEditItemCellDelegate {
    func projectEditItem(endEditing projectItem: ProjectEditCellView, text: String)
}
