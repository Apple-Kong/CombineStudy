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


//MARK: - map
example(of: "map") {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    var subscriptions = [AnyCancellable]()
    
    [123, 4, 56].publisher
        .map {
            formatter.string(for: NSNumber(integerLiteral: $0)) ?? ""
        }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

public struct Coordinate {
  public let x: Int
  public let y: Int
  
  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }
}

public func quadrantOf(x: Int, y: Int) -> String {
  var quadrant = ""
  
  switch (x, y) {
  case (1..., 1...):
    quadrant = "1"
  case (..<0, 1...):
    quadrant = "2"
  case (..<0, ..<0):
    quadrant = "3"
  case (1..., ..<0):
    quadrant = "4"
  default:
    quadrant = "boundary"
  }
  
  return quadrant
}

example(of: "mapping ket paths") {
    let publisher = PassthroughSubject<Coordinate, Never>()
    var subscriptions = [AnyCancellable]()
    
    publisher
        .map(\.x, \.y)
        .sink { x, y in
            print("좌표 (\(x), \(y)) 는 \(quadrantOf(x: x, y: y)) 사분면 위에 있습니다.")
        }
        .store(in: &subscriptions)
    
    publisher.send(Coordinate(x: 10, y: -8))
    publisher.send(Coordinate(x: 0, y: 5))
}


