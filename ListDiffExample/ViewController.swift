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
        let emojis = "👾👻🎃🤕🐤🦄🐳🐡🍭🎀😈🐙☄️🥥🍯🥃🎼🎹🎮🎸🎻🥁🐧🐣🦀🌺🌸🍞🍥🍙🧁🍡🍧🍰🍼🎁🎏❤️💚🎶💊🏂🛹🌰🤯😇🙃🤓😯😶🤧👿🦁🐷🐰🐻‍❄️🐻🐽🐏🐑🪶🌼☃️🌊🍌🧀🍘🍦🍩🧊🎤♟🛴🏝🎠🌋🗻🏕⛩🔮🛁🎐"
            .map { String($0) }
            .shuffled()
        let randomCount = Int.random(in: 20..<emojis.count)
        return emojis[0..<randomCount]
    }
}

