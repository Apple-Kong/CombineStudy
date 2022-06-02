import Foundation
import Combine

var greeting = "Hello, playground"

public func example(of description: String, action: () -> Void) {
      print("\n——— Example of:", description, "———")
        action()
}

//MARK: - Publisher

example(of: "Publisher") {
    // 1
    let myNotification = Notification.Name("MyNotification")
    // 2
    let publisher = NotificationCenter.default
        .publisher(for: myNotification, object: nil)
    
    // 3
    let center = NotificationCenter.default
    // 4
    let observer = center.addObserver(
        forName: myNotification,
        object: nil,
        queue: nil) { notification in
            print("Notification received!")
        }
    // 5
    center.post(name: myNotification, object: nil) // noti 발행
    // 6
    center.removeObserver(observer) // 옵저버 등록 해제
}

//MARK: - Subscriber


example(of: "Just") {
    let just = Just("Hello world!")
    
    _ = just.sink(receiveCompletion: {
        print("Received completion", $0)
    }, receiveValue: {
        
        print("Received Value", $0)
    })
}


example(of: "assign") {
    class SomeObject {
        var value: String = "" {
            didSet {
                print("Value changed: \(value)")
            }
        }
    }
    
    let object = SomeObject()
    let publisher = ["Hello", "World"].publisher
    _ = publisher.assign(to: \.value, on: object)
}





example(of: "Custom Subscriber") {
    let publisher = (1...6).publisher //Publisher 는 6개의 값을 발행함
    
    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(3)) //최대 3개의 값을 원한다.
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received Value", input)
            return .none //받고자 하는 값의 수를 조절하지 않겠다 라는 뜻 즉 demand 를 수정하지 않겠다
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received Completion", completion)
        }
    }
    
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
}
