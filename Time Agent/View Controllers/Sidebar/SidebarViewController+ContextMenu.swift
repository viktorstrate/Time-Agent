//
//  SidebarViewController+ContextMenu.swift
//  Time Agent
//
//  Created by Viktor Strate Kløvedal on 09/01/2020.
//  Copyright © 2020 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension SidebarViewController {
    
    // MARK: Delete
    @IBAction func projectMenuDeleteAction(_ sender: Any) {

        if outlineView.clickedRow == -1 {
            return
        }

        if let project = outlineView.item(atRow: outlineView.clickedRow) as? Project {
            print("Deleting project: \(project.name!)")
            Model.delete(managedObject: project)
            updateData()
            menuDelegate.changeActiveProject(nil)
            
            print("Starting sync because a project was deleted")
//            AppDelegate.main.fileSync.sync(editProvoked: true)
            AppDelegate.main?.fileSync?.save()
            return
        }

        if let group = outlineView.item(atRow: outlineView.clickedRow) as? ProjectGroup {
            print("Deleting group: \(group.name!)")

            if (group.projects!.count > 0 || group.subgroups!.count > 0) {
                let sheet = NSStoryboard.main!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("sidebarDeleteGroupModal")) as! SidebarDeleteGroupModalViewController

                sheet.keepCallback = {
                    Model.delete(managedObject: group)
                    self.updateData()
                    
                    print("Starting sync because a group was deleted")
    //                AppDelegate.main.fileSync.sync(editProvoked: true)
                    AppDelegate.main?.fileSync?.save()
                }

                sheet.deleteCallback = {
                    
                    var deleteGroup: ((ProjectGroup) -> Void)!
                    deleteGroup = {group in
                        
                        let projects = group.projects!.allObjects as! [Project]
                        for project in projects {
                            Model.delete(managedObject: project)
                        }
                        
                        if let subgroups = group.subgroups {
                            for sub in subgroups.allObjects as! [ProjectGroup] {
                                
                                if let projects = sub.projects {
                                    for project in projects.allObjects as! [Project] {
                                        print("Deleting project \(project.name!), in group \(sub.name!)")
                                        Model.delete(managedObject: project)
                                    }
                                }
                                
                                deleteGroup(sub)
                            }
                            
                            self.menuDelegate.changeActiveProject(nil)
                            print("Deleting group \(group.name!)")
                            Model.delete(managedObject: group)
                        }
                    }

                    deleteGroup(group)

                    self.updateData()
                    
                    print("Starting sync because a group and its projects was deleted")
    //                AppDelegate.main.fileSync.sync(editProvoked: true)
                    AppDelegate.main?.fileSync?.save()
                }

                presentAsSheet(sheet)
            
            } else { // If group is empty
                Model.delete(managedObject: group)
                self.updateData()
                
                print("Starting sync because an empty group was deleted")
                AppDelegate.main?.fileSync?.save()
            }

            return
        }
    }

    // MARK: New Group
    @IBAction func projectMenuGroupAction(_ sender: Any) {
        let projects = outlineView.selectedRowIndexes.filter({ (row) -> Bool in
            return outlineView.item(atRow: row) is Project
        }).map { (row) -> Project in
            return outlineView.item(atRow: row) as! Project
        }
        
        let groups = outlineView.selectedRowIndexes.filter({ (row) -> Bool in
            return outlineView.item(atRow: row) is ProjectGroup
        }).map { (row) -> ProjectGroup in
            return outlineView.item(atRow: row) as! ProjectGroup
        }

        let group = ProjectGroup()
        group.projects = NSSet(array: projects)
        group.subgroups = NSSet(array: groups)
        
        group.name = NSLocalizedString("New group", comment: "Default name for new groups")
//        group.parent = projects[0].group

        updateData(keepSelection: false)

        renameItem = group

        outlineView.reloadData()
    }

    // MARK: Rename
    @IBAction func projectMenuRenameAction(_ sender: Any) {

        if let item = outlineView.item(atRow: outlineView.clickedRow) as? NSManagedObject {
            renameItem = item
            outlineView.reloadData()
            
            if let project = item as? Project {
                menuDelegate.changeActiveProject(project)
            }
            
            return
        }
    }

    // MARK: New Project
    @IBAction func projectMenuNewProjectAction(_ sender: Any) {
        guard let item = outlineView.item(atRow: outlineView.clickedRow) as? NSManagedObject else {
            return
        }
        
        var parentGroup: ProjectGroup?
        
        if let group = item as? ProjectGroup {
            parentGroup = group
        }
        
        if let project = item as? Project {
            parentGroup = project.group
        }
        
        newProject(parent: parentGroup)
    }
    
    // MARK: Exporting
    @IBAction func projectMenuExportHTMLAction(_ sender: Any) {
        mainViewController.exportHTML()
    }
    
    @IBAction func projectMenuExportPDFAction(_ sender: Any) {
        mainViewController.exportPDF()
    }
    
    @IBAction func projectMenuExportCSVAction(_ sender: Any) {
        mainViewController.exportCSV()
    }
}
