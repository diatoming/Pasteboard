//
//  StatusBarController.swift
//  DownloadTask
//
//  Created by Diatoming on 2/14/17.
//  Copyright © 2017 diatoming. All rights reserved.
//

import Cocoa

final class MenuBarItemController: NSObject, NSWindowDelegate, NSDraggingDestination {
    
    typealias URLDropHandler = (URL) -> Void
    var onURLDropped: URLDropHandler?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var currentOperationCount = 0
    
    override init() {
        super.init()
        setup()
    }
    
    private func setup() {
//        self.statusItem.button?.image = NSImage(named: NSImage.actionTemplateName)
        self.statusItem.button?.image?.isTemplate = true
        
//        self.statusItem.button?.action =
        
        // Enable drag and drop if OS X >= 10.10
        if #available(macOS 10.10, *) {
            statusItem.button?.window?.delegate = self
            statusItem.button?.window?
                .registerForDraggedTypes([NSPasteboard.PasteboardType.string, NSPasteboard.PasteboardType(rawValue: "NSURLPboardType"), NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType"), NSPasteboard.PasteboardType.tiff])
        }
        
    }
    
    func updateStatusItemImage() {
        
    }
    
    deinit {
        NSStatusBar.system.removeStatusItem(statusItem)
    }
    
    // MARK: NSDraggingDestination
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        
        if let str = sender.draggingPasteboard.string(forType: .string),
            let _ = URL(string: str) {
            return .link
        }
        
//        print(sender.draggingPasteboard().propertyList(forType: NSURLPboardType))
//        print(sender.draggingPasteboard().propertyList(forType: NSURLPboardType) as? [String])
        
        if let urls = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSURLPboardType")) as? [String],
            urls.count > 0 {
            return .link
        }
        
        if let paths = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? [String] {
            for path in paths {
                var isDirectory: ObjCBool = false
                if !FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
                    || isDirectory.boolValue {
                    return []
                }
            }
        }
        return .copy
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        
        if let str = sender.draggingPasteboard.string(forType: NSPasteboard.PasteboardType.string),
            let url = URL(string: str) {
            self.onURLDropped?(url)
            return true
        }
        
        if let urls = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSURLPboardType")) as? [String],
            let urlStr = urls.first, let url = URL(string: urlStr) {
            self.onURLDropped?(url)
            return true
        }
        
        if sender.draggingPasteboard.data(forType: .tiff) != nil {
            return true
        } else if let paths = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? [String] {
            for _ in paths {
                
            }
            return true
        }
        return false
    }

}
