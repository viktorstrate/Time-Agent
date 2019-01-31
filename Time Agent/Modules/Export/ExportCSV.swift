//
//  ExportCSV.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 31/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

struct ExportCSV {
    static func toCSV(project: Project) -> String {
        
        let tasks = project.export()["tasks"] as! [[String: Any?]]
        var result = ""
        
        for (key, _) in tasks[0] {
            result += "\"\(key)\","
        }
        
        result = String(result[..<result.lastIndex(of: ",")!])
        result += "\n"
        
        for task in tasks {
            
            for (key, value) in task {
                
                var print = value
                
                if key == "archived" {
                    print = (value as! Bool) ? "Yes" : "No"
                }
                
                if key == "duration" {
                    
                    let time = value as! Double
                    
                    let h = floor(time / 60 / 60)
                    let m = floor(time / 60).truncatingRemainder(dividingBy: 60)
                    let s = floor(time).truncatingRemainder(dividingBy: 60)
                    
                    let format: (Double) -> String = { num in
                        if num < 10 {
                            return "0\(Int(num))"
                        } else {
                            return "\(Int(num))"
                        }
                    }
                    
                    print = "\(format(h)):\(format(m)):\(format(s))"
                }
                
                result += "\"\(print ?? "")\","
            }
            
            result = String(result[..<result.lastIndex(of: ",")!])
            result += "\n"
        }
        
        return result;
    }
    
    static func exportAsync(project: Project, path: URL) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            let csv = ExportCSV.toCSV(project: project)
            try! csv.write(to: path, atomically: false, encoding: .utf8)
        }
    }
}
