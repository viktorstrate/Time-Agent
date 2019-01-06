//
//  ViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 17/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class MenuViewController: NSSplitViewController, MenuViewProjectsDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let projectsTableView = splitViewItems[0].viewController as! ProjectsTableViewController
        projectsTableView.projectsDelegate = self
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
}

protocol MenuViewProjectsDelegate {
    func changeActiveProject(_ project: Project?)
}

