//
//  PasteboardMonitor.swift
//  Pasteboard
//
//  Created by Diatoming on 10/1/18.
//  Copyright © 2018 diatoming.com. All rights reserved.
//

import Cocoa

protocol PasteboardMonitorDelegate {
    func pasteboardChangeDetected(monitor: PasteboardMonitor, item: NSPasteboardItem)
}

class PasteboardMonitor {
    
    var delegate: PasteboardMonitorDelegate?
    
    var pasteboard: NSPasteboard
    var timer: Timer?
    var lastChangeCount = 0
    
    public init(pasteboard: NSPasteboard) {
        self.pasteboard = pasteboard
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        update()
    }
    
    @objc public func update() {
//        print("ticking---")
        
        if self.pasteboard.changeCount != lastChangeCount {
            resetCount()
            if let item = self.pasteboard.pasteboardItems?.first {
                delegate?.pasteboardChangeDetected(monitor: self, item: item)
            }
        }
    }
    
    func resetCount() {
        lastChangeCount = self.pasteboard.changeCount
    }
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func stop() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}
