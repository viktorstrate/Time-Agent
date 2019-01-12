//
//  FileSync.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 12/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Foundation
import Sync

class FileSync {
    let path: URL
    
    init(path: URL) {
        self.path = path
    }
    
    func save() {
        try! "Saved data".write(to: path, atomically: false, encoding: .utf8)
    }
}
