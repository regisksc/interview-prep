import Foundation

struct DayForecast: Identifiable {
    let id: UUID
    var dayName: String
    var date: Date
    var temperature: Int
    var high: Int
    var low: Int
    var condition: Condition
    var humidity: Int
    var windSpeed: Double
    var uvIndex: Int

    init(
        id: UUID = UUID(),
        dayName: String,
        date: Date,
        temperature: Int,
        high: Int,
        low: Int,
        condition: Condition,
        humidity: Int,
        windSpeed: Double,
        uvIndex: Int
    ) {
        self.id = id
        self.dayName = dayName
        self.date = date
        self.temperature = temperature
        self.high = high
        self.low = low
        self.condition = condition
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.uvIndex = uvIndex
    }

    enum Condition: String, CaseIterable, Identifiable {
        case sunny, partlyCloudy, cloudy, rainy, stormy, snowy

        var id: String { rawValue }

        var label: String {
            switch self {
            case .partlyCloudy: "Partly Cloudy"
            default: rawValue.capitalized
            }
        }

        var sfSymbolName: String {
            switch self {
            case .sunny: "sun.max.fill"
            case .partlyCloudy: "cloud.sun.fill"
            case .cloudy: "cloud.fill"
            case .rainy: "cloud.rain.fill"
            case .stormy: "cloud.bolt.rain.fill"
            case .snowy: "cloud.snow.fill"
            }
        }
    }
}

extension DayForecast {
    private static func date(daysFromNow offset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: .now) ?? .now
    }

    static let samples: [DayForecast] = [
        DayForecast(
            dayName: "Monday", date: date(daysFromNow: 0),
            temperature: 68, high: 72, low: 58,
            condition: .sunny, humidity: 45, windSpeed: 8.5, uvIndex: 7
        ),
        DayForecast(
            dayName: "Tuesday", date: date(daysFromNow: 1),
            temperature: 65, high: 70, low: 56,
            condition: .partlyCloudy, humidity: 55, windSpeed: 12.0, uvIndex: 5
        ),
        DayForecast(
            dayName: "Wednesday", date: date(daysFromNow: 2),
            temperature: 61, high: 66, low: 54,
            condition: .cloudy, humidity: 65, windSpeed: 15.3, uvIndex: 3
        ),
        DayForecast(
            dayName: "Thursday", date: date(daysFromNow: 3),
            temperature: 58, high: 62, low: 52,
            condition: .rainy, humidity: 80, windSpeed: 18.7, uvIndex: 2
        ),
        DayForecast(
            dayName: "Friday", date: date(daysFromNow: 4),
            temperature: 55, high: 59, low: 50,
            condition: .stormy, humidity: 88, windSpeed: 25.0, uvIndex: 1
        ),
        DayForecast(
            dayName: "Saturday", date: date(daysFromNow: 5),
            temperature: 63, high: 68, low: 55,
            condition: .partlyCloudy, humidity: 50, windSpeed: 10.2, uvIndex: 6
        ),
        DayForecast(
            dayName: "Sunday", date: date(daysFromNow: 6),
            temperature: 70, high: 74, low: 60,
            condition: .sunny, humidity: 40, windSpeed: 7.0, uvIndex: 8
        ),
    ]
}
