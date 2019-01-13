//
//  ProjectViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 26/11/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectViewController: NSViewController {

    var project: Project? {
        didSet {
            updateTimerLabel()
            tasksTableView.reloadData()
            
            guard let project = project else {
                projectNameField.stringValue = "No project selected"
                taskNameInput.isEnabled = false
                timerButton.isEnabled = false
                return
            }
            
            projectNameField.stringValue = project.name ?? "No name"
            taskNameInput.isEnabled = true
            timerButton.isEnabled = true
        }
    }
    
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
    
    var projectsSidebarDelegate: ProjectsSidebarDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Run didSet function
        if project == nil {
            let projects = Model.fetchAll(request: Project.fetchRequest())
            if !projects.isEmpty {
                project = projects[0]
            } else {
                project = nil
            }
        }
    }
    
    @IBAction func toggleSidebarAction(_ sender: Any) {
        guard let menuViewController = parent as? MenuViewController else {
            print("Error could not get parent menu controller, to toggle sidebar")
            return
        }
        
        menuViewController.toggleSidebar(sender)
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
        
        totalTimeLabel.stringValue = "Total time: " + (ProjectViewController.durationFormatter.string(from: duration + taskTime) ?? "ERROR")
        
        projectsSidebarDelegate?.projectsUpdated()
    }
    
    func taskFinished(name: String, start: Date, duration: TimeInterval) {
        print("Task finished: \(name) - \(duration)")
        
        let task = Task(name: name, duration: duration, start: start)
        task.project = project
        project?.wasUpdated()
        
        Model.save()
        
        tasksTableView.reloadData()
    }
    
    var tableViewTasks: [Task] = []
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
        tableViewTasks = tasks.sortedArray(using: [NSSortDescriptor(key: "start", ascending: false)]) as! [Task]

        
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
        
        cell.textField?.stringValue = cellValue
        
        return cell
    }
}
