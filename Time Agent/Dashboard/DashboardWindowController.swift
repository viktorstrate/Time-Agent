//
//  DashboardWindowController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 03/06/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class DashboardWindowController: NSWindowController {

    static var mainDashboardWindow: DashboardWindowController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    static func show(sender: Any?) {
        if mainDashboardWindow == nil {
            let storyboard = NSStoryboard(name: NSStoryboard.Name.init(NSString("Dashboard")), bundle: nil)
            mainDashboardWindow = storyboard.instantiateInitialController() as? DashboardWindowController
        }
        
        mainDashboardWindow!.showWindow(sender)
        AppDelegate.main?.popover.performClose(sender)
    }

}
