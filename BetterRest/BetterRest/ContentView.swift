//
//  ContentView.swift
//  BetterRest
//
//  Created by Julia Martcenko on 23/01/2025.
//

import SwiftUI
import CoreML

struct ContentView: View {
	@State private var wakeUp = defaultWakeTime
	@State private var sleepAmount = 8.0
	@State private var coffeeAmount = 1

	@State private var alertTitle = ""
	@State private var alertMessage = ""
	@State private var showingAlert = false

//	@State private var bedtime = defaultWakeTime

	var bedtime: Date {
		do {
			let config = MLModelConfiguration()
			let model = try SleepCalculator(configuration: config)

			let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
			let hour = (components.hour ?? 0) * 60 * 60
			let minute = (components.minute ?? 0) * 60

			let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

			let sleepTime = wakeUp - prediction.actualSleep

			//			alertTitle = "Your ideal bedtime is…"
//			bedtime = sleepTime
			return sleepTime
		} catch {
			alertTitle = "Error"
			alertMessage = "Sorry, there was a problem calculating your bedtime."
			showingAlert = true
			return Date.now
		}
	}

	static var defaultWakeTime: Date {
		var components = DateComponents()
		components.hour = 7
		components.minute = 0
		return Calendar.current.date(from: components) ?? .now
	}

    var body: some View {
		NavigationStack {
			Form {
				Section("When do you want to wake up?") {
					DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
				}
				Section("Desired amount of sleep") {
					Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
				}
				Section("Daily coffee intake") {
					Picker("", selection: $coffeeAmount) {
						ForEach(1..<10) {
							Text("^[\($0) cup](inflect: true)")
						}
					}
				}
				Section("Your ideal bedtime is…") {
					Text("\(bedtime.formatted(date: .omitted, time: .shortened))")
				}
			}
			.navigationTitle("BetterRest")
//			.toolbar {
//				Button("Calculate", action: calculateBedtime)
//			}
//			.onAppear() {
//				calculateBedtime()
//			}
//			.onChange(of: wakeUp) { _ in calculateBedtime() }
//			.onChange(of: sleepAmount) { _ in calculateBedtime() }
//			.onChange(of: coffeeAmount) { _ in calculateBedtime() }
			.alert(alertTitle, isPresented: $showingAlert) {
				Button ("OK") {
					showingAlert = false
				}
			} message: {
				Text(alertMessage)
			}
		}
    }

//	func calculateBedtime() {
//		do {
//			let config = MLModelConfiguration()
//			let model = try SleepCalculator(configuration: config)
//
//			let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
//			let hour = (components.hour ?? 0) * 60 * 60
//			let minute = (components.minute ?? 0) * 60
//
//			let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
//
//			let sleepTime = wakeUp - prediction.actualSleep
//
////			alertTitle = "Your ideal bedtime is…"
////			bedtime = sleepTime
//		} catch {
//			alertTitle = "Error"
//			alertMessage = "Sorry, there was a problem calculating your bedtime."
//			showingAlert = true
//		}
////		showingAlert = true
//	}

}

#Preview {
    ContentView()
}
