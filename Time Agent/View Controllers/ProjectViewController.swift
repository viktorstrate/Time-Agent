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
            guard let project = project else {
                projectNameField.stringValue = "No project selected"
                taskNameInput.isEnabled = false
                timerButton.isEnabled = false
                return
            }
            
            projectNameField.stringValue = project.name ?? "No name"
            taskNameInput.isEnabled = true
            timerButton.isEnabled = true
            
            tasksTableView.reloadData()
        }
    }
    
    lazy var durationFormatter: DateComponentsFormatter = {
        let format = DateComponentsFormatter()
        format.allowedUnits = [.hour, .minute, .second]
        format.unitsStyle = .abbreviated
        
        return format
    }()
    
    lazy var dateFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateStyle = .medium
        format.timeStyle = .none
        
        return format
    }()
    
    
    @IBOutlet weak var projectNameField: NSTextField!
    @IBOutlet weak var taskNameInput: NSTextField!
    @IBOutlet weak var timerButton: NSButton!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var tasksTableView: NSTableView!
    
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
            
            return
        }
        
        if taskNameInput.stringValue.isEmpty {
            print("Taks should have a name")
            return
        }
        
        startTime = Date()
        updateTimerLabel()
        callTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
        
        timerButton.image = NSImage(named: NSImage.Name("Stop button"))
        taskNameInput.isEditable = false
    }
    
    @objc func updateTimerLabel() {
        guard let startTime = startTime else {
            timerLabel.stringValue = ""
            return
        }
        
        let duration = Date().timeIntervalSince(startTime)

        
        
        timerLabel.stringValue = durationFormatter.string(from: duration) ?? "ERROR"
    }
    
    func taskFinished(name: String, start: Date, duration: TimeInterval) {
        print("Task finished: \(name) - \(duration)")
        
        let task = Task(context: Model.context)
        task.duration = duration
        task.name = name
        task.start = start
        task.project = project
        
        Model.save()
        
        tasksTableView.reloadData()
    }
}

extension ProjectViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        let tasks = project?.tasks?.count ?? 0
        
        print("Showing \(tasks) tasks")
        return tasks
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = tableColumn!.identifier
        
        let cell = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
        
        var cellValue: String!
        let tasks = project!.tasks!.sortedArray(using: [NSSortDescriptor(key: "date", ascending: false)]) as! [Task]
        let task = tasks[row]
        
        print("Date \(task.start) - \(dateFormatter.string(from: task.start!))")
        
        switch identifier.rawValue {
        case "date":
            cellValue = dateFormatter.string(from: task.start!)
            break
        case "task":
            cellValue = task.name
            break
        case "duration":
            cellValue = durationFormatter.string(from: task.duration)
            break
        default:
            cellValue = "Not defined"
        }
        
        cell.textField?.stringValue = cellValue
        
        return cell
    }
}
