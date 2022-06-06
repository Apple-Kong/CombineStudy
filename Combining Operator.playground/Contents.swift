import Foundation
import Combine
import PlaygroundSupport


public func example(of description: String, action: () -> Void) {
      print("\n——— Example of:", description, "———")
        action()
}

//MARK: - Prepending : 앞부분에 값 끼워넣기
example(of: "prepend") {
    let publisher = [7,8].publisher
    var subscriptions = [AnyCancellable]()
    
    publisher
        .prepend(5,6)
        .prepend([3,4]) // Sequence 도 prepend 가능
        .prepend(Set(1...2)) // set 은 순서가 보장되지 않는다
        .sink { value in
            print(value)
        }
        .store(in: &subscriptions)
}

example(of: "prepend with another publisher") {
    let publisher1 = [3,4].publisher
    let publisher2 = [1,2].publisher // 다른 Publisher 도 앞부분에 끼워넣을 수 있다. 단 이경우 finite 해야한다.
    _ = publisher1
        .prepend(publisher2)
        .sink(receiveValue: {print($0)})
        
}

example(of: "prepend with anoter publisher infinite") {
    let publisher1 = [3,4].publisher
    let publisher2 = PassthroughSubject<Int,Never>()
    _ = publisher1
        .prepend(publisher2)
        .sink(receiveCompletion: { completion in
            print(completion)
        }, receiveValue: { value in
            print(value)
        })
        
    publisher2.send(1)
    publisher2.send(2)
    publisher2.send(completion: .finished) // 반드시 complete 되는 맥락에 대한 정보를 제공해주어야. Combine 이 끝을 추론해서 뒤에 발행되는 값을 배치한다.
}


