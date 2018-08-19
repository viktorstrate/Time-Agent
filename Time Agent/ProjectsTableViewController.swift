//
//  ProjectsTableViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 19/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectsTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, ProjectsEditItemCellDelegate {
    
    var projects: [String] = ["First Project", "Another Project", "Hello world"]
    var editingProject = false
    var editTextField: NSTextField?

    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 34
        
    }
    
    @IBAction func addProjectAction(_ sender: NSButton) {
        editingProject = true
        tableView.reloadData()
    }
    
    func endEditing(text: String) {
        editingProject = false
        if !text.isEmpty {
            projects.append(text)
        }
        tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if editingProject {
            return projects.count + 1
        }
        
        return projects.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if editingProject && row == projects.count {
            let editItem = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectEditCell"), owner: nil) as! ProjectsEditItemCellView
            
            editItem.delegate = self

            editTextField = editItem.editTextField
            editTextField?.stringValue = ""
            
            return editItem
        }
        
        let projectItem = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectCell"), owner: nil) as! ProjectsItemCellView
        projectItem.title.stringValue = projects[row]

        return projectItem
        
        
        return nil
    }
    
}
