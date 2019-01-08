//
//  TimerBadge.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 08/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class TimerBadge: NSButton {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    // Make it click through
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
    
}
