import Foundation
import Combine
import PlaygroundSupport


public func example(of description: String, action: () -> Void) {
      print("\n——— Example of:", description, "———")
        action()
}


//MARK: - Collect
example(of: "collect") {
    let pubilsher = ["A", "B", "C", "D", "E"].publisher
    var subscriptions = [AnyCancellable]()
    
    pubilsher
//        .collect() 🚨limit 이 없이 collect 사용시 unbounded buffer 가 생성되고 이는 completion 이 이루어질 때 까지 메모리를 잡아 먹는다. 따라서 사용에 주의할 것.
        .collect(2) //Buffer 크기에 해당하는 값을 모아 Array 로 만들어 downstream 으로 보냄
        .sink { completion in
        print("Received completion : \(completion)")
    } receiveValue: { value in
        print("Receved Value : \(value)")
    }
    .store(in: &subscriptions)
}


