//
//  TimeDiagramView+Helpers.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 03/06/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension TimeDiagramView {    
    func getTotalDuration(for tasks: [Task]) -> TimeInterval {
        var result = TimeInterval(exactly: 0)!
        
        for task in tasks {
            result += task.duration
        }
        
        return result
    }
    
    func getTotalDuration(for tasks: [Task], from start: Date, to end: Date) -> TimeInterval {
        
        var filteredTasks = tasks
        
        filteredTasks = tasks.filter { (task) -> Bool in
            return task.start! >= start && task.start! <= end
        }
        
        return getTotalDuration(for: filteredTasks)
    }
    
    func getTimeStepInterval(for tasks: [Task]) -> TimeInterval {
        let duration = getTotalDuration(for: tasks)
        
        let hour = 60.0 * 60.0
        let day = hour * 24.0
        let week = day * 7.0
        let month = day * 30.0
        let year = day * 365.0
        
        if duration < day {
            return hour
        }
        
        if duration < week * 2.0 {
            return day
        }
        
        if duration < month * 4.0 {
            return week
        }
        
        if duration < year {
            return month
        }
        
        return year
    }
    
    func getHighestStep(for tasks: [Task]) -> TimeInterval {
        let stepSize = getTimeStepInterval(for: tasks)
        var cursor = start
        
        var longestDuration = 0.0
        
        while cursor < end {
            
            let duration = getTotalDuration(for: tasks, from: cursor, to: cursor.addingTimeInterval(stepSize))
            if duration > longestDuration {
                longestDuration = duration
            }
            
            cursor = cursor.addingTimeInterval(stepSize)
        }
        
        return longestDuration
    }
}
