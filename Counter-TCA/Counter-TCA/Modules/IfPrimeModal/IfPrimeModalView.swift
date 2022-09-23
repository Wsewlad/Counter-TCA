//
//  IfPrimeModalView.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 23.09.2022.
//

import SwiftUI

struct IfPrimeModalView: View {
    @EnvironmentObject var store: Store<AppState>
    
    var body: some View {
        VStack {
            Text(title)
            if self.store.state.count.isPrime {
                Button(action: { toggleFavorites() }) {
                    Text(actionTitle)
                }
            }
        }
    }
}

//MARK: - Actions
private extension IfPrimeModalView {
    func toggleFavorites() {
        self.store.state.toggleFavorites()
    }
}

//MARK: - Computed Properties
private extension IfPrimeModalView {
    var title: String {
        self.store.state.count.isPrime ? "\(self.store.state.count) is prime 🎉" : "\(self.store.state.count) is not prime :("
    }
    
    var actionTitle: String {
        self.store.state.isInFavorites ? "Remove from favorite primes" : "Save to favorite primes"
    }
}

struct IfPrimeModalView_Previews: PreviewProvider {
    static var previews: some View {
        IfPrimeModalView()
    }
}
