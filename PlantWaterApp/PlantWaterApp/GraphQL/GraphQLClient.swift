import Foundation
import Apollo
import GardenAPI

protocol GraphQLClientProtocol {
    func fetchReadings() async throws -> [GetReadingsQuery.Data.Reading]

    func submitReading(
        value: Int,
        emoji: String,
        date: String
    ) async throws -> SubmitReadingMutation.Data.SubmitReading

    func deleteReading(id: String) async throws

    func clearAllReadings() async throws
}

final class GraphQLClient {
    static let shared = GraphQLClient()

    private(set) var apollo: ApolloClient

    private init() {
        guard let url = URL(string: "https://sweet-fog-1609.donald-mallow-721.workers.dev/") else {
            fatalError("Invalid GraphQL endpoint URL")
        }

        self.apollo = ApolloClient(url: url)
    }

    func updateEndpoint(_ url: URL) {
        apollo = ApolloClient(url: url)
    }

    func fetchReadings() async throws -> [GetReadingsQuery.Data.Reading] {
        let response = try await apollo.fetch(query: GetReadingsQuery(), cachePolicy: .networkOnly)

        if let readings = response.data?.readings { return readings }

        try throwGraphQLErrorsIfPresent(response.errors)
        throw GraphQLClientError.noDataReturned
    }

    func submitReading(
        value: Int,
        emoji: String,
        date: String
    ) async throws -> SubmitReadingMutation.Data.SubmitReading {
        guard let graphQLValue = Int32(exactly: value) else {
            throw GraphQLClientError.invalidReadingValue(value)
        }

        let input = SubmitReadingInput(value: graphQLValue, emoji: emoji, date: date)

        let response = try await apollo.perform(mutation: SubmitReadingMutation(input: input))

        if let reading = response.data?.submitReading { return reading }

        try throwGraphQLErrorsIfPresent(response.errors)
        throw GraphQLClientError.noDataReturned
    }

    func deleteReading(id: String) async throws {
        let response = try await apollo.perform(mutation: DeleteReadingMutation(id: id))

        if response.data?.deleteReading == true { return }

        try throwGraphQLErrorsIfPresent(response.errors)
        throw GraphQLClientError.noDataReturned
    }

    func clearAllReadings() async throws {
        let response = try await apollo.perform(mutation: ClearAllReadingsMutation())

        if response.data?.clearAllReadings == true { return }

        try throwGraphQLErrorsIfPresent(response.errors)
        throw GraphQLClientError.noDataReturned
    }

    private func throwGraphQLErrorsIfPresent(_ errors: [GraphQLError]?) throws {
        guard let errors, !errors.isEmpty else { return }

        throw GraphQLClientError.graphQLErrors(
            errors.map(\.localizedDescription)
        )
    }
}

enum GraphQLClientError: LocalizedError {
    case noDataReturned
    case invalidReadingValue(Int)
    case graphQLErrors([String])

    var errorDescription: String? {
        switch self {
        case .noDataReturned:
            return "No data was returned from the GraphQL server."
        case .invalidReadingValue(let value):
            return "The reading value \(value) could not be converted to GraphQL Int."
        case .graphQLErrors(let messages):
            return messages.joined(separator: ", ")
        }
    }
}

// MARK: - GraphQLClientProtocol Conformance (For Testing)
extension GraphQLClient: GraphQLClientProtocol { }
