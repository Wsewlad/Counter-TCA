
import Foundation
import ComposableArchitecture

let store = Store<Int,()>(state: 0, reducer: { count, _ in count += 1 })

store.send(())
store.send(())
store.send(())
store.send(())
store.send(())

store.state

let newStore = store.view { $0 }

newStore.state

newStore.send(())
newStore.send(())
newStore.send(())
newStore.send(())
newStore.send(())

newStore.state

store.state

store.send(())
store.send(())

store.state
newStore.state

