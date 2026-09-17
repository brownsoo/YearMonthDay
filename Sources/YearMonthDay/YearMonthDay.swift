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
    
    public mutating func prevMonth() {
        let m = month - 1
        if m < 1 {
            if year - 1 < 1970 {
                return
            }
            self.year = year - 1
            self.month = 12
        } else {
            self.month = m
        }
        // FIXME: 해당 월의 범위 안에서 day 값 유지 하기
        self.day = 1
    }
    
    public mutating func nextMonth() {
        let m = month + 1
        if m > 12 {
            self.year = year + 1
            self.month = 1
        } else {
            self.month = m
        }
        // FIXME: 해당 월의 범위 안에서 day 값 유지 하기
        self.day = 1
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
    
    public func toDate(_ timeZone: TimeZone? = nil) -> Date {
        let form = DateFormatter()
        form.dateFormat = "yyyy-MM-dd"
        form.timeZone = timeZone ?? TimeZone.current
        return form.date(from: yyyyMMdd(joiner: "-"))!
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
