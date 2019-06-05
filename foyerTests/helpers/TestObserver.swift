import Foundation
import RxSwift
import RxCocoa
import RxTest
import XCTest

/**
 A `TestObserver` is a wrapper around an `Observer` that saves all events to an internal array so that
 assertions can be made on a signal's behavior. To use, just create an instance of `TestObserver` that
 matches the type of signal/producer you are testing, and observer/start your signal by feeding it the
 wrapped observer. For example,

 ```
 let test = TestObserver<Int>()
 mySignal.observer(test.observer)

 // ... later ...

 test.assertValues([1, 2, 3])
 ```
 */
class TestObserver<Value> {

    let observer: TestableObserver<Value>

    init() {
        let testScheduler = TestScheduler(initialClock: 0)
        self.observer = testScheduler.createObserver(Value.self)
    }

    /// Get all of the next values emitted by the signal.
    var values: [Value] {
        return self.observer.events.map { $0.value.element! }
    }

    /// Get the last value emitted by the signal.
    var lastValue: Value? {
        return self.values.last
    }

    /// `true` if at least one `.Next` value has been emitted.
    var didEmitValue: Bool {
        return !self.values.isEmpty
    }

    /// The failed error if the signal has failed.
    var failedError: Error? {
        return self.observer.events.compactMap { $0.value.error }.first
    }

    /// `true` if a `.Failed` event has been emitted.
    var didFail: Bool {
        return self.failedError != nil
    }

    /// `true` if a `.Completed` event has been emitted.
    var didComplete: Bool {
        return !(self.observer.events.filter { $0.value.isCompleted }.isEmpty)
    }

    /// `true` if a .Interrupt` event has been emitted.
    var didInterrupt: Bool {
        return !(self.observer.events.filter { $0.value.isStopEvent }.isEmpty)
    }

    func assertDidComplete(_ message: String = "Should have completed.", file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(self.didComplete, message, file: file, line: line)
    }

    func assertDidFail(_ message: String = "Should have failed.", file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(self.didFail, message, file: file, line: line)
    }

    func assertDidNotFail(_ message: String = "Should not have failed.", file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(self.didFail, message, file: file, line: line)
    }

    func assertDidInterrupt(_ message: String = "Should have failed.", file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(self.didInterrupt, message, file: file, line: line)
    }

    func assertDidNotInterrupt(_ message: String = "Should not have failed.", file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(self.didInterrupt, message, file: file, line: line)
    }

    func assertDidNotComplete(_ message: String = "Should not have completed", file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(self.didComplete, message, file: file, line: line)
    }

    func assertDidEmitValue(_ message: String = "Should have emitted at least one value.", file: StaticString = #file, line: UInt = #line) {
        XCTAssert(!self.values.isEmpty, message, file: file, line: line)
    }

    func assertDidNotEmitValue(_ message: String = "Should not have emitted any values.", file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(0, self.values.count, message, file: file, line: line)
    }

    func assertDidTerminate(_ message: String = "Should have terminated, i.e. completed/failed/interrupted.", file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(self.didFail || self.didComplete || self.didInterrupt, message, file: file, line: line)
    }

    func assertDidNotTerminate(_ message: String = "Should not have terminated, i.e. completed/failed/interrupted.",
                               file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(!self.didFail && !self.didComplete && !self.didInterrupt, message, file: file, line: line)
    }

    func assertValueCount(_ count: Int, _ message: String? = nil, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(count, self.values.count, message ?? "Should have emitted \(count) values", file: file, line: line)
    }
}

extension TestObserver where Value: Equatable {
    func assertValue(_ value: Value, _ message: String? = nil, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(1, self.values.count, "A single item should have been emitted.", file: file, line: line)
        XCTAssertEqual(value, self.lastValue, message ?? "A single value of \(value) should have been emitted", file: file, line: line)
    }

    func assertLastValue(_ value: Value, _ message: String? = nil, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(value, self.lastValue, message ?? "Last emitted value is equal to \(value).", file: file, line: line)
    }

    func assertValues(_ values: [Value], _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(values, self.values, message, file: file, line: line)
    }
}

//extension TestObserver where Value: Sequence, Value.Iterator.Element: Equatable {
//
//    func assertValue(_ value: Value, _ message: String? = nil, file: StaticString = #file, line: UInt = #line) {
//        XCTAssertEqual(1, self.values.count, "A single item should have been emitted.", file: file, line: line)
//        XCTAssertEqual(
//            Array(value),
//            self.lastValue.map(Array.init) ?? [],
//            message ?? "A single value of \(value) should have been emitted",
//            file: file,
//            line: line
//        )
//    }
//
//    func assertLastValue(_ value: Value, _ message: String? = nil, file: StaticString = #file, line: UInt = #line) {
//        XCTAssertEqual(Array(value), self.lastValue.map(Array.init) ?? [], message ?? "Last emitted value is equal to \(value).", file: file, line: line)
//    }
//
//    func assertValues(_ values: [[Value.Iterator.Element]], _ message: String = "", file: StaticString = #file, line: UInt = #line) {
//        XCTAssertEqual(Array(values), Array(self.values.map(Array.init)), message, file: file, line: line)
//    }
//}

//extension TestObserver where Value: RxOptional.OptionalType, Value.Wrapped: Equatable {
//
//    internal func assertValue(_ value: Value, _ message: String? = nil,
//                              file: StaticString = #file, line: UInt = #line) {
//        XCTAssertEqual(1, self.values.count, "A single item should have been emitted.", file: file, line: line)
//        XCTAssertEqual(value.value,
//                       self.lastValue?.value,
//                       message ?? "A single value of \(value) should have been emitted", file: file, line: line)
//    }
//
//    internal func assertLastValue(_ value: Value, _ message: String? = nil,
//                                  file: StaticString = #file, line: UInt = #line) {
//        XCTAssertEqual(value.value,
//                       self.lastValue?.value,
//                       message ?? "Last emitted value is equal to \(value).", file: file, line: line)
//    }
//
//    internal func assertValues(_ values: [Value], _ message: String = "",
//                               file: StaticString = #file, line: UInt = #line) {
//        // TODO:
//        //        XCTAssertEqual(values, self.values, message, file: file, line: line)
//    }
//}

// Assert equality between two doubly nested arrays of equatables.
private func XCTAssertEqual<T: Equatable>(
    _ expression1: @autoclosure () -> [[T]],
    _ expression2: @autoclosure () -> [[T]],
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line) {

    let lhs = expression1()
    let rhs = expression2()
    XCTAssertEqual(lhs.count, rhs.count, "Expected \(lhs.count) elements, but found \(rhs.count).", file: file, line: line)

    zip(lhs, rhs).forEach { xs, ys in
        XCTAssertEqual(xs, ys, "Expected \(lhs), but found \(rhs): \(message)", file: file, line: line)
    }
}
