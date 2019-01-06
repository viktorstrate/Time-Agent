//
//  ProjectViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 26/11/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectViewController: NSViewController {

    var project: ProjectModel? {
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
        }
    }
    
    @IBOutlet weak var projectNameField: NSTextField!
    @IBOutlet weak var taskNameInput: NSTextField!
    @IBOutlet weak var timerButton: NSButton!
    @IBOutlet weak var timerLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // Run didSet function
        if project == nil {
            project = nil
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
            
            taskNameInput.isEditable = true
            
            timerButton.image = NSImage(named: NSImage.Name("Start button"))
            let duration = Date().timeIntervalSince(start)
            
            let name = taskNameInput.stringValue
            taskNameInput.stringValue = ""
            
            taskFinished(name: name, duration: duration)
            
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

        let format = DateComponentsFormatter()
        format.allowedUnits = [.hour, .minute, .second]
        format.unitsStyle = .abbreviated
        
        timerLabel.stringValue = format.string(from: duration) ?? "ERROR"
    }
    
    func taskFinished(name: String, duration: TimeInterval) {
        
        print("Task finished: \(name) - \(duration)")
    }
}
