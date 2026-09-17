import XCTest
@testable import YearMonthDay

final class YearMonthDayInitTests: XCTestCase {

    func test_initWithComponents_keepsEachComponent() {
        // Arrange & Act
        let ymd = YearMonthDay(year: 2025, month: 3, day: 26)

        // Assert
        XCTAssertEqual(ymd.year, 2025)
        XCTAssertEqual(ymd.month, 3)
        XCTAssertEqual(ymd.day, 26)
    }

    func test_initWithDate_usesGivenCalendarComponents() {
        // Arrange: 2025-03-26 00:00 UTC
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!
        let date = Date(timeIntervalSince1970: 1_742_947_200)

        // Act
        let ymd = YearMonthDay(date, calendar: utcCalendar)

        // Assert
        XCTAssertEqual(ymd, YearMonthDay(year: 2025, month: 3, day: 26))
    }

    func test_initWithoutArguments_matchesCurrentDate() {
        // Arrange
        let expected = YearMonthDay(Date())

        // Act
        let now = YearMonthDay()

        // Assert
        XCTAssertEqual(now, expected)
    }

    func test_millisecondsToYmd_matchesSecondsBasedInit() {
        // Arrange
        let milliseconds = 1_742_947_200_000

        // Act
        let fromMillis = milliseconds.millisecondsToYmd()

        // Assert
        XCTAssertEqual(fromMillis, YearMonthDay(time: 1_742_947_200))
    }
}

final class YearMonthDayStringTests: XCTestCase {

    func test_description_doesNotPadSingleDigits() {
        XCTAssertEqual(YearMonthDay(year: 2025, month: 3, day: 6).description, "2025-3-6")
    }

    func test_identity_matchesDescription() {
        let ymd = YearMonthDay(year: 2025, month: 3, day: 6)
        XCTAssertEqual(ymd.identity, ymd.description)
    }

    func test_yyyyMMdd_padsToTwoDigits() {
        let ymd = YearMonthDay(year: 2025, month: 3, day: 6)
        XCTAssertEqual(ymd.yyyyMMdd(), "20250306")
        XCTAssertEqual(ymd.yyyyMMdd(joiner: "-"), "2025-03-06")
        XCTAssertEqual(ymd.yyyyMMdd(joiner: "/"), "2025/03/06")
    }

    func test_yyyyMMdd_leavesTwoDigitValuesUnchanged() {
        let ymd = YearMonthDay(year: 2025, month: 12, day: 31)
        XCTAssertEqual(ymd.yyyyMMdd(joiner: "-"), "2025-12-31")
    }

    func test_componentStrings_returnRawValues() {
        let ymd = YearMonthDay(year: 2025, month: 3, day: 6)
        XCTAssertEqual(ymd.yearString, "2025")
        XCTAssertEqual(ymd.monthString, "3")
        XCTAssertEqual(ymd.dayString, "6")
    }
}

final class YearMonthDayComparisonTests: XCTestCase {

    private let base = YearMonthDay(year: 2025, month: 3, day: 26)

    func test_compare_returnsMinusOneZeroOrOne() {
        XCTAssertEqual(base.compare(versus: YearMonthDay(year: 2024, month: 3, day: 26)), 1)
        XCTAssertEqual(base.compare(versus: YearMonthDay(year: 2026, month: 3, day: 26)), -1)
        XCTAssertEqual(base.compare(versus: YearMonthDay(year: 2025, month: 2, day: 26)), 1)
        XCTAssertEqual(base.compare(versus: YearMonthDay(year: 2025, month: 4, day: 26)), -1)
        XCTAssertEqual(base.compare(versus: YearMonthDay(year: 2025, month: 3, day: 25)), 1)
        XCTAssertEqual(base.compare(versus: YearMonthDay(year: 2025, month: 3, day: 27)), -1)
        XCTAssertEqual(base.compare(versus: base), 0)
    }

    func test_comparableOperators_orderByYearThenMonthThenDay() {
        let later = YearMonthDay(year: 2025, month: 4, day: 1)

        XCTAssertTrue(base < later)
        XCTAssertTrue(later > base)
        XCTAssertTrue(base <= later)
        XCTAssertTrue(base <= base)
        XCTAssertTrue(later >= base)
        XCTAssertTrue(base >= base)
        XCTAssertFalse(base > later)
    }

    func test_sorted_ordersAscending() {
        // Arrange
        let unsorted = [
            YearMonthDay(year: 2025, month: 4, day: 1),
            YearMonthDay(year: 2024, month: 12, day: 31),
            YearMonthDay(year: 2025, month: 3, day: 26),
        ]

        // Act
        let sorted = unsorted.sorted()

        // Assert
        XCTAssertEqual(sorted.map(\.description), ["2024-12-31", "2025-3-26", "2025-4-1"])
    }

    func test_compareYearMonth_returnsSignedDifferenceIgnoringDay() {
        // 같은 해에서는 월 차이를 그대로 반환한다.
        XCTAssertEqual(base.compareYearMonth(YearMonthDay(year: 2025, month: 1, day: 1)), 2)
        // 해가 다르면 연 차이를 그대로 반환한다(월·일 무시).
        XCTAssertEqual(base.compareYearMonth(YearMonthDay(year: 2023, month: 12, day: 31)), 2)
        // 일(day)만 다르면 같은 년월로 취급한다.
        XCTAssertEqual(base.compareYearMonth(YearMonthDay(year: 2025, month: 3, day: 1)), 0)
    }

    func test_hashValue_isEqualForEqualValues() {
        XCTAssertEqual(
            Set([base, YearMonthDay(year: 2025, month: 3, day: 26)]).count,
            1)
    }
}

final class YearMonthDayMonthCursorTests: XCTestCase {

    func test_nextMonth_incrementsMonthAndResetsDay() {
        // Arrange
        var cursor = YearMonthDay(year: 2025, month: 1, day: 15)

        // Act
        cursor.nextMonth()

        // Assert
        XCTAssertEqual(cursor, YearMonthDay(year: 2025, month: 2, day: 1))
    }

    func test_nextMonth_rollsOverToJanuaryOfNextYear() {
        var cursor = YearMonthDay(year: 2025, month: 12, day: 31)
        cursor.nextMonth()
        XCTAssertEqual(cursor, YearMonthDay(year: 2026, month: 1, day: 1))
    }

    func test_prevMonth_decrementsMonthAndResetsDay() {
        var cursor = YearMonthDay(year: 2025, month: 3, day: 15)
        cursor.prevMonth()
        XCTAssertEqual(cursor, YearMonthDay(year: 2025, month: 2, day: 1))
    }

    func test_prevMonth_rollsOverToDecemberOfPreviousYear() {
        var cursor = YearMonthDay(year: 2025, month: 1, day: 15)
        cursor.prevMonth()
        XCTAssertEqual(cursor, YearMonthDay(year: 2024, month: 12, day: 1))
    }

    func test_prevMonth_doesNotMoveBefore1970() {
        // Arrange
        var cursor = YearMonthDay(year: 1970, month: 1, day: 15)

        // Act
        cursor.prevMonth()

        // Assert: 하한에 도달하면 day 초기화조차 일어나지 않는다.
        XCTAssertEqual(cursor, YearMonthDay(year: 1970, month: 1, day: 15))
    }
}

final class YearMonthDayDateConversionTests: XCTestCase {

    func test_toDate_returnsMidnightInGivenTimeZone() {
        // Arrange
        let ymd = YearMonthDay(year: 2025, month: 3, day: 26)
        let utc = TimeZone(identifier: "UTC")!

        // Act
        let date = ymd.toDate(utc)

        // Assert
        XCTAssertEqual(date.timeIntervalSince1970, 1_742_947_200, accuracy: 0.001)
    }

    func test_toDate_roundTripsThroughCalendarOfSameTimeZone() {
        // Arrange
        let ymd = YearMonthDay(year: 2025, month: 3, day: 26)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current

        // Act
        let restored = YearMonthDay(ymd.toDate(), calendar: calendar)

        // Assert
        XCTAssertEqual(restored, ymd)
    }
}
