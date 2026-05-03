import Foundation

@Observable
final class SettingsViewModel {
    var isExporting = false
    var isImporting = false
    var alertMessage: String?
}
