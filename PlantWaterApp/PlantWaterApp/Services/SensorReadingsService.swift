import Foundation

protocol SensorReadingsServiceProtocol {
    func fetchReadings() async throws -> [SensorReadingModel]
    func saveReading(value: Int, emoji: String, date: Date) async throws -> SensorReadingModel
    func deleteReading(id: String) async throws
    func clearAllReadings() async throws
}

struct SensorReadingsService: SensorReadingsServiceProtocol {
    private let graphQLClient: GraphQLClientProtocol
    private let iso8601Formatter = ISO8601DateFormatter()

    init(graphQLClient: GraphQLClientProtocol = GraphQLClient.shared) {
        self.graphQLClient = graphQLClient
    }

    func fetchReadings() async throws -> [SensorReadingModel] {
        let readings = try await graphQLClient.fetchReadings()
        return try readings.map(SensorReadingGraphQLMapper.map)
    }

    func saveReading(value: Int, emoji: String, date: Date) async throws -> SensorReadingModel {
        let savedReading = try await graphQLClient.submitReading(
            value: value,
            emoji: emoji,
            date: iso8601Formatter.string(from: date)
        )

        return try SensorReadingGraphQLMapper.map(savedReading)
    }

    func deleteReading(id: String) async throws {
        try await graphQLClient.deleteReading(id: id)
    }

    func clearAllReadings() async throws {
        try await graphQLClient.clearAllReadings()
    }
}

// This service keeps the app-facing model layer separate from Apollo generated
// GraphQL types. The view models work with SensorReadingModel, while this layer
// handles networking calls, date formatting, and GraphQL to domain mapping.
//
// AI initially mixed Apollo response types into higher level app code, but this
// boundary keeps the UI independent from the backend client implementation.
