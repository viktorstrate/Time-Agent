//
//  ViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 17/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class MenuViewController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func changeActiveProject() {
        
    }

}

