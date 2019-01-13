//
//  Task+helpers.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 12/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension Task {
    convenience init(name: String, duration: TimeInterval, start: Date) {
        self.init()
        self.name = name
        self.duration = duration
        self.start = start
    }
}
