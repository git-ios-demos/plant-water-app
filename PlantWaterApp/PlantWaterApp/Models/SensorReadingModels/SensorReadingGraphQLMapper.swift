import Foundation
import GardenAPI

enum SensorReadingGraphQLMapper {
    private static let iso8601Formatter = ISO8601DateFormatter()

    static func map(_ reading: GetReadingsQuery.Data.Reading) throws -> SensorReadingModel {
        try buildSensorReading(
            id: reading.id,
            dateString: reading.date,
            value: reading.value,
            emoji: reading.emoji
        )
    }

    static func map(_ reading: SubmitReadingMutation.Data.SubmitReading) throws -> SensorReadingModel {
        try buildSensorReading(
            id: reading.id,
            dateString: reading.date,
            value: reading.value,
            emoji: reading.emoji
        )
    }

    private static func buildSensorReading(
        id: String,
        dateString: String,
        value: Int,
        emoji: String
    ) throws -> SensorReadingModel {
        guard let date = iso8601Formatter.date(from: dateString) else {
            throw SensorReadingGraphQLMapperError.invalidDateString(dateString)
        }

        return SensorReadingModel(
            id: id,
            date: date,
            value: value,
            emoji: emoji
        )
    }
}

enum SensorReadingGraphQLMapperError: LocalizedError {
    case invalidDateString(String)

    var errorDescription: String? {
        switch self {
        case .invalidDateString(let value):
            return "Could not convert GraphQL date string into Date: \(value)"
        }
    }
}
