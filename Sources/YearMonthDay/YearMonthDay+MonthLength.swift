//
//  YearMonthDay+MonthLength.swift
//  YearMonthDay
//
//  그레고리력 기준 월 길이/윤년 계산.
//

import Foundation

extension YearMonthDay {

    /// 이 타입이 다루는 가장 이른 연도. `prevMonth()` 의 하한이다.
    public static let minimumYear = 1970

    /// 평년의 월별 마지막 날 (1월 → 31).
    private static let lastDaysOfCommonYear = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    /// 그레고리력에서 윤년인지 여부.
    public static func isLeapYear(_ year: Int) -> Bool {
        if year % 400 == 0 { return true }
        if year % 100 == 0 { return false }
        return year % 4 == 0
    }

    /// 해당 년월의 마지막 날.
    /// - Parameter month: 1...12. 범위를 벗어나면 가장 가까운 유효 월로 간주한다.
    public static func lastDay(year: Int, month: Int) -> Int {
        let normalizedMonth = min(max(month, 1), 12)
        if normalizedMonth == 2 && isLeapYear(year) {
            return 29
        }
        return lastDaysOfCommonYear[normalizedMonth - 1]
    }

    /// 그레고리력에 실제로 존재하는 날짜인지 여부. (예: 2025-02-30 은 `false`)
    public var isValidDate: Bool {
        guard (1...12).contains(month) else { return false }
        return (1...YearMonthDay.lastDay(year: year, month: month)).contains(day)
    }
}
