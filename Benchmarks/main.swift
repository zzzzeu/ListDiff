import Benchmark
import ListDiff

let random500FromData = Array(repeating: Int.random(in: 0..<500), count: 500)
let random500ToData = Array(repeating: Int.random(in: 0..<500), count: 500)
let random10_000FromData = Array(repeating: Int.random(in: 0..<10_000), count: 10_000)
let random10_000ToData = Array(repeating: Int.random(in: 0..<10_000), count: 10_000)

benchmark("ListDiff 500 elements") {
    _ = ListDiff.diffing(oldData: random500FromData, newData: random500ToData)
}

benchmark("ListDiff 10,000 elements") {
    _ = ListDiff.diffing(oldData: random10_000FromData, newData: random10_000ToData)
}

if #available(macOS 10.15, *) {
    benchmark("CollectionDifference 500 elements") {
        _ = random500ToData.difference(from: random500FromData).inferringMoves()
    }

    benchmark("CollectionDifference 10,000 elements") {
        _ = random10_000ToData.difference(from: random10_000FromData).inferringMoves()
    }
}

Benchmark.main()
