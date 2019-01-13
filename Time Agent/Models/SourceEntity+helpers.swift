//
//  SourceEntity+helpers.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 12/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension SourceEntity {
    convenience init() {
        print("Setting up source entity")
        self.init(context: Model.context)
        self.id = UUID().uuidString
        
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }
    
    func wasUpdated() {
        self.updatedAt = Date()
    }
}
