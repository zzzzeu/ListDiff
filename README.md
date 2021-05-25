# ListDiff
A lightweight O(n) difference algorithm based on the Paul Heckel's algorithm.
It builds on top of generic BidirectionalCollection, provide friendly support to UIKit based API.

## Getting start
#### Basic usage
```swift
print(ListDiff.diffing(oldData: "laksjdzcxlkawiey", newData: "xclvkbyoieuwyrck"))
```
#### Use with CollectionView / TableView
```swift
collectionView.animateItemChanges(oldData: oldData, newData: newData) {
    dataSource = newData
}
```

## Benchmark
Comparing to Swift's CollectionDifference
|                          |Base algorithm|Order|500 elements|10,000 elements|
|:-------------------------|-------------:|----:|-----------:|--------------:|
|ListDiff                  |Heckel        |O(N) |`0.0037s`   |`0.0736s`      |
|Swift.CollectionDifference|Myers         |O(ND)|`0.0112s`   |`4.7747s`      |

Benchmark could be seen [here](https://github.com/zzzzeu/ListDiff/blob/main/Benchmarks/main.swift).

```
$ swift run -c release ListDiffBenchmark
name                                 time              std        iterations
----------------------------------------------------------------------------
ListDiff 500 elements                   3719045.000 ns ±  11.13 %        377
ListDiff 10,000 elements               73628145.000 ns ±   1.01 %         17
CollectionDifference 500 elements      11225107.000 ns ±   4.66 %        120
CollectionDifference 10,000 elements 4774718233.000 ns ±   0.67 %          2
```

## Install
### Swift Package Manager for Apple platforms
Select Xcode menu `File > Swift Packages > Add Package Dependency` and enter repository URL with GUI.
```
Repository: https://github.com/zzzzeu/ListDiff
```
### Swift Package Manager
Add the following to the dependencies of your `Package.swift`:
```swift
.package(url: "https://github.com/zzzzeu/ListDiff.git", from: "0.0.1")
```
