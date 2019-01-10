//
//  ProjeectGroupCellView.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 10/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectGroupCellView: NSTableCellView {

    var group: ProjectGroup! {
        didSet {
            title.stringValue = group.name ?? ""
        }
    }
    
    @IBOutlet weak var title: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
