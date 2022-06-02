import Foundation
import Combine
import PlaygroundSupport


public func example(of description: String, action: () -> Void) {
      print("\n——— Example of:", description, "———")
        action()
}

//MARK: - Future (Publisher)
// 비동기적으로 하나의 결과물을 발행하고 completion 발행하는 데 사용 가능.
PlaygroundPage.current.needsIndefiniteExecution = true

example(of: "Future") {
    func futureIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int,Never> {
        Future<Int, Never> { promise in


            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                promise(.success(integer + 1))
            }
        }
    }

    let future = futureIncrement(integer: 1, afterDelay: 3)

    var subscriptions = Set<AnyCancellable>()

    future.sink {
        print($0)
    } receiveValue: {
        print($0)
    }
    .store(in: &subscriptions)

}


//MARK: - Subject (Publisher)

example(of: "PaththroughSubject") {
    
    // 1. 커스텀 에러 타입 정의
    enum MyError: Error {
        case test
    }
    
    // 2. 커스텀 subscriber 구현
    final class StringSubscriber: Subscriber {
        typealias Input = String
        typealias Failure = MyError // 커스텀 에러 타입을 Subscriber 의 Failure 타입으로 사용
        
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: String) -> Subscribers.Demand {
            print("Received Value : \(input)")
            return input == "World" ? .max(1) : .none
        }
        
        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received completion : \(completion)")
        }
    }
    
    let subscriber = StringSubscriber()
    let subject = PassthroughSubject<String, MyError>()
    subject.subscribe(subscriber)
    
    let subscription = subject.sink { completion in
        print("Received Completion : from sink - ", completion)
    } receiveValue: { value in
        print("Received Value : \(value) - From Sink")
    }
    
    //직접 Publisher 에 값을 발행시켜줄 수 있다.
    subject.send("Hello")
    subject.send("World")
    
//    subscription.cancel()
    subject.send("Any body there?")
    
    subject.send(completion: .finished)
//    subject.send(completion: .failure(.test))
    subject.send("How about another one?")
    
    //하나의 Publisher 에 여러개의 Subscriber 를 달 수 있다.
    //하나의 subscription 을 취소하려면 해당 subscription 의 .cancel() 메서드를 활용하면된다.
    //Subject Publisher 와 연결된 모든 subscription 을 종료하고자 한다면, completion 을 send 하면된다.
    //completion 에는 에러도 전달이 가능하다.
    
    //결론 : PassThroughSubject 는 명령형 코드 -> 선언형 코드 로의 연결의 하나의 방식이다
}

//MARK: - CurrentValueSubject

example(of: "CurrentValueSubject") {
    let subject = CurrentValueSubject<Int, Never>(0)
    var subscriptions = [AnyCancellable]()
    subject
        .print()
        .sink { completion in
        print("Received completion", completion)
    } receiveValue: { value in
        print(value)
    }
    .store(in: &subscriptions)
    
    subject.send(1)
    //아래처럼 값을 세팅하기만 해도, 값이 자동 발행됨.
    subject.value = 2
    subject.value = 3
    print("print current value \(subject.value)")
    //즉 값을 할당하는 코드로 -> 자동으로 선언형 프로그래밍으로 전환가능.
    
    
    //새롭게 subscriber 를 연결
    subject
//        .print()
        .sink(receiveValue: { print("Second Subscription : \($0)")})
        .store(in: &subscriptions)
    
    //연결과 동시에 현재 값만 한번 발행함.
    
    
    
//    subject.value = .finished 🚨 -> 이코드는 에러 발생!!
    
    
    //🌟 해당 scope 를 빠져나가면서 subscriptions 에 저장되어 있는 구독들이 자동 취소된다!!
    
    //아래 코드 처럼 completion 을 보내주면 cancel 안되고 completion 됨 -> cancel 따로 또 해줄 필요는 없다.
    subject.send(completion: .finished) // 이 코드로 구독을 종료 시켜야함.
}

