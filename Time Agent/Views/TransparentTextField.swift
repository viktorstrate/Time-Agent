//
//  TransparentTextField.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 19/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class TransparentTextField: NSTextField {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        

    }
    
    override func awakeFromNib() {
        self.drawsBackground = false
        self.isEditable = false
        self.isBezeled = false
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
