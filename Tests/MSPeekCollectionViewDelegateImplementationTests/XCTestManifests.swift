import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MSPeekCollectionViewDelegateImplementationTests.allTests),
    ]
}
#endif
