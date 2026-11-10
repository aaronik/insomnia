import AppKit
import IOKit.pwr_mgt

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    static func main() {
        let application = NSApplication.shared
        let delegate = AppDelegate()
        application.delegate = delegate
        application.setActivationPolicy(.accessory)
        application.run()
    }

    private var statusItem: NSStatusItem!
    private var displaySleepAssertion: IOPMAssertionID?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: 46)
        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(statusItemClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        updateAppearance()
    }

    func applicationWillTerminate(_ notification: Notification) {
        deactivate()
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showContextMenu()
        } else if displaySleepAssertion == nil {
            activate()
        } else {
            deactivate()
        }
    }

    private func activate() {
        var assertionID: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Insomnia is keeping the display awake" as CFString,
            &assertionID
        )

        guard result == kIOReturnSuccess else {
            NSApp.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.messageText = "Could not keep the Mac awake"
            alert.informativeText = "macOS rejected the power assertion (error \(result))."
            alert.runModal()
            return
        }

        displaySleepAssertion = assertionID
        updateAppearance()
    }

    private func deactivate() {
        if let assertionID = displaySleepAssertion {
            IOPMAssertionRelease(assertionID)
            displaySleepAssertion = nil
        }
        updateAppearance()
    }

    private func updateAppearance() {
        guard let button = statusItem?.button else { return }
        let active = displaySleepAssertion != nil
        button.title = ""
        button.imagePosition = .imageOnly
        button.image = switchImage(active: active)
        button.toolTip = active
            ? "Insomnia is on — click to allow idle sleep; right-click for options"
            : "Insomnia is off — click to keep the display awake; right-click for options"
        button.setAccessibilityLabel("Insomnia")
        button.setAccessibilityValue(active ? "On" : "Off")
    }

    private func switchImage(active: Bool) -> NSImage {
        let image = NSImage(size: NSSize(width: 38, height: 20), flipped: false) { _ in
            let track = NSRect(x: 1, y: 2, width: 36, height: 16)
            let trackPath = NSBezierPath(roundedRect: track, xRadius: 8, yRadius: 8)
            (active ? NSColor.systemGreen : NSColor.secondaryLabelColor).setFill()
            trackPath.fill()

            let knob = NSRect(x: active ? 21 : 3, y: 4, width: 12, height: 12)
            NSColor.white.setFill()
            NSBezierPath(ovalIn: knob).fill()
            return true
        }
        image.isTemplate = false // Preserve green/gray rather than tinting the entire switch.
        return image
    }

    private func showContextMenu() {
        let menu = NSMenu()
        let state = displaySleepAssertion == nil ? "Off" : "On"
        let stateItem = NSMenuItem(title: "Insomnia: \(state)", action: nil, keyEquivalent: "")
        stateItem.isEnabled = false
        menu.addItem(stateItem)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit Insomnia", action: #selector(quit(_:)), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        if let button = statusItem.button {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height), in: button)
        }
    }

    @objc private func quit(_ sender: Any?) {
        NSApp.terminate(nil)
    }
}
