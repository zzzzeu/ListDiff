#if canImport(UIKit) && !os(watchOS)
import UIKit

public extension UITableView {
    func animateRowChanges<T: Diffable & Equatable, C: BidirectionalCollection>(
        oldData: C,
        newData: C,
        deletionAnimation: RowAnimation = .automatic,
        insertionAnimation: RowAnimation = .automatic,
        section: Int = 0,
        updateData: () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) where C.Element == T {
        apply(
            diffResult: ListDiff.diffing(oldData: oldData, newData: newData),
            deletionAnimation: deletionAnimation,
            insertionAnimation: insertionAnimation,
            section: section,
            updateData: updateData,
            completion: completion
        )
    }
    
    func animateRowChanges<T: Hashable, C: BidirectionalCollection>(
        oldData: C,
        newData: C,
        deletionAnimation: RowAnimation = .automatic,
        insertionAnimation: RowAnimation = .automatic,
        section: Int = 0,
        updateData: () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) where C.Element == T {
        apply(
            diffResult: ListDiff.diffing(oldData: oldData, newData: newData),
            deletionAnimation: deletionAnimation,
            insertionAnimation: insertionAnimation,
            section: section,
            updateData: updateData,
            completion: completion
        )
    }
    
    func apply(
        diffResult: ListDiff.Result,
        deletionAnimation: RowAnimation = .automatic,
        insertionAnimation: RowAnimation = .automatic,
        section: Int = 0,
        updateData: () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        let result = diffResult.forBatchUpdates()
        func update() {
            updateData()
            deleteRows(at: result.deletes.map { IndexPath(row: $0, section: section) } , with: deletionAnimation)
            insertRows(at: result.inserts.map { IndexPath(row: $0, section: section) }, with: insertionAnimation)
            result.moves.forEach { moveRow(at: IndexPath(row: $0.from, section: section), to: IndexPath(row: $0.to, section: section)) }
        }
        if #available(iOS 11.0, *) {
            performBatchUpdates(update, completion: completion)
        } else {
            beginUpdates()
            update()
            endUpdates()
            completion?(true)
        }
    }
    
}

public extension UICollectionView {
    func animateItemChanges<T: Diffable & Equatable, C: BidirectionalCollection>(
        oldData: C,
        newData: C,
        section: Int = 0,
        updateData: () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) where C.Element == T {
        apply(
            diffResult: ListDiff.diffing(oldData: oldData, newData: newData),
            section: section,
            updateData: updateData,
            completion: completion
        )
    }
    
    func animateItemChanges<T: Hashable, C: BidirectionalCollection>(
        oldData: C,
        newData: C,
        section: Int = 0,
        updateData: () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) where C.Element == T {
        apply(
            diffResult: ListDiff.diffing(oldData: oldData, newData: newData),
            section: section,
            updateData: updateData,
            completion: completion
        )
    }
    
    func apply(
        diffResult: ListDiff.Result,
        section: Int = 0,
        updateData: () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        performBatchUpdates({
            updateData()
            let result = diffResult.forBatchUpdates()
            deleteItems(at: result.deletes.map { IndexPath(item: $0, section: section) })
            insertItems(at: result.inserts.map { IndexPath(item: $0, section: section) })
            result.moves.forEach { moveItem(at: IndexPath(item: $0.from, section: section), to: IndexPath(item: $0.to, section: section)) }
        }, completion: completion)
    }
    
}

#endif
