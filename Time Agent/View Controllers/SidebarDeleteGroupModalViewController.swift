//
//  SidebarDeleteGroupModalViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 10/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class SidebarDeleteGroupModalViewController: NSViewController {

    var keepCallback: (() -> Void)?
    var deleteCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(sender)
    }
    
    @IBAction func keepChildrenAction(_ sender: Any) {
        self.dismiss(sender)
        keepCallback?()
    }
    
    @IBAction func deleteChildrenAction(_ sender: Any) {
        self.dismiss(sender)
        deleteCallback?()
    }
}
