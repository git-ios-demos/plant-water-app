import Foundation

/// Represents a real-time sensor data point used for live updates,
/// such as streaming values in a chart or monitoring UI.
struct LiveSensorPointModel: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int
}

extension LiveSensorPointModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "LiveSensorPointModel(id: \(id), date: \(date), value: \(value))"
    }
}

// Conforming to CustomDebugStringConvertible via an extension keeps
// debugging logic separate from the core model definition,
// improving readability and separation of concerns.
//
// This provides consistent, structured output when inspecting values
// during debugging (for example in logs/console), which I find
// contributes to a more efficient workflow.
//
// AI initially suggested using CustomStringConvertible, but that protocol
// is intended for user facing descriptions. This was adjusted to
// CustomDebugStringConvertible to better separate debug output from
// any UI representation.
