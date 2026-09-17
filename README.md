# YearMonthDay

시/분/초 없이 **년·월·일**만 다루는 가벼운 Swift 값 타입입니다.
`Date`는 항상 시각과 타임존을 함께 가지므로 "달력상의 날짜"만 비교하거나 저장할 때 불편합니다.
`YearMonthDay`는 그 부분만 떼어내 `Hashable`, `Comparable`, `CustomStringConvertible`로 제공합니다.

## 설치

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/brownsoo/YearMonthDay.git", from: "1.0.0")
]
```

```swift
.target(name: "MyApp", dependencies: ["YearMonthDay"])
```

Xcode에서는 **File → Add Package Dependencies…** 에 위 URL을 입력하면 됩니다.

## 사용법

### 생성

```swift
let today = YearMonthDay()                              // 현재 날짜 (Calendar.current)
let ymd   = YearMonthDay(year: 2025, month: 3, day: 26)
let fromDate = YearMonthDay(Date())
let fromDateUTC = YearMonthDay(Date(), calendar: utcCalendar)
let fromEpoch = YearMonthDay(time: 1742947200)          // 초 단위 TimeInterval
let fromMillis = 1742947200000.millisecondsToYmd()      // 밀리초 단위 Int
```

### 문자열

```swift
let ymd = YearMonthDay(year: 2025, month: 3, day: 6)

ymd.description             // "2025-3-6"  (패딩 없음)
ymd.identity                // "2025-3-6"
ymd.yyyyMMdd()              // "20250306"  (2자리 패딩)
ymd.yyyyMMdd(joiner: "-")   // "2025-03-06"
ymd.yyyyMMdd(joiner: "/")   // "2025/03/06"
```

> `description`/`identity`는 0 패딩을 하지 않습니다. 정렬 가능한 키나 저장용 문자열이
> 필요하면 `yyyyMMdd(joiner:)`를 사용하세요.

### 비교

```swift
let a = YearMonthDay(year: 2025, month: 3, day: 26)
let b = YearMonthDay(year: 2025, month: 4, day: 1)

a < b                    // true
a.compare(versus: b)     // -1  (작으면 -1, 같으면 0, 크면 1)
a.compareYearMonth(b)    // -1  (년·월만 비교, 차이값을 그대로 반환)
[b, a].sorted()          // [a, b]
```

`compare(versus:)`는 항상 `-1 / 0 / 1`을 반환하지만,
`compareYearMonth(_:)`는 부호만 의미가 있는 **차이값**을 반환합니다(예: 2년 차이면 `2`).

### 월 이동

```swift
var cursor = YearMonthDay(year: 2025, month: 1, day: 15)
cursor.prevMonth()   // 2024-12-15
cursor.nextMonth()   // 2025-01-15
```

`day`는 옮겨진 달의 범위 안에서 유지됩니다. 범위를 넘으면 그 달의 마지막 날로 맞춰집니다.

```swift
var end = YearMonthDay(year: 2025, month: 1, day: 31)
end.nextMonth()      // 2025-02-28  (평년)

var leap = YearMonthDay(year: 2024, month: 1, day: 31)
leap.nextMonth()      // 2024-02-29  (윤년)
```

`prevMonth()`는 1970년 1월 이전으로는 넘어가지 않으며, 하한에 닿으면 값이 그대로 유지됩니다.

### 달력 계산

```swift
YearMonthDay.lastDay(year: 2024, month: 2)   // 29
YearMonthDay.isLeapYear(2100)                // false
YearMonthDay.minimumYear                     // 1970

YearMonthDay(year: 2025, month: 2, day: 30).isValidDate   // false
YearMonthDay(year: 2024, month: 2, day: 29).isValidDate   // true
```

### Date로 변환

```swift
let date = ymd.toDate()                       // 해당 날짜 00:00, TimeZone.current
let utc  = ymd.toDate(TimeZone(identifier: "UTC"))
```

## 주의사항

- 생성 시 달력상 존재하지 않는 날짜(예: 2025-02-30)를 막지 않습니다. 필요하면 `isValidDate`로
  직접 검증하세요.
- `toDate()`는 그런 값도 크래시 없이 처리하지만, 그레고리력 규칙대로 다음 달로 넘겨 보정합니다
  (2025-02-30 → 2025-03-02).
- `toDate()`는 항상 그레고리력으로 계산하므로 기기 로케일 달력의 영향을 받지 않습니다.
- 한 번 잘린 `day`는 되돌아오지 않습니다. 1/31 → 2/28 → 3/28 순서로 이동합니다.
  원래 날짜를 유지해야 하면 커서와 선택 값을 따로 보관하세요.

## 요구 사항

iOS 13+ / macOS 10.15+ / tvOS 13+ / watchOS 6+, Swift 5.9+

## 라이선스

MIT. [LICENSE](LICENSE) 참고.
