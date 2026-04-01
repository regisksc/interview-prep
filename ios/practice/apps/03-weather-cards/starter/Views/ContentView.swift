import SwiftUI

struct ContentView: View {
    let forecast = DayForecast.samples

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("San Francisco")
                .font(.largeTitle.bold())

            ForEach(forecast) { day in
                HStack {
                    Text(day.dayName)
                    Spacer()
                    Text("\(day.temperature)°")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView()
}
