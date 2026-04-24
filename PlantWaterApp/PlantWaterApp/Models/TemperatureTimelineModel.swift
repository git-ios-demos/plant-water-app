import Foundation

/// Represents a single data point in the temperature timeline used for charting,
/// including past, current, and future temperature values.
struct TemperatureTimelineModel: Identifiable {
    let id = UUID()
    let date: Date
    let highF: Double
    let lowF: Double
    let currentF: Double?
    let kind: Kind

    /// Indicates whether the timeline entry represents past, current, or future data.
    enum Kind: String, Codable, Hashable {
        case past, today, future
    }
}

extension TemperatureTimelineModel: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        TemperatureTimelineModel(
        id: \(id),
        date: \(date),
        highF: \(highF),
        lowF: \(lowF),
        currentF: \(String(describing: currentF)),
        kind: \(kind.debugDescription))
        """
    }
}

extension TemperatureTimelineModel.Kind: CustomDebugStringConvertible {
    var debugDescription: String {
        "Kind(\(rawValue.uppercased()))"
    }
}

// Nesting `Kind` inside `TemperatureTimelineModel` keeps the enum scoped
// to the model it belongs to, which makes the relationship more explicit
// and avoids adding another global type unnecessarily.
//
// AI initially suggested pulling the enum out to file scope, but I kept it
// nested because it is only meaningful within the context of a temperature
// timeline entry.
