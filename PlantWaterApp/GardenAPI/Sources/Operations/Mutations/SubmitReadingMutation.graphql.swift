// swiftlint:disable all
// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct SubmitReadingMutation: GraphQLMutation {
  public static let operationName: String = "SubmitReading"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation SubmitReading($input: SubmitReadingInput!) { submitReading(input: $input) { __typename id value emoji date } }"#
    ))

  public var input: SubmitReadingInput

  public init(input: SubmitReadingInput) {
    self.input = input
  }

  @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

  nonisolated public struct Data: GardenAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GardenAPI.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("submitReading", SubmitReading.self, arguments: ["input": .variable("input")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      SubmitReadingMutation.Data.self
    ] }

    public var submitReading: SubmitReading { __data["submitReading"] }

    /// SubmitReading
    ///
    /// Parent Type: `Reading`
    nonisolated public struct SubmitReading: GardenAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GardenAPI.Objects.Reading }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GardenAPI.ID.self),
        .field("value", Int.self),
        .field("emoji", String.self),
        .field("date", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        SubmitReadingMutation.Data.SubmitReading.self
      ] }

      public var id: GardenAPI.ID { __data["id"] }
      public var value: Int { __data["value"] }
      public var emoji: String { __data["emoji"] }
      public var date: String { __data["date"] }
    }
  }
}
// swiftlint:enable all
