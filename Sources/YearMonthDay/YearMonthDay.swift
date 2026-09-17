//
//  YearMonthDay.swift
//  YearMonthDay
//
//  Created by 브라운수 on 3/26/25.
//


import Foundation

/// 년월일 다루는 모델
public struct YearMonthDay : Hashable {
    
    public var year: Int
    public var month: Int
    public var day: Int
    
    /// init with now date
    public init() {
        self.init(Date())
    }
    
    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
    
    public init(time: TimeInterval) {
        self.init(Date(timeIntervalSince1970: time))
    }
    
    /// init with date
    public init(_ date: Date, calendar: Calendar = Calendar.current) {
        let set: Set<Calendar.Component> = [.year, .month, .day]
        let comps = calendar.dateComponents(set, from: date)
        self = YearMonthDay(
            year: comps.year!,
            month: comps.month!,
            day: comps.day!)
    }
    
    public var identity: String {
        return "\(year)-\(month)-\(day)"
    }
    
    /// 이전 달로 옮긴다. day 는 옮겨진 달의 범위 안에서 유지된다.
    /// 1970년 1월 이전으로는 넘어가지 않으며, 그 경우 값은 그대로 유지된다.
    public mutating func prevMonth() {
        guard let moved = movingMonth(by: -1) else { return }
        self = moved
    }

    /// 다음 달로 옮긴다. day 는 옮겨진 달의 범위 안에서 유지된다.
    public mutating func nextMonth() {
        guard let moved = movingMonth(by: 1) else { return }
        self = moved
    }

    /// 년월을 `offset` 개월만큼 옮긴 값을 만든다.
    /// day 는 최대한 유지하되 옮겨진 달의 마지막 날을 넘으면 그 날로 맞춘다(1/31 → 2/28).
    /// 1970년 1월보다 앞이면 `nil` 을 돌려준다.
    private func movingMonth(by offset: Int) -> YearMonthDay? {
        // 0-based 월 통산값으로 바꿔 계산하면 연도 이월을 따로 처리할 필요가 없다.
        let totalMonths = year * 12 + (month - 1) + offset
        let movedYear = totalMonths / 12
        let movedMonth = totalMonths % 12 + 1

        if movedYear < YearMonthDay.minimumYear {
            return nil
        }
        return YearMonthDay(
            year: movedYear,
            month: movedMonth,
            day: min(day, YearMonthDay.lastDay(year: movedYear, month: movedMonth)))
    }

    /// 다른 날짜의 년월만 비교
    /// 작으면 음수, 크면 양수, 같으면 0
    public func compareYearMonth(_ other: YearMonthDay) -> Int {
        if self.year == other.year {
            return self.month - other.month
        }
        return self.year - other.year
    }
    
    
    
    public var yearString: String {
        return String(year)
    }
    public var monthString: String {
        return String(month)
    }
    public var dayString: String {
        return String(day)
    }
}

extension YearMonthDay: CustomStringConvertible {
    public var description: String {
        return "\(year)-\(month)-\(day)"
    }
}

fileprivate extension Int {
    var twoDigitString: String {
        if self > -10 && self < 0 {
            return "-0\(abs(self))"
        } else if self < 10 {
            return "0\(self)"
        } else {
            return "\(self)"
        }
    }
}

extension YearMonthDay {
    
    public func yyyyMMdd(joiner: String = "") -> String {
        return [yearString,
                month.twoDigitString,
                day.twoDigitString].joined(separator:joiner)
    }
    
    public func compare(versus: YearMonthDay) -> Int {
        if year > versus.year {
            return 1
        } else if year < versus.year {
            return -1
        }
        if month > versus.month {
            return 1
        } else if month < versus.month {
            return -1
        }
        if day > versus.day {
            return 1
        } else if day < versus.day {
            return -1
        } else {
            return 0
        }
    }
    
    /// 해당 날짜 자정의 `Date`.
    /// - Parameter timeZone: 기준 타임존. 생략하면 `TimeZone.current`.
    /// - Note: 존재하지 않는 날짜(2025-02-30)는 그레고리력 규칙대로 다음 달로 넘겨 보정한다.
    ///   엄격하게 걸러야 하면 호출 전에 `isValidDate` 를 확인할 것.
    public func toDate(_ timeZone: TimeZone? = nil) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone ?? TimeZone.current
        let components = DateComponents(year: year, month: month, day: day)
        // Calendar 는 범위를 넘는 day 를 다음 달로 넘겨 보정한다.
        // 그래도 만들 수 없는 값이면 같은 달 1일로 떨어뜨려 강제 언래핑 크래시를 피한다.
        return calendar.date(from: components)
            ?? calendar.date(from: DateComponents(year: year, month: month, day: 1))
            ?? Date(timeIntervalSince1970: 0)
    }
}

extension YearMonthDay: Comparable {
    static public func <(lhs: YearMonthDay, rhs: YearMonthDay) -> Bool {
        return lhs.compare(versus: rhs) < 0
    }
    static public func >(lhs: YearMonthDay, rhs: YearMonthDay) -> Bool {
        return lhs.compare(versus: rhs) > 0
    }
    static public func ==(lhs: YearMonthDay, rhs: YearMonthDay) -> Bool {
        return lhs.compare(versus: rhs) == 0
    }
    static public func >=(lhs: YearMonthDay, rhs: YearMonthDay) -> Bool {
        let val = lhs.compare(versus: rhs)
        return val > 0 || val == 0
    }
    static public func <=(lhs: YearMonthDay, rhs: YearMonthDay) -> Bool {
        let val = lhs.compare(versus: rhs)
        return val < 0 || val == 0
    }
}

extension Int {
    /// 본 값을 밀리세컨드로 가정하여 년월일을 구한다.
    public func millisecondsToYmd() -> YearMonthDay {
        let interval =  Double(self) / 1000.0
        return YearMonthDay(time: interval)
    }
}
