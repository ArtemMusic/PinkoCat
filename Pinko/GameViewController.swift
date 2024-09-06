import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            let mainMenuScene = MainMenuScene(size: view.bounds.size)
            mainMenuScene.scaleMode = .aspectFill
            view.presentScene(mainMenuScene)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
