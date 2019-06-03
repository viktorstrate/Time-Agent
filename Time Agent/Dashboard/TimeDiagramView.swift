//
//  TimeDiagramView.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 11/05/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class TimeDiagramView: NSView {
    
    var tasks: [Task] = []
    
    var start: Date = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())! {
        didSet {
            _updateTasks()
        }
    }
    
    var end: Date = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())! {
        didSet {
            _updateTasks()
        }
    }

    override func awakeFromNib() {
        self.wantsLayer = true
        self.superview?.wantsLayer = true
        _updateTasks()
    }
    
    var context: CGContext? {
        get {
            return NSGraphicsContext.current?.cgContext
        }
    }
    
    func _updateTasks() {
        tasks = Task.fetch(between: start, and: end)
        print("Dashboard found \(tasks.count) tasks")
    }
    
    override func layout() {
        super.layout()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.shadow = NSShadow()
        self.layer?.backgroundColor = NSColor.red.cgColor
        self.layer?.shadowOpacity = 0.1
        self.layer?.shadowColor = NSColor.black.cgColor
        self.layer?.shadowOffset = NSMakeSize(0, -2)
        self.layer?.shadowRadius = 2
        
        let window = NSBezierPath(rect: bounds)
        NSColor.white.setFill()
        window.fill()
        
        drawBackLines()
    }
    
    func drawBackLines() {
        let height = bounds.height - 40
        
        var maxHours = self.getHighestStep(for: tasks) / (60.0*60.0)
        maxHours = max(maxHours, 1)
        
        
        let hourStep = ceil(maxHours / 6.0)
        
        let lineSpace: CGFloat = height / CGFloat(ceil(maxHours / hourStep))
        
        var hours = 0.0
        
        while hours <= maxHours {
            
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: lineSpace*CGFloat(hours)))
            path.addLine(to: CGPoint(x: bounds.width - 60, y: lineSpace*CGFloat(hours)))
            path.closeSubpath()
            
            context?.setLineWidth(1.0)
            context?.setStrokeColor(NSColor(calibratedWhite: 0.9, alpha: 1).cgColor)
            context?.addPath(path)
            context?.drawPath(using: CGPathDrawingMode.stroke)
            
            if hours > 0 {
                let formatting: [NSAttributedString.Key: Any] = [
                    .foregroundColor: NSColor.gray
                ]
                
                NSString(string: "\(String(format:"%.0f", hours))h" ).draw(in: NSRect(x: bounds.width - 40, y: lineSpace*CGFloat(hours)-10, width: 35, height: 20), withAttributes: formatting)
            }
            
            hours += hourStep
        }
    }
}
