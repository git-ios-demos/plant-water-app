// swiftlint:disable all
// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct ClearAllReadingsMutation: GraphQLMutation {
  public static let operationName: String = "ClearAllReadings"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation ClearAllReadings { clearAllReadings }"#
    ))

  public init() {}

  nonisolated public struct Data: GardenAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { GardenAPI.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("clearAllReadings", Bool.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ClearAllReadingsMutation.Data.self
    ] }

    public var clearAllReadings: Bool { __data["clearAllReadings"] }
  }
}
// swiftlint:enable all
