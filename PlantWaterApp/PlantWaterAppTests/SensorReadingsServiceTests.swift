import Testing
import Foundation
import GardenAPI
@testable import PlantWaterApp

@MainActor
struct SensorReadingsServiceTests {
    @Test
    func fetchReadings_whenClientThrows_propagatesError() async {
        let mockClient = MockGraphQLClient()
        mockClient.fetchReadingsResult = .failure(MockError.forcedFailure)

        let service = SensorReadingsService(graphQLClient: mockClient)

        do {
            _ = try await service.fetchReadings()
            Issue.record("Expected fetchReadings() to throw, but it succeeded.")
        } catch {
            #expect(error as? MockError == .forcedFailure)
            #expect(mockClient.fetchReadingsCallCount == 1)
        }
    }

    @Test
    func saveReading_forwardsValueEmojiAndISO8601DateToClient() async {
        let mockClient = MockGraphQLClient()
        mockClient.submitReadingResult = .failure(MockError.forcedFailure)

        let service = SensorReadingsService(graphQLClient: mockClient)

        let date = Date(timeIntervalSince1970: 0)

        do {
            _ = try await service.saveReading(
                value: 55,
                emoji: "🌱",
                date: date
            )
            Issue.record("Expected saveReading() to throw, but it succeeded.")
        } catch {
            #expect(error as? MockError == .forcedFailure)
            #expect(mockClient.submitReadingCallCount == 1)
            #expect(mockClient.lastSubmittedValue == 55)
            #expect(mockClient.lastSubmittedEmoji == "🌱")
            #expect(mockClient.lastSubmittedDate == "1970-01-01T00:00:00Z")
        }
    }

    @Test
    func deleteReading_forwardsIdToClient() async throws {
        let mockClient = MockGraphQLClient()
        let service = SensorReadingsService(graphQLClient: mockClient)

        try await service.deleteReading(id: "abc123")

        #expect(mockClient.deleteReadingCallCount == 1)
        #expect(mockClient.lastDeletedID == "abc123")
    }

    @Test
    func clearAllReadings_callsClient() async throws {
        let mockClient = MockGraphQLClient()
        let service = SensorReadingsService(graphQLClient: mockClient)

        try await service.clearAllReadings()

        #expect(mockClient.clearAllReadingsCallCount == 1)
    }

    @Test
    func deleteReading_whenClientThrows_propagatesError() async {
        let mockClient = MockGraphQLClient()
        mockClient.deleteReadingError = MockError.forcedFailure

        let service = SensorReadingsService(graphQLClient: mockClient)

        do {
            try await service.deleteReading(id: "bad-id")
            Issue.record("Expected deleteReading() to throw, but it succeeded.")
        } catch {
            #expect(error as? MockError == .forcedFailure)
            #expect(mockClient.deleteReadingCallCount == 1)
            #expect(mockClient.lastDeletedID == "bad-id")
        }
    }

    @Test
    func clearAllReadings_whenClientThrows_propagatesError() async {
        let mockClient = MockGraphQLClient()
        mockClient.clearAllReadingsError = MockError.forcedFailure

        let service = SensorReadingsService(graphQLClient: mockClient)

        do {
            try await service.clearAllReadings()
            Issue.record("Expected clearAllReadings() to throw, but it succeeded.")
        } catch {
            #expect(error as? MockError == .forcedFailure)
            #expect(mockClient.clearAllReadingsCallCount == 1)
        }
    }
}

// MARK: - Mocks

final class MockGraphQLClient: GraphQLClientProtocol {
    var fetchReadingsResult: Result<[GetReadingsQuery.Data.Reading], Error> = .success([])
    var submitReadingResult: Result<SubmitReadingMutation.Data.SubmitReading, Error>?
    var deleteReadingError: Error?
    var clearAllReadingsError: Error?

    var fetchReadingsCallCount = 0
    var submitReadingCallCount = 0
    var deleteReadingCallCount = 0
    var clearAllReadingsCallCount = 0

    var lastSubmittedValue: Int?
    var lastSubmittedEmoji: String?
    var lastSubmittedDate: String?
    var lastDeletedID: String?

    func fetchReadings() async throws -> [GetReadingsQuery.Data.Reading] {
        fetchReadingsCallCount += 1
        return try fetchReadingsResult.get()
    }

    func submitReading(
        value: Int,
        emoji: String,
        date: String
    ) async throws -> SubmitReadingMutation.Data.SubmitReading {
        submitReadingCallCount += 1
        lastSubmittedValue = value
        lastSubmittedEmoji = emoji
        lastSubmittedDate = date

        guard let submitReadingResult else {
            fatalError("submitReadingResult must be set before calling submitReading")
        }

        return try submitReadingResult.get()
    }

    func deleteReading(id: String) async throws {
        deleteReadingCallCount += 1
        lastDeletedID = id

        if let deleteReadingError {
            throw deleteReadingError
        }
    }

    func clearAllReadings() async throws {
        clearAllReadingsCallCount += 1

        if let clearAllReadingsError {
            throw clearAllReadingsError
        }
    }
}

private enum MockError: Error, Equatable {
    case forcedFailure
}

// Tests files follow the Arrange–Act–Assert (AAA) pattern to keep
// structure consistent and easy to scan.
//
// - Arrange: set up mocks and initial state
// - Act: perform the operation under test
// - Assert: verify results and side effects
