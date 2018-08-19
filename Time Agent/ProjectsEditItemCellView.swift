//
//  ProjectsEditItemCellView.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 19/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectsEditItemCellView: NSTableCellView, NSTextFieldDelegate {

    var delegate: ProjectsEditItemCellDelegate?
    
    @IBOutlet weak var editTextField: NSTextField!
    
    override func awakeFromNib() {
        editTextField.delegate = self
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        delegate?.endEditing(text: editTextField.stringValue)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        editTextField.selectText(self)
    }
    
}

protocol ProjectsEditItemCellDelegate {
    func endEditing(text: String)
}
