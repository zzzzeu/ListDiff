import UIKit
import ListDiff

class ViewController: UIViewController {
    
    var emojis = String.randomEmojis
    
    @IBOutlet weak var emojisCollectionView: UICollectionView! {
        didSet {
            emojisCollectionView.dataSource = self
        }
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        let newEmojis = String.randomEmojis
        emojisCollectionView.animateItemChanges(oldData: emojis, newData: newEmojis) {
            emojis = newEmojis
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emojisCollectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        if let emojiCell = cell as? EmojiCollectionViewCell {
            emojiCell.label.text = emojis[indexPath.item]
        }
        return cell
    }
}

extension String {
    static var randomEmojis: ArraySlice<String> {
        let emojis = "ðūðŧððĪðĪðĶðģðĄð­ðððâïļðĨĨðŊðĨðžðđðŪðļðŧðĨð§ðĢðĶðšðļððĨðð§ðĄð§ð°ðžððâĪïļððķðððđð°ðĪŊðððĪðŊðķðĪ§ðŋðĶð·ð°ðŧââïļðŧð―ðððŠķðžâïļððð§ððĶðĐð§ðĪâðīðð ððŧðâĐðŪðð"
            .map { String($0) }
            .shuffled()
        let randomCount = Int.random(in: 20..<emojis.count)
        return emojis[0..<randomCount]
    }
}

