import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: GPUUsageStore
    @State private var draft = AppSettings()
    @State private var draftPassword = ""
    @State private var sshConfigHosts = SSHConfigLoader.loadHosts()
    @State private var selectedSSHConfigAlias = ""

    private var selectedSSHConfigHost: SSHConfigHost? {
        sshConfigHosts.first { $0.alias == selectedSSHConfigAlias }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("GPUUsage Settings")
                    .font(.title3.weight(.semibold))
                Text("우클릭 메뉴로 언제든 다시 열 수 있습니다.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !sshConfigHosts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Import From ~/.ssh/config")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button("Reload") {
                            reloadSSHConfigHosts()
                        }
                    }

                    Picker("Saved Host", selection: $selectedSSHConfigAlias) {
                        Text("Select a saved host").tag("")

                        ForEach(sshConfigHosts) { host in
                            Text(host.displayName).tag(host.alias)
                        }
                    }

                    if let selectedSSHConfigHost {
                        Text(selectedSSHConfigHost.detailSummary)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack {
                        Spacer()

                        Button("Use Selected Host") {
                            applySSHConfigHost()
                        }
                        .disabled(selectedSSHConfigHost == nil)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("SSH Target")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("gpu-prod or user@host", text: $draft.sshTarget)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Identity File (Optional)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("~/.ssh/id_ed25519", text: $draft.sshIdentityFilePath)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("SSH Password (Optional)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                SecureField("Password-based auth", text: $draftPassword)
                    .textFieldStyle(.roundedBorder)
                Text("비워두면 키 기반 인증을 사용합니다. 입력한 비밀번호는 UserDefaults가 아니라 macOS Keychain에 저장됩니다.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("SSH Port (Optional)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Leave blank to use ~/.ssh/config or port 22", text: $draft.sshPort)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Refresh Interval")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Stepper(value: $draft.pollIntervalSeconds, in: 3...300) {
                    Text("\(draft.pollIntervalSeconds) seconds")
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Menu Bar Summary")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Menu Bar Summary", selection: $draft.menuBarDisplayMode) {
                    ForEach(MenuBarDisplayMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.menu)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Remote Command")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField(AppSettings.defaultRemoteCommand, text: $draft.remoteCommand)
                    .textFieldStyle(.roundedBorder)
            }

            Text("로컬 Mac의 SSH 키와 ~/.ssh/config를 그대로 사용합니다. `SSH Target`에 alias를 넣으면 config의 포트/유저가 적용되고, 직접 host를 넣을 때만 `SSH Port`를 채우면 됩니다. PATH 문제가 있으면 `nvidia-smi` 대신 전체 경로를 넣으면 됩니다.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Button("Reload Current") {
                    loadCurrentSettings()
                }

                Button("Clear Saved Settings") {
                    store.resetConfiguration()
                    loadCurrentSettings()
                }

                Spacer()

                Button("Apply") {
                    store.applySettings(draft, password: draftPassword)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(draft == store.settings && draftPassword == store.loadSavedPassword())
            }
        }
        .padding(20)
        .frame(width: 500)
        .onAppear {
            reloadSSHConfigHosts()
            loadCurrentSettings()
        }
    }

    private func loadCurrentSettings() {
        draft = store.settings
        draftPassword = store.loadSavedPassword()
    }

    private func reloadSSHConfigHosts() {
        sshConfigHosts = SSHConfigLoader.loadHosts()

        if selectedSSHConfigAlias.isEmpty || !sshConfigHosts.contains(where: { $0.alias == selectedSSHConfigAlias }) {
            selectedSSHConfigAlias = sshConfigHosts.first?.alias ?? ""
        }
    }

    private func applySSHConfigHost() {
        guard let selectedSSHConfigHost else { return }
        draft = selectedSSHConfigHost.apply(to: draft)
    }
}
