import Foundation

public protocol Diffable {
    var diffID: AnyHashable { get }
}

public enum ListDiff {
    public struct Result {
        public var inserts = IndexSet()
        public var deletes = IndexSet()
        public var moves = [(from: Int, to: Int)]()
        public var updates = IndexSet()
        public var oldMap = [AnyHashable: Int]()
        public var newMap = [AnyHashable: Int]()
    }
    
    public static func diffing<T: Hashable, C: BidirectionalCollection>(oldData: C, newData: C) -> Result where C.Element == T {
        diffing(oldData: oldData, newData: newData) { $0 }
    }
    
    public static func diffing<T: Diffable & Equatable, C: BidirectionalCollection>(oldData: C, newData: C) -> Result where C.Element == T {
        diffing(oldData: oldData, newData: newData) { $0.diffID }
    }
    
    public static func diffing<T: Equatable, C: BidirectionalCollection>(oldData: C, newData: C, getID: (T) -> AnyHashable) -> Result where C.Element == T {
        // 数据 id 作为 key，entry 作为 value
        var table = [AnyHashable: Entry<C.Index>](minimumCapacity: max(oldData.count, newData.count))
        
        // 第一次遍历
        // 为新数组中的每个元素创建一个 entry
        // 元素每次出现时 newCounter 计数增加，oldIndexes 栈中 push 一个空值
        var newRecords = newData.map { (newRecord) -> Record<C.Index> in
            let key = getID(newRecord)
            if let entry = table[key] {
                entry.push(new: nil)
                return Record(entry)
            } else { //第一次出现的元素
                let entry = Entry<C.Index>()
                entry.push(new: nil)
                table[key] = entry
                return Record(entry)
            }
        }
        
        // 第二次遍历
        // 栈后进先出，倒序遍历旧数组，为旧数组中的每个元素创建一个 entry
        // 元素每次出现时 oldCounter 计数增加，oldIndexes 栈中 push 元素在旧数组中的 index
        var intIndex = oldData.count - 1
        var oldRecords = oldData.indices.reversed().map { i -> Record<C.Index> in
            defer {
                intIndex -= 1
            }
            let oldRecord = oldData[i]
            let key = getID(oldRecord)
            if let entry = table[key] {
                entry.push(old: (i, intIndex))
                return Record(entry)
            } else { //第一次出现的元素
                let entry = Entry<C.Index>()
                entry.push(old: (i, intIndex))
                table[key] = entry
                return Record(entry)
            }
        }
        
        // 第三次遍历
        // 处理在两边数组中都有出现的元素
        var index = newData.startIndex
        for i in newRecords.indices {
            defer {
                index = newData.index(after: index)
            }
            let newRecord = newRecords[i]
            if !newRecord.entry.occurOnBothSides {
                continue
            }
            let entry = newRecord.entry
            //取栈顶的index，如果为空值则表示该元素需要insert
            guard let (oldIndex, intIndex) = entry.oldIndexes.pop() else {
                continue
            }
            // 标记元素是否需要update
            if newData[index] != oldData[oldIndex] {
                entry.updated = true
            }
            // 将新数据的 index 赋值给 oldRecord.index，旧数据的 index 赋值给 newRecord.index
            newRecords[i].index = intIndex
            oldRecords[intIndex].index = i
        }
        
        var result = Result()
        
        // 第四遍遍历
        // 计算删除项的偏移量，记录该位置前的删除操作次数
        // 检查需要删除的元素，index 加入 result
        var runningOffset = 0
        index = oldData.startIndex
        let deleteOffsets = oldRecords.enumerated().map { (i, oldRecord) -> Int in
            let deleteOffset = runningOffset
            // 如果oldRecord中index为nil，则需要删除，offset + 1
            if oldRecord.index == nil {
                result.deletes.insert(i)
                runningOffset += 1
            }
            result.oldMap[getID(oldData[index])] = i
            index = oldData.index(after: index)
            return deleteOffset
        }
        
        // 第五遍遍历
        // 重置插入项的偏移量，计算移动位置
        runningOffset = 0
        index = newData.startIndex
        newRecords.enumerated().forEach { (i, newRecord) in
            let insertOffset = runningOffset
            //newRecord.index有值则表示该元素需要update/move
            if let oldIndex = newRecord.index {
                //检查entry的updated标记
                if newRecord.entry.updated {
                    result.updates.insert(oldIndex)
                }
                
                // 计算偏移量，如果相等则不需要move
                let deleteOffset = deleteOffsets[oldIndex]
                if (oldIndex - deleteOffset + insertOffset) != i {
                    result.moves.append((from: oldIndex, to: i))
                }
            } else {
                // 需要insert的新元素，offset + 1
                result.inserts.insert(i)
                runningOffset += 1
            }
            result.newMap[getID(newData[index])] = i
            index = newData.index(after: index)
        }
        
        return result
    }
    
    struct Stack<Element> {
        var items = [Element]()
        var isEmpty: Bool {
            return self.items.isEmpty
        }
        mutating func push(_ item: Element) {
            items.append(item)
        }
        mutating func pop() -> Element {
            return items.removeLast()
        }
    }
    
    class Entry<Index> {
        // 数据出现在旧数组中的次数
        var oldCounter: Int = 0
        // 数据出现在新数组中的次数
        var newCounter: Int = 0
        // 数据在旧数组中的索引，在新数组中则压入空值
        var oldIndexes = Stack<(Index, Int)?>()
        // 标记需要更新的数据
        var updated: Bool = false
        // 数据是否出现在新旧数组两边
        var occurOnBothSides: Bool {
            return newCounter > 0 && oldCounter > 0
        }
        
        func push(new index: (Index, Int)?) {
            newCounter += 1
            oldIndexes.push(index)
        }
        
        func push(old index: (Index, Int)?) {
            oldCounter += 1
            oldIndexes.push(index)
        }
    }
    
    struct Record<Index> {
        // 每个新旧数据的 index 都对应一个 record
        let entry: Entry<Index>
        // 记录新数据在旧数组中的位置或旧数据在新数组中的位置，不存在则默认为空值
        var index: Int?
        init(_ entry: Entry<Index>) {
            self.entry = entry
        }
    }
}

public extension ListDiff.Result {
    // 使用 UICollectionView 和 UITableView 的 performBatchUpdates
    // 方法进行 move + update 时会导致 crash
    // update 时前后有 insert 或 delete 也容易导致 crash，需要进行操作的转换
    func forBatchUpdates() -> ListDiff.Result {
        var result = self
        result.mutatingForBatchUpdates()
        return result
    }
    
    private mutating func mutatingForBatchUpdates() {
        // 将move + update 转换为 delete + insert
        for (index, move) in moves.enumerated().reversed() {
            if let _ = updates.remove(move.from) {
                moves.remove(at: index)
                deletes.insert(move.from)
                inserts.insert(move.to)
            }
        }
        
        // 将update 转换为 delete + insert
        for (key, oldIndex) in oldMap {
            if updates.contains(oldIndex), let newIndex = newMap[key] {
                deletes.insert(oldIndex)
                inserts.insert(newIndex)
            }
        }
        
        updates.removeAll()
        
    }
}
