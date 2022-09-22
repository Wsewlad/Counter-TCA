//
//  IfPrimeModalView.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 23.09.2022.
//

import SwiftUI

struct IfPrimeModalView: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            Text(title)
            if model.count.isPrime {
                Button(action: { model.toggleFavorites() }) {
                    Text(actionTitle)
                }
            }
        }
    }
}

//MARK: - Computed Properties
private extension IfPrimeModalView {
    var title: String {
        model.count.isPrime ? "\(model.count) is prime 🎉" : "\(model.count) is not prime :("
    }
    
    var actionTitle: String {
        model.isInFavorites ? "Remove from favorite primes" : "Save to favorite primes"
    }
}

struct IfPrimeModalView_Previews: PreviewProvider {
    static var previews: some View {
        IfPrimeModalView()
    }
}
