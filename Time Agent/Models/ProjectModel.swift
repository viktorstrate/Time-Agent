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
            return managedObject.value(forKey: "name") as? String
        }

        set {
            managedObject.setValue(newValue, forKey: "name")
        }
    }
    
    static func addProject(name projectName: String) -> ProjectModel {
        let entity = NSEntityDescription.entity(forEntityName: "Project", in: Model.coreDataContext)
        let managedObject = NSManagedObject(entity: entity!, insertInto: Model.coreDataContext)
        let newModel = ProjectModel(managedObject)
        
        newModel.name = projectName
        
        return newModel
    }
    
    static func fetchAll() -> [ProjectModel] {
        return Model.fetchAllModels(name: "Project")!.map({ (model) -> ProjectModel in
            return ProjectModel(model.managedObject)
        })
    }
}
