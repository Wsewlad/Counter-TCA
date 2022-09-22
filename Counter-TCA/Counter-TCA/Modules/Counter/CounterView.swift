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
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { model.decrement() }) {
                    Text("-")
                }
                Text("\(model.count)")
                Button(action: { model.increment() }) {
                    Text("+")
                }
            }
            
            Button(action: { isPrimeModalShown.toggle() }) {
                Text("Is this prime?")
            }
            Button(action: {}) {
                Text("What is the \(model.count.ordinal) prime?")
            }
        }
        .font(.title)
        .navigationTitle("Counter demo")
        .sheet(isPresented: $isPrimeModalShown) {
            IfPrimeModalView()
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView()
    }
}
