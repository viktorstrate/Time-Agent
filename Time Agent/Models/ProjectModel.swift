//
//  Project.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 26/11/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectModel: Model {
    
    var name: String? {
        get {
            return value(forKey: "name") as? String
        }

        set {
            super.setValue(newValue, forKey: "name")
        }
    }
    
    static func addProject(name projectName: String) -> ProjectModel {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Project", in: context)
        let newModel = ProjectModel(entity: entity!, insertInto: context)
        
        newModel.name = projectName
//        newModel.setValue(projectName, forKey: "name")
//        newModel.setName(projectName)
        
        return newModel
    }
    
    static func fetchAll() -> [ProjectModel]? {
        return Model.fetchAllModels(name: "Project") as? [ProjectModel]
    }
}
