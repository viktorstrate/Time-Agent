//
//  ProjectsItemCellView.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 19/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectCellView: NSTableCellView {

    var project: Project! {
        didSet {
            print("Setting project to view \(project.name ?? "undef")")
            title.stringValue = project.name ?? ""
            totalTime.title = ProjectViewController.durationFormatter.string(from: project.calculateTotalTime()) ?? "ERROR"
        }
    }
    
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var totalTime: NSButton!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
