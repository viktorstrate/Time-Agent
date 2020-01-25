//
//  ExportHTML.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 15/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Stencil
import Foundation

struct ExportHTML {
    private static func stringToDate(_ string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from: string)
//        print("Converted string \(string) to date \(String(describing: date))")
        
        return date
    }
    
    static func toHtml(projects: [Project]) -> String {
        guard let path = Bundle.main.path(forResource: "ExportTemplate", ofType:"html") else {
            print("ERROR: Could not get html export template")
            return ""
        }
        
        let template = try! String(contentsOfFile: path)
        
        let environment = Environment(extensions: [stencilFilters()])
        
        var projectsData: [[String: Any]] = []
        for project in projects {
            
            var project: [String: Any] = project.export()
            project["tasks"] = (project["tasks"] as! [[String: Any?]]).filter({ $0["archived"] as! Bool == false })
            
            projectsData.append(project)
        }
        
        var contextData: [String: Any] = [:]
        contextData["projects"] = projectsData
        
        let render = try! environment.renderTemplate(string: template, context: contextData)
        
        return render
    }
    
    static func toHtml(project: Project) -> String {
        return toHtml(projects: [project])
    }
    
    static func exportAsync(projects: [Project], path: URL) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            let html = ExportHTML.toHtml(projects: projects)
            try! html.write(to: path, atomically: false, encoding: .utf8)
        }
    }
}

extension ExportHTML {
    static func stencilFilters() -> Extension {
        let ext = Extension()
        ext.registerFilter("sum") { (value: Any?) -> Any? in
            guard let value = value as? [[String: Any?]] else {
                return "CALL SUM FILTER ON ARRAY"
            }
            
            let sum = value.reduce(0, { (prev: Double, task: [String: Any?]) -> Double in
                return prev + (task["duration"] as! Double)
            })
            
            return sum
        }
        
        ext.registerFilter("duration") { (value: Any?) -> Any? in
            guard let value = value as? Double else {
                return -1
            }
            
            let interval = TimeInterval(exactly: value)!
            
            let format = DateComponentsFormatter()
            format.allowedUnits = [.hour, .minute, .second]
            format.unitsStyle = .abbreviated
            
            return format.string(from: interval)
        }
        
        ext.registerFilter("date") { (value: Any?) -> Any? in
            guard let value = value as? String else {
                return "DATE ERROR"
            }
            
            let date = stringToDate(value)
            
            let format = DateFormatter()
            format.dateStyle = .short
            format.timeStyle = .medium
            
            return format.string(from: date!)
        }
        
        ext.registerFilter("enddate") { (value: Any?) -> Any? in
            guard let task = value as? [String: Any?] else {
                return "PASS ENDDATE A TASK OBJECT"
            }
            
            let startDate = stringToDate(task["start"] as! String)!
            let endDate = startDate.addingTimeInterval(TimeInterval(exactly: task["duration"] as! Double)!)
            
            let format = DateFormatter()
            format.dateStyle = .short
            format.timeStyle = .medium
            
            return format.string(from: endDate)
        }
        
        ext.registerFilter("sortTasks") { (value: Any?) -> Any? in
            guard var tasks = value as? [[String: Any?]] else {
                return "PASS SORT_TASK AN ARRAY OF TASKS"
            }
            
            tasks.sort(by: { (a, b) -> Bool in
                return stringToDate(a["start"] as! String)! > stringToDate(b["start"] as! String)!
            })
            
            return tasks
        }
        
        return ext
    }
}
