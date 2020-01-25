//
//  ViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 17/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class MainViewController: NSSplitViewController, MainViewProjectsDelegate {
    
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
    
    var dialogueActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        projectViewController.mainDelegate = self
        projectViewController.mainViewController = self
        
        sidebarViewController.menuDelegate = self
        sidebarViewController.mainViewController = self
        
        AppDelegate.main?.fileSync?.onSyncComplete.append {
            self.coreDataUpdated()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    static func makeController() -> MainViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let identifier = "MenuViewController"
        
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? MainViewController else {
            fatalError("Could not instantiate MenuViewController")
        }
        
        return viewController
    }
    
    func changeActiveProject(_ project: Project?) {
        print("Changed active project...")
        projectViewController.project = project
    }
    
    func coreDataUpdated() {
        print("Core data changed")
        sidebarViewController.updateData(keepSelection: false)
        projectViewController.updateTasksTableView()
    }
    
    func projectUpdated(_ project: Project) {
        sidebarViewController.updateData(keepSelection: true)
    }
}

protocol MainViewProjectsDelegate {
    func changeActiveProject(_ project: Project?)
    func coreDataUpdated()
    func projectUpdated(_ project: Project)
}

