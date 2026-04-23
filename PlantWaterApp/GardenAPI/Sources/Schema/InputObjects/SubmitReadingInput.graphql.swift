// swiftlint:disable all
// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

nonisolated public struct SubmitReadingInput: InputObject {
  @_spi(Unsafe) public private(set) var __data: InputDict

  @_spi(Unsafe) public init(_ data: InputDict) {
    __data = data
  }

  public init(
    value: Int32,
    emoji: String,
    date: String
  ) {
    __data = InputDict([
      "value": value,
      "emoji": emoji,
      "date": date
    ])
  }

  public var value: Int32 {
    get { __data["value"] }
    set { __data["value"] = newValue }
  }

  public var emoji: String {
    get { __data["emoji"] }
    set { __data["emoji"] = newValue }
  }

  public var date: String {
    get { __data["date"] }
    set { __data["date"] = newValue }
  }
}
// swiftlint:enable all
