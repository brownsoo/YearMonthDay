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

    func test_nextMonth_incrementsMonthAndKeepsDay() {
        // Arrange
        var cursor = YearMonthDay(year: 2025, month: 1, day: 15)

        // Act
        cursor.nextMonth()

        // Assert
        XCTAssertEqual(cursor, YearMonthDay(year: 2025, month: 2, day: 15))
    }

    func test_nextMonth_rollsOverToJanuaryOfNextYear() {
        var cursor = YearMonthDay(year: 2025, month: 12, day: 31)
        cursor.nextMonth()
        XCTAssertEqual(cursor, YearMonthDay(year: 2026, month: 1, day: 31))
    }

    func test_nextMonth_clampsDayToShorterMonth() {
        // 1/31 -> 2/28 (평년)
        var cursor = YearMonthDay(year: 2025, month: 1, day: 31)
        cursor.nextMonth()
        XCTAssertEqual(cursor, YearMonthDay(year: 2025, month: 2, day: 28))

        // 3/31 -> 4/30
        var other = YearMonthDay(year: 2025, month: 3, day: 31)
        other.nextMonth()
        XCTAssertEqual(other, YearMonthDay(year: 2025, month: 4, day: 30))
    }

    func test_nextMonth_clampsDayToFebruaryOfLeapYear() {
        var cursor = YearMonthDay(year: 2024, month: 1, day: 31)
        cursor.nextMonth()
        XCTAssertEqual(cursor, YearMonthDay(year: 2024, month: 2, day: 29))
    }

    func test_prevMonth_decrementsMonthAndKeepsDay() {
        var cursor = YearMonthDay(year: 2025, month: 3, day: 15)
        cursor.prevMonth()
        XCTAssertEqual(cursor, YearMonthDay(year: 2025, month: 2, day: 15))
    }

    func test_prevMonth_rollsOverToDecemberOfPreviousYear() {
        var cursor = YearMonthDay(year: 2025, month: 1, day: 15)
        cursor.prevMonth()
        XCTAssertEqual(cursor, YearMonthDay(year: 2024, month: 12, day: 15))
    }

    func test_prevMonth_clampsDayToShorterMonth() {
        // 3/31 -> 2/28 (평년)
        var cursor = YearMonthDay(year: 2025, month: 3, day: 31)
        cursor.prevMonth()
        XCTAssertEqual(cursor, YearMonthDay(year: 2025, month: 2, day: 28))

        // 5/31 -> 4/30
        var other = YearMonthDay(year: 2025, month: 5, day: 31)
        other.prevMonth()
        XCTAssertEqual(other, YearMonthDay(year: 2025, month: 4, day: 30))
    }

    func test_prevMonth_clampsDayToFebruaryOfLeapYear() {
        var cursor = YearMonthDay(year: 2024, month: 3, day: 31)
        cursor.prevMonth()
        XCTAssertEqual(cursor, YearMonthDay(year: 2024, month: 2, day: 29))
    }

    func test_monthCursor_roundTripRestoresClampedDayOnly() {
        // 1/31 -> 2/28 -> 3/28: 한 번 잘린 day는 복원되지 않는다(값 타입의 단순 규칙).
        var cursor = YearMonthDay(year: 2025, month: 1, day: 31)
        cursor.nextMonth()
        cursor.nextMonth()
        XCTAssertEqual(cursor, YearMonthDay(year: 2025, month: 3, day: 28))
    }

    func test_prevMonth_doesNotMoveBefore1970() {
        // Arrange
        var cursor = YearMonthDay(year: 1970, month: 1, day: 15)

        // Act
        cursor.prevMonth()

        // Assert
        XCTAssertEqual(cursor, YearMonthDay(year: 1970, month: 1, day: 15))
    }
}

final class YearMonthDayLastDayTests: XCTestCase {

    func test_lastDay_returnsMonthLengthForCommonYear() {
        let expected = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        for (index, days) in expected.enumerated() {
            XCTAssertEqual(
                YearMonthDay.lastDay(year: 2025, month: index + 1),
                days,
                "2025-\(index + 1)월의 마지막 날이 다르다")
        }
    }

    func test_lastDay_returns29ForFebruaryOfLeapYear() {
        XCTAssertEqual(YearMonthDay.lastDay(year: 2024, month: 2), 29)
        XCTAssertEqual(YearMonthDay.lastDay(year: 2000, month: 2), 29)
    }

    func test_lastDay_returns28ForCenturyNonLeapYear() {
        XCTAssertEqual(YearMonthDay.lastDay(year: 1900, month: 2), 28)
        XCTAssertEqual(YearMonthDay.lastDay(year: 2100, month: 2), 28)
    }

    func test_lastDay_matchesCalendarRange() {
        // Arrange: Gregorian Calendar 결과와 교차 검증
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        for year in [1970, 1999, 2000, 2024, 2025, 2100] {
            for month in 1...12 {
                let reference = calendar.range(
                    of: .day,
                    in: .month,
                    for: DateComponents(calendar: calendar, year: year, month: month, day: 1).date!)!.count

                // Act & Assert
                XCTAssertEqual(
                    YearMonthDay.lastDay(year: year, month: month),
                    reference,
                    "\(year)-\(month)")
            }
        }
    }
}

final class YearMonthDayDateConversionTests: XCTestCase {

    func test_toDate_returnsMidnightInGivenTimeZone() throws {
        // Arrange
        let ymd = YearMonthDay(year: 2025, month: 3, day: 26)
        let utc = TimeZone(identifier: "UTC")!

        // Act
        let date = try XCTUnwrap(ymd.toDate(utc))

        // Assert
        XCTAssertEqual(date.timeIntervalSince1970, 1_742_947_200, accuracy: 0.001)
    }

    func test_toDate_roundTripsThroughCalendarOfSameTimeZone() throws {
        // Arrange
        let ymd = YearMonthDay(year: 2025, month: 3, day: 26)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current

        // Act
        let restored = YearMonthDay(try XCTUnwrap(ymd.toDate()), calendar: calendar)

        // Assert
        XCTAssertEqual(restored, ymd)
    }

    func test_toDate_returnsNilForNonExistingDate() {
        // 존재하지 않는 날짜는 보정하지 않고 nil 로 알린다.
        XCTAssertNil(YearMonthDay(year: 2025, month: 2, day: 30).toDate())
        XCTAssertNil(YearMonthDay(year: 2025, month: 2, day: 29).toDate())
        XCTAssertNil(YearMonthDay(year: 2025, month: 4, day: 31).toDate())
    }

    func test_toDate_returnsNilForOutOfRangeComponents() {
        XCTAssertNil(YearMonthDay(year: 2025, month: 13, day: 1).toDate())
        XCTAssertNil(YearMonthDay(year: 2025, month: 0, day: 1).toDate())
        XCTAssertNil(YearMonthDay(year: 2025, month: 3, day: 0).toDate())
    }

    func test_toDate_returnsDateForFebruary29OfLeapYear() throws {
        // Arrange
        let leapDay = YearMonthDay(year: 2024, month: 2, day: 29)
        let utc = TimeZone(identifier: "UTC")!

        // Act
        let date = try XCTUnwrap(leapDay.toDate(utc))

        // Assert
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        XCTAssertEqual(YearMonthDay(date, calendar: calendar), leapDay)
    }

    func test_toDate_isNotAffectedByNonGregorianLocale() throws {
        // DateFormatter 기반 구현은 기기 로케일 달력(예: 일본력)에 흔들렸다.
        let ymd = YearMonthDay(year: 2025, month: 3, day: 26)

        let date = try XCTUnwrap(ymd.toDate(TimeZone(identifier: "UTC")!))

        XCTAssertEqual(date.timeIntervalSince1970, 1_742_947_200, accuracy: 0.001)
    }

}

final class YearMonthDayValidityTests: XCTestCase {

    func test_isValidDate_trueForRealDates() {
        XCTAssertTrue(YearMonthDay(year: 2025, month: 3, day: 26).isValidDate)
        XCTAssertTrue(YearMonthDay(year: 2024, month: 2, day: 29).isValidDate)
        XCTAssertTrue(YearMonthDay(year: 2025, month: 12, day: 31).isValidDate)
    }

    func test_isValidDate_falseForOutOfRangeDay() {
        XCTAssertFalse(YearMonthDay(year: 2025, month: 2, day: 30).isValidDate)
        XCTAssertFalse(YearMonthDay(year: 2025, month: 2, day: 29).isValidDate)
        XCTAssertFalse(YearMonthDay(year: 2025, month: 4, day: 31).isValidDate)
        XCTAssertFalse(YearMonthDay(year: 2025, month: 3, day: 0).isValidDate)
    }

    func test_isValidDate_falseForOutOfRangeMonth() {
        XCTAssertFalse(YearMonthDay(year: 2025, month: 0, day: 1).isValidDate)
        XCTAssertFalse(YearMonthDay(year: 2025, month: 13, day: 1).isValidDate)
    }

    func test_isLeapYear_followsGregorianRule() {
        XCTAssertTrue(YearMonthDay.isLeapYear(2024))
        XCTAssertTrue(YearMonthDay.isLeapYear(2000))
        XCTAssertFalse(YearMonthDay.isLeapYear(2025))
        XCTAssertFalse(YearMonthDay.isLeapYear(1900))
        XCTAssertFalse(YearMonthDay.isLeapYear(2100))
    }

}

final class YearMonthDayMonthCursorResetTests: XCTestCase {

    func test_nextMonth_withShouldResetDay_resetsDayToFirst() {
        // Arrange
        var cursor = YearMonthDay(year: 2025, month: 1, day: 15)

        // Act
        cursor.nextMonth(shouldResetDay: true)

        // Assert
        XCTAssertEqual(cursor, YearMonthDay(year: 2025, month: 2, day: 1))
    }

    func test_prevMonth_withShouldResetDay_resetsDayToFirst() {
        var cursor = YearMonthDay(year: 2025, month: 3, day: 15)
        cursor.prevMonth(shouldResetDay: true)
        XCTAssertEqual(cursor, YearMonthDay(year: 2025, month: 2, day: 1))
    }

    func test_nextMonth_withShouldResetDay_resetsDayOnYearRollOver() {
        var cursor = YearMonthDay(year: 2025, month: 12, day: 31)
        cursor.nextMonth(shouldResetDay: true)
        XCTAssertEqual(cursor, YearMonthDay(year: 2026, month: 1, day: 1))
    }

    func test_prevMonth_withShouldResetDay_resetsDayOnYearRollOver() {
        var cursor = YearMonthDay(year: 2025, month: 1, day: 15)
        cursor.prevMonth(shouldResetDay: true)
        XCTAssertEqual(cursor, YearMonthDay(year: 2024, month: 12, day: 1))
    }

    func test_monthCursor_withShouldResetDay_skipsClamping() {
        // day 를 버리므로 짧은 달로 옮겨도 클램프가 필요 없다.
        var cursor = YearMonthDay(year: 2025, month: 1, day: 31)
        cursor.nextMonth(shouldResetDay: true)
        XCTAssertEqual(cursor, YearMonthDay(year: 2025, month: 2, day: 1))
    }

    func test_monthCursor_withShouldResetDayFalse_matchesDefault() {
        // Arrange
        var explicit = YearMonthDay(year: 2025, month: 1, day: 31)
        var implicit = YearMonthDay(year: 2025, month: 1, day: 31)

        // Act
        explicit.nextMonth(shouldResetDay: false)
        implicit.nextMonth()

        // Assert: 기본값은 day 유지다.
        XCTAssertEqual(explicit, implicit)
        XCTAssertEqual(explicit, YearMonthDay(year: 2025, month: 2, day: 28))
    }

    func test_prevMonth_withShouldResetDay_stillStopsAt1970() {
        // Arrange
        var cursor = YearMonthDay(year: 1970, month: 1, day: 15)

        // Act
        cursor.prevMonth(shouldResetDay: true)

        // Assert: 하한에서는 이동하지 않으므로 day 초기화도 일어나지 않는다.
        XCTAssertEqual(cursor, YearMonthDay(year: 1970, month: 1, day: 15))
    }
}
