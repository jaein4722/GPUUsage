import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = GPUUsageStore()
    private var statusItemController: StatusItemController?
    private lazy var settingsWindowController = SettingsWindowController(store: store)

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let statusItemController = StatusItemController(store: store)
        statusItemController.showSettingsAction = { [weak self] in
            self?.showSettingsWindow()
        }
        self.statusItemController = statusItemController

        if !store.settings.isConfigured {
            DispatchQueue.main.async { [weak self] in
                self?.showSettingsWindow()
            }
        }
    }

    private func showSettingsWindow() {
        settingsWindowController.present()
    }
}
