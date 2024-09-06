import SpriteKit

class MainMenuScene: SKScene {
    private var playButton: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        setupPlayButton()
    }
    
    private func setupPlayButton() {
        playButton = SKSpriteNode(color: SKColor.lightGray, size: CGSize(width: 150, height: 50))
        playButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        playButton.zPosition = 1
        let playLabel = SKLabelNode(text: "Play")
        playLabel.fontSize = 25
        playLabel.fontColor = SKColor.black
        playLabel.position = CGPoint(x: 0, y: -10)
        playButton.addChild(playLabel)
        self.addChild(playButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if playButton.contains(touchLocation) {
            if let view = self.view {
                if let scene = SKScene(fileNamed: "GameScene") {
                    scene.scaleMode = .aspectFill
                    view.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
                }
            }
        }
    }
}
