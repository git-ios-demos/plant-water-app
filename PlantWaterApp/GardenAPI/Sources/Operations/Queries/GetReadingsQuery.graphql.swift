// swiftlint:disable all
// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct GetReadingsQuery: GraphQLQuery {
  public static let operationName: String = "GetReadings"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetReadings { readings { __typename id value emoji date } }"#
    ))

  public init() {}

  nonisolated public struct Data: GardenAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GardenAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("readings", [Reading].self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetReadingsQuery.Data.self
    ] }

    public var readings: [Reading] { __data["readings"] }

    /// Reading
    ///
    /// Parent Type: `Reading`
    nonisolated public struct Reading: GardenAPI.SelectionSet {
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
        GetReadingsQuery.Data.Reading.self
      ] }

      public var id: GardenAPI.ID { __data["id"] }
      public var value: Int { __data["value"] }
      public var emoji: String { __data["emoji"] }
      public var date: String { __data["date"] }
    }
  }
}
// swiftlint:enable all
