//
//  SettingsViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 10/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {

    @IBOutlet weak var syncButton: NSButton!
    @IBOutlet weak var syncPathLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    @IBAction func toggleSync(_ sender: Any) {
        if syncButton.state == .off {
            syncPathLabel.stringValue = ""
        }
        
        if syncButton.state == .on {
            let panel = NSSavePanel()
            panel.allowedFileTypes = ["time-agent"]
            
            panel.beginSheetModal(for: self.view.window!) { (result) in
                if result == .OK {
                    let path = panel.url!
                    self.syncPathLabel.stringValue = path.absoluteString
                }
            }
        }
    }
}
