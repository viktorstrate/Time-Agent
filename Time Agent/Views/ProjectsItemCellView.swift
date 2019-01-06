//
//  ProjectsItemCellView.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 19/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectsItemCellView: NSTableCellView {

    var project: Project! {
        didSet {
            title.stringValue = project.name ?? ""
        }
    }
    
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var totalTime: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
