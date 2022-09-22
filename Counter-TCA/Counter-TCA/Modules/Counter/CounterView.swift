//
//  CounterView.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import SwiftUI

struct CounterView: View {
    @EnvironmentObject var model: Model
    
    @State private var isPrimeModalShown: Bool = false
    @State private var alertNthPrimePresented: Bool = false
    @State private var alertNthPrime: Int?  = nil
    
    var body: some View {
        VStack {
            stepperView
                .alert(
                    "",
                    isPresented: $alertNthPrimePresented,
                    presenting: alertNthPrime,
                    actions: { _ in Button("OK", action: {}) },
                    message: { n in Text("The \(model.count.ordinal) prime is \(n)") }
                )
                .onChange(of: alertNthPrimePresented) { newValue in
                    if !newValue {
                        alertNthPrime = nil
                    }
                }
            
            buttonsView
        }
        .font(.title)
        .navigationTitle("Counter demo")
        .sheet(isPresented: $isPrimeModalShown) {
            IfPrimeModalView()
        }
    }
}

//MARK: - Stepper View
private extension CounterView {
    var stepperView: some View {
        HStack {
            Button(action: { model.decrement() }) {
                Text("-")
            }
            
            Text("\(model.count)")
            
            Button(action: { model.increment() }) {
                Text("+")
            }
        }
    }
}

//MARK: - Buttons View
private extension CounterView {
    var buttonsView: some View {
        VStack {
            Button(action: { isPrimeModalShown.toggle() }) {
                Text("Is this prime?")
            }
            
            Button(action: {
                model.nthPrime {
                    self.alertNthPrime = $0
                    alertNthPrimePresented = true
                }
            }) {
                Text("What is the \(model.count.ordinal) prime?")
            }
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView()
    }
}
