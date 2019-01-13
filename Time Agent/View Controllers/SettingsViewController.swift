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
        AppDelegate.main.popover.performClose(self)
        updateUI()
    }
    
    override func viewDidAppear() {
        view.window?.title = NSLocalizedString("Preferences", comment: "Title of preferences window")
        view.window?.makeKey() // Focus window
    }
    
    @IBAction func toggleSync(_ sender: Any) {
        if syncButton.state == .off {
            UserDefaults.standard.set(nil, forKey: "settings.sync-path")
            updateUI()
        }
        
        if syncButton.state == .on {
            let panel = NSSavePanel()
            panel.allowedFileTypes = ["time-agent"]
            
            panel.beginSheetModal(for: self.view.window!) { (result) in
                if result == .OK {
                    let path = panel.url!
                    UserDefaults.standard.set(path, forKey: "settings.sync-path")
                    
                    let fileSync = FileSync(path: path)
                    fileSync.sync()
                    
                } else {
                    UserDefaults.standard.set(nil, forKey: "settings.sync-path")
                }
                
                self.updateUI()
            }
        }
    }
    
    func updateUI() {
        if let path = UserDefaults.standard.url(forKey: "settings.sync-path") {
            syncPathLabel.stringValue = path.absoluteString
            syncButton.state = .on
        } else {
            syncPathLabel.stringValue = ""
            syncButton.state = .off
        }
    }
}
