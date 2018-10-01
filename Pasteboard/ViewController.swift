//
//  ViewController.swift
//  Pasteboard
//
//  Created by Diatoming on 10/1/18.
//  Copyright © 2018 diatoming.com. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    let menuItemController = MenuBarItemController()
    lazy var monitors: [PasteboardMonitor] = []
    
    var menus: [NSMenuItem] = [] {
        didSet {
            var items = menus
            items.append(NSMenuItem.separator())
            items.append(quitMenu)
            
            self.mainMenu?.items = items
        }
    }
    
    let quitMenu = NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "")
    
    // 📝TODO: let user set max count
    let maxCacheCount = 20
    var mainMenu: NSMenu? {
        return self.menuItemController.statusItem.menu
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.menuItemController.statusItem.button?.image = #imageLiteral(resourceName: "doc.plaintext")
        self.menuItemController.statusItem.menu = NSMenu(title: "menu")
        
        self.menuItemController.statusItem.menu?.addItem(NSMenuItem.separator())
        self.menuItemController.statusItem.menu?.addItem(quitMenu)

        let pasteboard = NSPasteboard.general
        let pbMonitor = PasteboardMonitor(pasteboard: pasteboard)
        pbMonitor.delegate = self
        
        monitors.append(pbMonitor)
    }

    @objc func menuItemClicked(_ sender: NSMenuItem) {
//        print(sender)
//        print(sender.title)
        for monitor in self.monitors {
            
            monitor.stop()
            
            if monitor.pasteboard == NSPasteboard.general {
                let pb = monitor.pasteboard
                pb.clearContents()
                pb.setString(sender.title, forType: .string)
            }
            
            monitor.resetCount()
            
            monitor.start()
            
        }
    }

}
extension ViewController: PasteboardMonitorDelegate {
    func pasteboardChangeDetected(monitor: PasteboardMonitor, item: NSPasteboardItem) {
        print(item)
        print(monitor.lastChangeCount)
        if monitor.pasteboard == NSPasteboard.general, let str = item.plainText() {
            if self.menus.count >= maxCacheCount {
                self.menus.removeFirst()
            }
            self.menus.append(newMenuItem(title: str, action: #selector(self.menuItemClicked)))
        }
    }
    
    func newMenuItem(title: String, action: Selector) -> NSMenuItem {
        let item =  NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }
}

extension NSPasteboardItem {
    func plainText() -> String? {
        return self.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text"))
    }
}


