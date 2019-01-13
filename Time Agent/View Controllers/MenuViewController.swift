//
//  ViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 17/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class MenuViewController: NSSplitViewController, MenuViewProjectsDelegate {
    
    var sidebarViewController: SidebarViewController {
        get {
            return splitViewItems[0].viewController as! SidebarViewController
        }
    }
    
    var projectViewController: ProjectViewController {
        get {
            return splitViewItems[1].viewController as! ProjectViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        projectViewController.menuDelegate = self
        sidebarViewController.menuDelegate = self
        
        AppDelegate.main.fileSync?.onSyncComplete.append {
            self.coreDataUpdated()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    static func makeController() -> MenuViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let identifier = "MenuViewController"
        
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? MenuViewController else {
            fatalError("Could not instantiate MenuViewController")
        }
        
        return viewController
    }
    
    func changeActiveProject(_ project: Project?) {
        print("Changed active project...")
        let projectViewController = splitViewItems[1].viewController as! ProjectViewController
        
        projectViewController.project = project
    }
    
    func coreDataUpdated() {
        print("Core data changed")
        sidebarViewController.updateData(keepSelection: false)
    }
    
    func projectUpdated(_ project: Project) {
        sidebarViewController.updateData(keepSelection: true)
    }
}

protocol MenuViewProjectsDelegate {
    func changeActiveProject(_ project: Project?)
    func coreDataUpdated()
    func projectUpdated(_ project: Project)
}

