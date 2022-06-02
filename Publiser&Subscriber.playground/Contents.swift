import Foundation
import Combine
import PlaygroundSupport


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
            //출력물을 보면 competion 이벤트를 받지 못한걸 볼 수 있다. 이는 Publisher 가 completion 을 발행하기 전에 subscriber 가 구독을 중지하기 때문이다.
        }
    }
    
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
}

example(of: "Custom Subscriber  .none -> .max(1)") {
    let publisher = (1...6).publisher
    
    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(3))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received Value", input)
            return .max(1) //값을 받아 올때마다, demand 값을 1씩 증가시킨다. 따라서 모든 발행 값을 받아오게 되고
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received Completion", completion)
            //completion 또한 받아온다.
        }
    }
    
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
}

example(of: "Custom Subscriber String") {
    let publisher = ["A", "B", "C", "D", "E", "F", "G", "H"].publisher
    
    final class IntSubscriber: Subscriber {
     
        
        typealias Input = String //Publisher 가 발행하는 타입과 Subscriber 가 받아들이는 타입은 동일해야함.
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(3))
        }
        
        func receive(_ input: String) -> Subscribers.Demand {
            print("Received Value", input)
            return .max(1) //값을 받아 올때마다, demand 값을 1씩 증가시킨다. 따라서 모든 발행 값을 받아오게 되고
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received Completion", completion)
            //completion 또한 받아온다.
        }
    }
    
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
}
