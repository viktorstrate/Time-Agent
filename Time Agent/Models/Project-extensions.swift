//
//  Project-extensions.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 06/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension Project {
    func calculateTotalTime() -> TimeInterval {
        let tasks = self.tasks!.sortedArray(using: []) as! [Task]
        let taskTime = tasks.reduce(0) { (prev, task) -> Double in
            return prev + task.duration
        }
        
        return taskTime
    }
}
