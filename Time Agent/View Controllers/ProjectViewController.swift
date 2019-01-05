//
//  ProjectViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 26/11/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func toggleSidebarAction(_ sender: Any) {
        guard let menuViewController = parent as? MenuViewController else {
            print("Error could not get parent menu controller, to toggle sidebar")
            return
        }
        
        menuViewController.toggleSidebar(sender)
    }
}
