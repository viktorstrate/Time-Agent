//
//  ProjectsTableViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 19/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource, ProjectsEditItemCellDelegate, NSMenuDelegate, ProjectsSidebarDelegate {

    var newProject = false

    // Project or Group currently being renamed
    var renameItem: NSManagedObject? = nil
    var editTextField: NSTextField?
    var menuDelegate: MenuViewProjectsDelegate!

    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet var projectContextMenu: NSMenu!

    override func viewDidLoad() {
        super.viewDidLoad()

        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.menu = projectContextMenu
        outlineView.rowHeight = 24;

        outlineView.action = #selector(outlineViewClicked)
        outlineView.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: "public.data")])

        projectContextMenu.delegate = self
        projectContextMenu.autoenablesItems = false

    }

    @IBAction func addProjectAction(_ sender: NSButton) {
        print("Add new project")
        newProject = true
        outlineView.reloadData()
        outlineView.scrollRowToVisible(outlineView.numberOfRows-1)
    }

    func endEditing(text: String) {
        if (newProject == true) {
            newProject = false
            if !text.isEmpty {
                let project = Project()
                project.name = text
                project.wasUpdated()
            }
            
//            updateData()
            outlineView.reloadData()
            
            
            print("Starting sync because new project was added")
            AppDelegate.main.fileSync.sync(editProvoked: true)
        } else {
            // Rename project or group
            let renamedObject = renameItem!
            renameItem = nil

            if !text.isEmpty {
                if let renamedProject = renamedObject as? Project {
                    renamedProject.name = text
                    renamedProject.wasUpdated()
                }

                if let renamedGroup = renamedObject as? ProjectGroup {
                    renamedGroup.name = text
                    renamedGroup.wasUpdated()
                }
            }

//            updateData(keepSelection: false)
            outlineView.reloadData()
            
            let row = outlineView.row(forItem: renamedObject)
            outlineView.selectRowIndexes(IndexSet(arrayLiteral: row), byExtendingSelection: false)

            if let renamedProject = renamedObject as? Project {
                menuDelegate.changeActiveProject(renamedProject)
            }
            
            print("Starting sync because project was renamed")
            AppDelegate.main.fileSync.sync(editProvoked: true)
        }
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        // Root
        if item == nil {
            let projects = Project.fetchRoots()
            let groups = ProjectGroup.fetchRoots()

            var count = projects.count + groups.count

            if newProject {
                count = count + 1
            }

            return count
        }

        if let group = item as? ProjectGroup {
            let children = group.projects!.count

            return children
        }

        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        // Root
        if item == nil {
            if newProject && index == 0 {
                return "NewProject"
            }

            var i: Int = index

            if newProject {
                i = i - 1
            }

            let projects = Project.fetchRoots()
            let groups = ProjectGroup.fetchRoots()

            var combined: [NSManagedObject] = []
            combined.append(contentsOf: projects)
            combined.append(contentsOf: groups)

            return combined[i]
        }

        if let group = item as? ProjectGroup {
            let projects = group.projects!.allObjects as! [Project]

            return projects[index]
        }

        return "Did not know how to implement item"
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is ProjectGroup {
            return true
        }

        return false
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        if let rowObject = item as? NSManagedObject, renameItem == rowObject {
            print("Found rename project or group")

            let renameView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectEditCell"), owner: self) as! ProjectEditCellView

            renameView.delegate = self
            renameView.editingObject = rowObject

            return renameView
        }

        if let project = item as? Project {
            let projectView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectCell"), owner: self) as! ProjectCellView
            projectView.project = project

            return projectView
        }

        if let group = item as? ProjectGroup {



            let groupItem = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("groupCell"), owner: self) as! ProjectGroupCellView
            groupItem.group = group

            return groupItem
        }

        if let key = item as? String {
            if key == "NewProject" {

                let newProjectItem = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectEditCell"), owner: nil) as! ProjectEditCellView

                newProjectItem.delegate = self

                return newProjectItem
            }
        }

        return nil
    }

    var previousSelection: IndexSet?

    @objc func outlineViewClicked() {
        // Deselect active project
        if outlineView.clickedRow == -1 {
            menuDelegate.changeActiveProject(nil)
            return
        }

        if outlineView.selectedRowIndexes.contains(outlineView.clickedRow) {
            if let project = outlineView.item(atRow: outlineView.clickedRow) as? Project {
                menuDelegate.changeActiveProject(project)
            }
        }
    }

    // MARK: Core Data related functions

    func updateData(keepSelection: Bool = true) {
        do {
            try Model.context.save()
            let selected = outlineView.selectedRowIndexes
            outlineView.reloadData()
            if keepSelection {
                outlineView.selectRowIndexes(selected, byExtendingSelection: false)
            }

        } catch {
            print("Error saving data")
        }
    }

    // MARK: Right click menu

    @IBAction func projectMenuDeleteAction(_ sender: Any) {

        if outlineView.clickedRow == -1 {
            return
        }

        if let project = outlineView.item(atRow: outlineView.clickedRow) as? Project {
            print("Deleting project: \(project.name!)")
            Model.delete(managedObject: project)
            updateData()
            
            print("Starting sync because a project was deleted")
            AppDelegate.main.fileSync.sync(editProvoked: true)
            return
        }

        if let group = outlineView.item(atRow: outlineView.clickedRow) as? ProjectGroup {
            print("Deleting group: \(group.name!)")

            let sheet = NSStoryboard.main!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("sidebarDeleteGroupModal")) as! SidebarDeleteGroupModalViewController

            sheet.keepCallback = {
                Model.delete(managedObject: group)
                self.updateData()
                
                print("Starting sync because a group without projects was deleted")
                AppDelegate.main.fileSync.sync(editProvoked: true)
            }

            sheet.deleteCallback = {
                let projects = group.projects!.allObjects as! [Project]

                for project in projects {
                    Model.delete(managedObject: project)
                }

                Model.delete(managedObject: group)

                self.updateData()
                
                print("Starting sync because a group with projects was deleted")
                AppDelegate.main.fileSync.sync(editProvoked: true)
            }

            presentAsSheet(sheet)

            return
        }
    }

    @IBAction func projectMenuRenameAction(_ sender: Any) {

        if let item = outlineView.item(atRow: outlineView.clickedRow) as? NSManagedObject {
            renameItem = item
            outlineView.reloadData()
            return
        }
    }

    @IBAction func projectMenuGroupAction(_ sender: Any) {
        let projects = outlineView.selectedRowIndexes.filter({ (row) -> Bool in
            return outlineView.item(atRow: row) is Project
        }).map { (row) -> Project in
            return outlineView.item(atRow: row) as! Project
        }

        let group = ProjectGroup()
        group.projects = NSSet(array: projects)
        group.name = NSLocalizedString("New group", comment: "Default name for new groups")

        updateData(keepSelection: false)

        renameItem = group

        outlineView.reloadData()
    }

    func menuWillOpen(_ menu: NSMenu) {
        var shouldCancel = false

        if (outlineView.clickedRow == -1) {
            shouldCancel = true
        }

        let multipleSelected = outlineView.selectedRowIndexes.count > 1

        // Don't allow renaming of multiple projects
        menu.item(withTag: 0)!.isEnabled = !multipleSelected

        if (shouldCancel) {
            menu.cancelTracking()
        }
    }

    func projectsUpdated() {
        print("Projects updated...")
        updateData()
    }
}

protocol ProjectsSidebarDelegate {
    func projectsUpdated()
}
