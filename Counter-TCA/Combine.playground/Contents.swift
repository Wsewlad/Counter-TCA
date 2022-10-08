
public struct Effect<A> {
    public let run: (@escaping (A) -> Void) -> Void
    
    public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
        return Effect<B> { callback in self.run { a in callback(f(a)) } }
    }
}

import Dispatch

let anIntInTwoSeconds = Effect<Int> { callback in
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        callback(42)
        callback(1729)
    }
}

anIntInTwoSeconds.run { print($0) }
//
//anIntInTwoSeconds.map { $0 * $0 }.run { print($0) }

import Combine

var count = 0
let iterator = AnyIterator<Int>.init {
    count += 1
    return count
}
Array(iterator.prefix(10))

                // Lazy
let aFutureInt = Deferred {
    // Eager
    Future<Int, Never> { callback in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Hello from the future")
            callback(.success(42))
            callback(.success(1729))
        }
    }
}

//aFutureInt.subscribe(
//    AnySubscriber<Int, Never>.init(
//        receiveSubscription: { subscription in
//            print("subscription")
//            subscription.cancel()
//            subscription.request(.unlimited)
//        },
//        receiveValue: { value in
//            print("value: ", value)
//            return .unlimited
//        },
//        receiveCompletion: { completion in
//            print("completion", completion)
//        }
//    )
//)

let cancellable = aFutureInt.sink { int in
    print(int)
}
//cancellable.cancel()

//Subject.init

let passthrough = PassthroughSubject<Int, Never>()
let currentValue = CurrentValueSubject<Int, Never>.init(2)

let c1 = passthrough.sink { int in
    print("passthrough", int)
}

let c2 = currentValue.sink { int in
    print("currentValue", int)
}

passthrough.send(42)
currentValue.send(1729)
passthrough.send(42)
currentValue.send(1729)
