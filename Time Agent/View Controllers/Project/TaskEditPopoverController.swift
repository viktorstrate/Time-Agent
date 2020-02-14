//
//  TaskEditPopoverController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 14/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class TaskEditPopoverController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var startPicker: NSDatePicker!
    @IBOutlet weak var endPicker: NSDatePicker!
    @IBOutlet weak var durationPicker: NSDatePicker!
    
    var task: Task!
    var onFinished: (() -> Void)?
    
    var referenceDate: Date {
        get {
            return Date(timeIntervalSinceReferenceDate: -60*60)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleField.stringValue = task.name!
        startPicker.dateValue = task.start!
        endPicker.dateValue = task.start!.addingTimeInterval(task.duration)
        
        durationPicker.dateValue = referenceDate.addingTimeInterval(task.duration)
    }
    
    @IBAction func finished(_ sender: Any?) {
        
        if titleField.stringValue == "" {
            self.dismiss(self)
            return
        }
        
        task.name = titleField.stringValue
        task.start = startPicker.dateValue
        task.duration = endPicker.dateValue.timeIntervalSinceReferenceDate - startPicker.dateValue.timeIntervalSinceReferenceDate
        
        task.wasUpdated()
        
        NSLog("Task edited: \(task)")
        Model.save()
        
        onFinished?()
        self.dismiss(self)
    }
    
    @IBAction func startPickerAction(_ sender: Any) {
        var duration = endPicker.dateValue.timeIntervalSinceReferenceDate - startPicker.dateValue.timeIntervalSinceReferenceDate
        
        print("Start picker changed: duration \(duration)")
        
        if duration < 0 {
            endPicker.dateValue = startPicker.dateValue.addingTimeInterval(1)
            duration = 1
        }
        
        durationPicker.dateValue = referenceDate.addingTimeInterval(duration)
    }
    
    @IBAction func endPickerAction(_ sender: Any) {
        var duration = endPicker.dateValue.timeIntervalSinceReferenceDate - startPicker.dateValue.timeIntervalSinceReferenceDate
        
        print("End picker changed: duration \(duration)")
        
        if duration < 0 {
            startPicker.dateValue = endPicker.dateValue.addingTimeInterval(-1)
            duration = 1
        }
        
        durationPicker.dateValue = referenceDate.addingTimeInterval(duration)
    }
    
    @IBAction func durationPickerAction(_ sender: Any) {
        let duration = durationPicker.dateValue.timeIntervalSinceReferenceDate - Date(timeIntervalSinceReferenceDate: -60*60).timeIntervalSinceReferenceDate
        
        print("Duration picker changed: duration \(duration)")
        
        if duration < 0 {
            durationPicker.dateValue = referenceDate.addingTimeInterval(0)
        }
        
        endPicker.dateValue = startPicker.dateValue.addingTimeInterval(duration)
        
    }
    
    static func makeController(task: Task) -> TaskEditPopoverController {
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
        let identifier = "TaskEditController"
        
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? TaskEditPopoverController else {
            fatalError("Could not instantiate TaskEditPopoverController")
        }
        
        viewController.task = task
        
        return viewController
    }
    
}
