//
//  TimeDiagramView.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 11/05/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

@IBDesignable
class TimeDiagramView: NSView {
    
    func getTotalDuration(from start: Date, to end: Date) -> TimeInterval {
        let tasks = Task.fetch(between: start, and: end)
        
        var result = TimeInterval(exactly: 0)!
        
        for task in tasks {
            result += task.duration
        }
        
        return result
    }
    
    func getTimeStepInterval() -> TimeInterval {
        let duration = getTotalDuration(from: start, to: end)
        
        let hour = 60.0 * 60.0
        let day = hour * 24.0
        let week = day * 7.0
        let month = day * 30.0
        let year = day * 365.0
        
        if duration < day {
            return hour
        }
        
        if duration < week * 2.0 {
            return day
        }
        
        if duration < month * 4.0 {
            return week
        }
        
        if duration < year {
            return month
        }
        
        return year
    }
    
    func getHighestStep() -> TimeInterval {
        let stepSize = getTimeStepInterval()
        var cursor = start
        
        var longestDuration = 0.0
        
        while cursor < end {
            
            let duration = getTotalDuration(from: cursor, to: cursor.addingTimeInterval(stepSize))
            if duration > longestDuration {
                longestDuration = duration
            }
            
            cursor = cursor.addingTimeInterval(stepSize)
        }
        
        return longestDuration
    }
    
    var start: Date = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
    var end: Date = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!

    override func awakeFromNib() {
        self.wantsLayer = true
        self.superview?.wantsLayer = true
        print("Total duration: ")
        print(getTotalDuration(from: Date.distantPast, to: Date.distantFuture))
    }
    
    var context: CGContext? {
        get {
            return NSGraphicsContext.current?.cgContext
        }
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
        
        let maxHours = getHighestStep() / (60.0*60.0)
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
    
    override func prepareForInterfaceBuilder() {
    }
}
