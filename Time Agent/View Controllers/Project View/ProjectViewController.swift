//
//  ProjectViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 26/11/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectViewController: NSViewController, NSMenuDelegate {

    var project: Project? {
        didSet {
            updateTimerLabel()
            tasksTableView.reloadData()
            
            guard let project = project else {
                projectNameField.stringValue = NSLocalizedString("No project selected", comment: "Title when no project is selected")
                taskNameInput.isEnabled = false
                timerButton.isEnabled = false
                moreButton.isEnabled = false
                
                return
            }
            
            projectNameField.stringValue = project.name ?? "No name"
            taskNameInput.isEnabled = true
            timerButton.isEnabled = true
            moreButton.isEnabled = true
        }
    }
    
    @IBOutlet weak var syncButton: NSButton!
    @IBOutlet weak var moreButton: NSButton!
    @IBOutlet weak var lastSyncLabel: NSTextField!
    @IBOutlet var taskContextMenu: NSMenu!
    @IBOutlet var moreContextMenu: NSMenu!
    
    static var durationFormatter: DateComponentsFormatter = {
        let format = DateComponentsFormatter()
        format.allowedUnits = [.hour, .minute, .second]
        format.unitsStyle = .abbreviated
        
        return format
    }()
    
    static var dateFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateStyle = .short
        format.timeStyle = .medium
        
        return format
    }()
    
    
    @IBOutlet weak var projectNameField: NSTextField!
    @IBOutlet weak var taskNameInput: NSTextField!
    @IBOutlet weak var timerButton: NSButton!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var tasksTableView: NSTableView!
    @IBOutlet weak var totalTimeLabel: NSTextField!
    
    var menuDelegate: MenuViewProjectsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Run didSet function
        if project == nil {
            let projects = Project.fetchRoots()
            if !projects.isEmpty {
                project = projects[0]
            } else {
                project = nil
            }
        }
        
        if let fileSync = AppDelegate.main.fileSync {
            fileSync.onSyncComplete.append {
                self.updateSyncLabel()
            }
        } else {
            lastSyncLabel.stringValue = ""
            syncButton.isEnabled = false
        }
        
        self.updateSyncLabel()
    }
    
    func updateSyncLabel() {
        if let syncDate = AppDelegate.main.fileSync?.lastSync {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            
            print("Sync date: \(syncDate) \(formatter.string(from: syncDate))")
            self.lastSyncLabel.stringValue = "Last synced: \(formatter.string(from: syncDate))"
        }
    }
    
    @IBAction func toggleSidebarAction(_ sender: Any) {
        guard let menuViewController = parent as? MenuViewController else {
            print("Error could not get parent menu controller, to toggle sidebar")
            return
        }
        
        menuViewController.toggleSidebar(sender)
    }
    
    // MARK: More context menu + exporting
    
    @IBAction func moreButtonAction(_ sender: NSButton) {
        let point = NSPoint(x: -8, y: sender.frame.height + 4)
        moreContextMenu.popUp(positioning: nil, at: point, in: sender)
    }
    
    @IBAction func exportHTMLAction(_ sender: Any) {
        
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["html"]
        
        panel.beginSheetModal(for: view.window!) { (result) in
            if result == .OK {
                let path = panel.url!
                
                ExportHTML.exportAsync(project: self.project!, path: path)
            }
        }
    }
    
    @IBAction func exportPDFAction(_ sender: Any) {
        
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["pdf"]
        
        panel.beginSheetModal(for: view.window!) { (result) in
            if result == .OK {
                let path = panel.url!
                
                ExportPDF.exportAsync(project: self.project!, path: path)
            }
        }
    }
    
    @IBAction func openSettingsAction(_ sender: Any) {
        print("Opening settings window")
        let settings = SettingsViewController.makeController()
        presentAsModalWindow(settings)
    }
    
    @IBAction func syncAction(_ sender: Any) {
        AppDelegate.main.fileSync?.load()
    }
    
    // MARK: Timer
    
    var callTimer: Timer?
    var startTime: Date?
    
    @IBAction func toggleTimer(_ sender: NSButton) {
        if startTime != nil {
            // Stop timer
            let start = startTime!
            startTime = nil
            callTimer?.invalidate()
            updateTimerLabel()
            
            taskNameInput.isEditable = true
            
            timerButton.image = NSImage(named: NSImage.Name("Start button"))
            let duration = Date().timeIntervalSince(start)
            
            let name = taskNameInput.stringValue
            taskNameInput.stringValue = ""
            
            taskFinished(name: name, start: start, duration: duration)
            
            AppDelegate.main.setTimer(start: false)
            
            return
        }
        
        if taskNameInput.stringValue.isEmpty {
            print("Task should have a name")
            return
        }
        
        startTime = Date()
        updateTimerLabel()
        callTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
        
        timerButton.image = NSImage(named: NSImage.Name("Stop button"))
        taskNameInput.isEditable = false
        
        AppDelegate.main.setTimer(start: true)
    }
    
    @objc func updateTimerLabel() {
        
        guard let project = project else {
            return
        }
        
        var duration: TimeInterval
        
        if startTime == nil {
            duration = 0
        } else {
            duration = Date().timeIntervalSince(startTime!)
        }
        
        timerLabel.stringValue = ProjectViewController.durationFormatter.string(from: duration) ?? "ERROR"
        
        let taskTime = project.calculateTotalTime()
        
        let formatString = NSLocalizedString("Total time: %@", comment: "Total time used on selected project")
        let time = (ProjectViewController.durationFormatter.string(from: duration + taskTime) ?? "ERROR")
        
        totalTimeLabel.stringValue = String.localizedStringWithFormat(formatString, time)
        
        menuDelegate?.projectUpdated(project)
    }
    
    func taskFinished(name: String, start: Date, duration: TimeInterval) {
        print("Task finished: \(name) - \(duration)")
        
        let task = Task(name: name, duration: duration, start: start)
        task.project = project
        project?.wasUpdated()
        
        Model.save()
        
        tasksTableView.reloadData()
        
        print("Starting sync because task was created")
        AppDelegate.main.fileSync?.save()
    }
    
    var tableViewTasks: [Task] = []
    
    // Mark: right click menu
    
    func menuWillOpen(_ menu: NSMenu) {
        
        let multipleSelected = tasksTableView.selectedRowIndexes.count > 1
        
        // Disable 'edit' when multiple selected
        menu.item(withTag: 0)?.isEnabled = !multipleSelected
        
        let row = tasksTableView.clickedRow
        if tableViewTasks.count <= row && row != -1 {
            print("Invalid row")
            return
        }
        
        let clickedTask = tableViewTasks[row]
        
        if clickedTask.archived {
            menu.item(withTag: 2)?.title = NSLocalizedString("Reopen", comment: "Task menu item to remove from archive")
        } else {
            menu.item(withTag: 2)?.title = NSLocalizedString("Archive", comment: "Task menu item to archive")
        }
        
        
        if tasksTableView.clickedRow == -1 {
            menu.cancelTracking()
        }
    }
    
    @IBAction func taskMenuEditAction(_ sender: NSMenuItem) {
        print("Edit task")
        
        let row = tasksTableView.clickedRow
        
        if tableViewTasks.count <= row && row != -1 {
            print("Invalid row")
            return
        }
        
        let task = tableViewTasks[row]
        
        
        guard let view = tasksTableView.view(atColumn: 0, row: row, makeIfNecessary: false) else {
            print("Could not get view of tableview")
            return
        }
        
        let popover = TaskEditPopoverController.makeController(task: task)
        popover.onFinished = {
            self.tasksTableView.reloadData()
            Model.save()
            
            print("Starting sync because task was edited")
            AppDelegate.main.fileSync?.save()
        }
        
        print("Presenting popover")
        present(popover, asPopoverRelativeTo: view.visibleRect, of: view, preferredEdge: NSRectEdge.minX, behavior: NSPopover.Behavior.transient)
        
    }
    
    
    @IBAction func taskMenuDeleteAction(_ sender: Any) {
        print("Delete task")
        
        var rows = tasksTableView.selectedRowIndexes.makeIterator()
        while let row = rows.next() {
            
            if tableViewTasks.count <= row && row != -1 {
                print("Invalid row")
                return
            }
            
            let task = tableViewTasks[row]
            
            print("Deleting task: \(task.name!)")
            
            Model.delete(managedObject: task)
        }
        
        
        Model.save()
        
        self.tasksTableView.reloadData()
        
        print("Starting sync because task was deleted")
        AppDelegate.main.fileSync?.save()
    }
    
    @IBAction func taskMenuArchiveAction(_ sender: Any) {
        
        let row = tasksTableView.clickedRow
        if tableViewTasks.count <= row && row != -1 {
            print("Invalid row")
            return
        }
        
        let clickedTask = tableViewTasks[row]
        let action = !clickedTask.archived
        
        var rows = tasksTableView.selectedRowIndexes.makeIterator()
        while let row = rows.next() {
            
            if tableViewTasks.count <= row && row != -1 {
                print("Invalid row")
                return
            }
            
            let task = tableViewTasks[row]
            
            print("Archiving task: \(task.name!)")
            
            task.archived = action
        }
        
        self.tasksTableView.reloadData()
        
        print("Starting sync because task was archived")
        AppDelegate.main.fileSync?.save()
    }
}

extension ProjectViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        guard let project = project else {
            return 0
        }
        
        guard let tasks = project.tasks else {
            print("ERROR: ProjectViewController -> viewFor tableColumn: Could not get project.tasks")
            return 0
        }
        
        print("Updating tableview tasks")
        tableViewTasks = tasks.sortedArray(using: [NSSortDescriptor(key: "archived", ascending: true), NSSortDescriptor(key: "start", ascending: false)]) as! [Task]

        
        print("Showing \(tasks.count) tasks")
        return tasks.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn!.identifier
        
        let cell = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
        
        var cellValue: String!
        
        let task = tableViewTasks[row]
        
        guard let start = task.start else {
            print("ERROR: ProjectViewController -> viewFor tableColumn: task.start is nil")
            return nil
        }
        
        switch identifier.rawValue {
        case "date":
            cellValue = ProjectViewController.dateFormatter.string(from: start)
            break
        case "task":
            cellValue = task.name
            break
        case "duration":
            cellValue = ProjectViewController.durationFormatter.string(from: task.duration)
            break
        default:
            cellValue = "Not defined"
        }
        
        if task.archived {
            cell.textField?.textColor = NSColor.disabledControlTextColor
        } else {
            cell.textField?.textColor = NSColor.controlTextColor
        }
        
        cell.textField?.stringValue = cellValue
        
        return cell
    }
}
