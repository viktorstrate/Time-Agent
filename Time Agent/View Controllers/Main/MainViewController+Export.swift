//
//  MainViewController+Export.swift
//  Time Agent
//
//  Created by Viktor Strate Kløvedal on 25/01/2020.
//  Copyright © 2020 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension MainViewController {
    
    private func projectsToExport() -> [Project] {
        var projects = sidebarViewController.selectedProjects()
        if projects.isEmpty {
            if let activeProject = projectViewController.project {
                projects.append(activeProject)
            }
        }
        
        return projects
    }
    
    private func defaultExportName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: Date())
        
        var name = "Report"
        
        let projects = projectsToExport()
        if projects.count == 1 {
            if let projectName: String = projects.first?.name {
                name = projectName
            }
        }
        
        return "\(name) \(dateStr)"
    }
    
    func exportHTML() {
        let projects = projectsToExport()
        if projects.isEmpty {
            print("No projects selected to export")
            return
        }
        
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["html"]
        panel.nameFieldStringValue = defaultExportName()
        
        self.dialogueActive = true
        panel.beginSheetModal(for: view.window!) { (result) in
            self.dialogueActive = false
            
            if result == .OK {
                let path = panel.url!
                
                ExportHTML.exportAsync(projects: projects, path: path)
            }
        }
    }
    
    func exportPDF() {
        let projects = projectsToExport()
        if projects.isEmpty {
            print("No projects selected to export")
            return
        }
        
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["pdf"]
        panel.nameFieldStringValue = defaultExportName()
        
        self.dialogueActive = true
        panel.beginSheetModal(for: view.window!) { (result) in
            self.dialogueActive = false
            if result == .OK {
                let path = panel.url!
                
                ExportPDF.exportAsync(projects: projects, path: path)
            }
        }
    }
    
    func exportCSV() {
        guard let project: Project = sidebarViewController.outlineView.item(atRow: sidebarViewController.outlineView.selectedRow) as? Project else {
            print("Could not get project to export")
            return
        }
        
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["csv"]
        panel.nameFieldStringValue = defaultExportName()
        
        self.dialogueActive = true
        panel.beginSheetModal(for: view.window!) { (result) in
            self.dialogueActive = false
            if result == .OK {
                let path = panel.url!
                
                ExportCSV.exportAsync(project: project, path: path)
            }
        }
    }
}
