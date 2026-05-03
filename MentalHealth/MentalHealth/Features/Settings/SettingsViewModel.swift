import Foundation
import SwiftUI

enum AccentPreset: String, CaseIterable, Identifiable {
    case blue, green, orange, red, purple, teal, pink

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
    var color: Color {
        switch self {
        case .blue:   return .blue
        case .green:  return .green
        case .orange: return .orange
        case .red:    return .red
        case .purple: return .purple
        case .teal:   return .teal
        case .pink:   return .pink
        }
    }
}

@Observable
final class SettingsViewModel {
    var isExporting = false
    var isImporting = false
    var showResetConfirm = false
    var showCrisisResources = false
    var exportDocument: JSONDocument?
    var errorMessage: String?
}
