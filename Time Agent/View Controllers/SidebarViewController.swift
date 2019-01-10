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
    
    // Project currently being renamed
    var renameProject: Project? = nil
    var editTextField: NSTextField?
    var projectsDelegate: MenuViewProjectsDelegate?

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
                let project = Project(context: Model.context)
                project.name = text
                project.creationDate = Date()
                updateData()
            }
        } else {
            // Rename project
            let renamedProject = renameProject!
            renameProject = nil
            
            
            if !text.isEmpty {
                renamedProject.name = text
            }
            
            updateData()
            let row = outlineView.row(forItem: renamedProject)
            outlineView.selectRowIndexes(IndexSet(arrayLiteral: row), byExtendingSelection: false)
            projectsDelegate?.changeActiveProject(renamedProject)
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
        if let project = item as? Project {
            
            if project == renameProject {
                print("Found rename project")
                
                let renameItem = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectEditCell"), owner: self) as! ProjectsEditItemCellView
                
                renameItem.delegate = self
                renameItem.editingProject = project
                
                return renameItem
            }
            
            let projectItem = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectCell"), owner: self) as! ProjectsItemCellView
            projectItem.project = project
            
            return projectItem
        }
        
        if let group = item as? ProjectGroup {
            
            let groupItem = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("groupCell"), owner: self) as! ProjectGroupCellView
            groupItem.group = group
            
            return groupItem
        }
        
        if let key = item as? String {
            if key == "NewProject" {
                
                let newProjectItem = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectEditCell"), owner: nil) as! ProjectsEditItemCellView
                
                newProjectItem.delegate = self
                
                return newProjectItem
            }
        }
        
        return nil
    }
    
//    func projectIndex(_ index: Int) -> Int {
//        var projectIndex = index
//        if newProject {
//            projectIndex -= 1
//        }
//        return projectIndex
//    }
    
    var previousSelection: IndexSet?
    
    @objc func outlineViewClicked() {
        // Deselect active project
        if outlineView.clickedRow == -1 {
            projectsDelegate?.changeActiveProject(nil)
            return
        }
        
        if outlineView.selectedRowIndexes.contains(outlineView.clickedRow) {
            guard let project = outlineView.item(atRow: outlineView.clickedRow) as? Project else {
                print("Clicked item is not a project")
                return
            }
            
            projectsDelegate?.changeActiveProject(project)
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
            return
        }
        
        if let group = outlineView.item(atRow: outlineView.clickedRow) as? ProjectGroup {
            print("Deleting group: \(group.name!)")
            
            let sheet = NSStoryboard.main!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("sidebarDeleteGroupModal")) as! SidebarDeleteGroupModalViewController
            
            sheet.keepCallback = {
                Model.delete(managedObject: group)
                self.updateData()
            }
            
            sheet.deleteCallback = {
                let projects = group.projects!.allObjects as! [Project]
                
                for project in projects {
                    Model.delete(managedObject: project)
                }
                
                Model.delete(managedObject: group)
                
                self.updateData()
            }
            
            presentAsSheet(sheet)
            
            return
        }
    }
    
    @IBAction func projectMenuRenameAction(_ sender: Any) {
        
        guard let project = outlineView.item(atRow: outlineView.clickedRow) as? Project else {
            print("Clicked row was not a project")
            return
        }
        
        renameProject = project
        
        outlineView.reloadData()
    }
    
    @IBAction func projectMenuGroupAction(_ sender: Any) {
        let projects = outlineView.selectedRowIndexes.filter({ (row) -> Bool in
            return outlineView.item(atRow: row) is Project
        }).map { (row) -> Project in
            return outlineView.item(atRow: row) as! Project
        }
        
        let group = ProjectGroup(context: Model.context)
        group.projects = NSSet(array: projects)
        group.name = "New group"
        group.creationDate = Date()
        
        updateData()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        var shouldCancel = false
        
        if (outlineView.clickedRow == -1) {
            shouldCancel = true
        }
        
        let multipleSelected = outlineView.selectedRowIndexes.count > 1
        
        // Only enable groups if multiple projects are selected
        menu.item(withTag: 2)!.isEnabled = multipleSelected
        
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

// Drag and drop outline view
extension SidebarViewController {
    
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let pbItem = NSPasteboardItem()
        
        print("Get pasteboard")
        
        guard let managedObj = item as? NSManagedObject else {
            print("Drag drop: Item not a managed object")
            return nil
        }
        
        pbItem.setString(managedObj.objectID.uriRepresentation().absoluteString, forType: NSPasteboard.PasteboardType("public.data"))
        
        print("Drag URL: \(managedObj.objectID.uriRepresentation().absoluteString)")
        
        print("pbItem is \(pbItem)")
        
        return pbItem
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        if item is ProjectGroup {
            return .move
        }
        
        if item is Project {
            return []
        }
        
        // For root
        return .move
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        print("Move Action")
        
        let group = item as? ProjectGroup
        
        print("Move to group \(group?.name ?? "Root")")
        
        info.enumerateDraggingItems(options: [], for: outlineView, classes: [NSString.self, NSPasteboardItem.self, NSURL.self], searchOptions: [:]) { (draggingItem, index, stopPtr) in
            
            let pbItem = draggingItem.item as! NSPasteboardItem
            
            let urlString = pbItem.string(forType: NSPasteboard.PasteboardType("public.data"))!
            let url = URL(string: urlString)!
            
            let objId = Model.context.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: url)!
            
            guard let project = (try? Model.context.existingObject(with: objId)) as? Project else {
                print("Could not get project: \(index)")
                return
            }
            
            project.group = group
        }
        
        
        updateData(keepSelection: false)
        
        return true
    }
    
}
