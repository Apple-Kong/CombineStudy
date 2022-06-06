import Foundation
import Combine
import PlaygroundSupport


public func example(of description: String, action: () -> Void) {
      print("\n——— Example of:", description, "———")
        action()
}

//MARK: - filter
example(of: "filter") {
    let numbers = (1...10).publisher
    var subscriptions = [AnyCancellable]()
    
    numbers
        .filter { $0.isMultiple(of: 3) }
        .sink { number in
            print("\(number) 는 3의 배수입니다.")
        }
        .store(in: &subscriptions)
}

//MARK: - removeDuplicates
example(of: "remove duplicates") {
    var subscriptions = [AnyCancellable]()
    
    let words = "어이 어이 거기! 앞은 좀 좀 보고 다니라고~"
        .components(separatedBy: " ")
        .publisher
    
    words
        .removeDuplicates()
        .sink(receiveValue: { print($0)})
        .store(in: &subscriptions)
}

//MARK: - compactMap
example(of: "compact mapping") {
    
}
