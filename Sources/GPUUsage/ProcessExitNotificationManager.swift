import Foundation
import UserNotifications

@MainActor
struct ProcessExitNotificationManager {
    var isSupportedEnvironment: Bool {
        Bundle.main.bundleURL.pathExtension == "app" && Bundle.main.bundleIdentifier != nil
    }

    private var center: UNUserNotificationCenter? {
        guard isSupportedEnvironment else { return nil }
        return UNUserNotificationCenter.current()
    }

    func requestAuthorizationIfNeeded() async -> Bool {
        guard let center else { return false }
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    func sendExitNotification(for watch: ProcessExitWatch) async -> Bool {
        guard let center else { return false }

        let content = UNMutableNotificationContent()
        content.title = "\(watch.displayProcessName) finished"
        content.body = watch.subtitle
        content.sound = .default
        content.interruptionLevel = .active

        let request = UNNotificationRequest(
            identifier: "gpuusage.process-exit.\(watch.id)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        do {
            try await center.add(request)
            return true
        } catch {
            return false
        }
    }
}
