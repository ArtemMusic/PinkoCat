import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var birdNode: SKSpriteNode!
    var isMovingRight: Bool = true
    var poisonCookie: SKSpriteNode!
    var food: SKSpriteNode!
    var bottomBorder: SKNode!
    
    // Константы
    private let birdCategory: UInt32 = 1
    private let wallCategory: UInt32 = 2
    private let poisonCookieCategory: UInt32 = 3
    private let foodCategory: UInt32 = 5
    private let bottomBorderCategory: UInt32 = 4
    private let bounceStrength: CGFloat = 500
    private let borderHeight: CGFloat = 20
    
    // Меню рестарта
    private var gameOverLabel: SKLabelNode!
    private var restartButton: SKSpriteNode!
    private var menuButton: SKSpriteNode!
    private var isGameOver: Bool = false  // Отслеживание состояния игры
    
    // Счетчик очков
    private var scoreLabel: SKLabelNode!
    private var score: Int = 0
    
    override func didMove(to view: SKView) {
        setupBirdNode()
        setupPoisonCookie()
        setupFood()
        setupBottomBorder()
        setupPhysics()
        relocatePoisonCookie()
        relocateFood()
        setupGameOverMenu()
        hideGameOverMenu()
        setupScoreLabel()
    }
    
    private func setupBirdNode() {
        birdNode = SKSpriteNode(imageNamed: "bird")  // Ensure the image is correctly set
        birdNode.name = "bird"
        birdNode.size = CGSize(width: 70, height: 70)  // Set appropriate size
        birdNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)  // Initial position
        birdNode.zPosition = 1
        birdNode.physicsBody = SKPhysicsBody(circleOfRadius: birdNode.size.width / 2)
        birdNode.physicsBody?.isDynamic = true
        birdNode.physicsBody?.affectedByGravity = true
        birdNode.physicsBody?.restitution = 0.5  // Adjust restitution for bounce effect
        birdNode.physicsBody?.friction = 0.0
        birdNode.physicsBody?.linearDamping = 0.0  // No linear damping for proper bouncing
        birdNode.physicsBody?.angularDamping = 0.0  // No angular damping
        birdNode.physicsBody?.allowsRotation = true
        birdNode.physicsBody?.velocity = CGVector(dx: 0, dy: -250)
        birdNode.physicsBody?.categoryBitMask = birdCategory
        birdNode.physicsBody?.contactTestBitMask = wallCategory | poisonCookieCategory | bottomBorderCategory
        birdNode.physicsBody?.collisionBitMask = wallCategory
        self.addChild(birdNode)
    }
    
    private func setupPoisonCookie() {
        poisonCookie = SKSpriteNode(imageNamed: "poisonCookie")
        poisonCookie.name = "poisonCookie"
        poisonCookie.size = CGSize(width: 70, height: 115)
        poisonCookie.zPosition = 1
        poisonCookie.physicsBody = SKPhysicsBody(circleOfRadius: poisonCookie.size.width / 2)
        poisonCookie.physicsBody?.isDynamic = false
        poisonCookie.physicsBody?.categoryBitMask = poisonCookieCategory
        poisonCookie.physicsBody?.contactTestBitMask = birdCategory
        poisonCookie.physicsBody?.collisionBitMask = 0
        self.addChild(poisonCookie)
    }
    
    private func setupFood() {
        food = SKSpriteNode(imageNamed: "food")
        food.name = "food"
        food.size = CGSize(width: 70, height: 70)
        food.zPosition = 1
        food.physicsBody = SKPhysicsBody(circleOfRadius: food.size.width / 2)
        food.physicsBody?.isDynamic = false
        food.physicsBody?.categoryBitMask = foodCategory
        food.physicsBody?.contactTestBitMask = birdCategory
        food.physicsBody?.collisionBitMask = 0
        self.addChild(food)
    }
    
    private func setupBottomBorder() {
        bottomBorder = SKNode()
        bottomBorder.position = CGPoint(x: self.frame.midX, y: self.frame.minY + borderHeight / 2)
        let borderPhysicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: borderHeight))
        borderPhysicsBody.isDynamic = false
        borderPhysicsBody.categoryBitMask = bottomBorderCategory
        borderPhysicsBody.contactTestBitMask = birdCategory
        borderPhysicsBody.collisionBitMask = 0
        bottomBorder.physicsBody = borderPhysicsBody
        self.addChild(bottomBorder)
    }
    
    private func setupPhysics() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = wallCategory
        self.physicsBody?.contactTestBitMask = birdCategory
        self.physicsBody?.collisionBitMask = birdCategory
        physicsWorld.contactDelegate = self
    }
    
    private func setupGameOverMenu() {
        // Настройка надписи "Проиграл"
        gameOverLabel = SKLabelNode(text: "Try again")
        gameOverLabel.fontSize = 45
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
        gameOverLabel.zPosition = 2
        self.addChild(gameOverLabel)
        gameOverLabel.isHidden = true
        
        // Настройка кнопки "Рестарт"
        restartButton = SKSpriteNode(color: SKColor.lightGray, size: CGSize(width: 150, height: 50))
        restartButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 50)
        restartButton.zPosition = 2
        let restartLabel = SKLabelNode(text: "Restart")
        restartLabel.fontSize = 25
        restartLabel.fontColor = SKColor.black
        restartLabel.position = CGPoint(x: 0, y: -10)
        restartButton.addChild(restartLabel)
        self.addChild(restartButton)
        restartButton.isHidden = true
        
        // Настройка кнопки "Меню"
        menuButton = SKSpriteNode(color: SKColor.lightGray, size: CGSize(width: 150, height: 50))
        menuButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 120)
        menuButton.zPosition = 2
        let menuLabel = SKLabelNode(text: "Menu")
        menuLabel.fontSize = 25
        menuLabel.fontColor = SKColor.black
        menuLabel.position = CGPoint(x: 0, y: -10)
        menuButton.addChild(menuLabel)
        self.addChild(menuButton)
        menuButton.isHidden = true
    }
    
    private func hideGameOverMenu() {
        gameOverLabel.isHidden = true
        restartButton.isHidden = true
        menuButton.isHidden = true
    }
    
    private func showGameOverMenu() {
        gameOverLabel.isHidden = false
        restartButton.isHidden = false
        menuButton.isHidden = false
    }
    
    private func setupScoreLabel() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = SKColor.white
        // Position the label at the bottom center of the screen
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 30)  // Adjust the y-coordinate as needed
        scoreLabel.zPosition = 2
        self.addChild(scoreLabel)
    }
    
    private func updateScore() {
        score += 1
        scoreLabel.text = "Score: \(score)"
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if isGameOver {
            if restartButton.contains(touchLocation) {
                restartGame()
            } else if menuButton.contains(touchLocation) {
                goToMainMenu()
            }
        } else {
            let sideImpulse: CGFloat = isMovingRight ? 200 : -200
            birdNode.physicsBody?.velocity = CGVector(dx: sideImpulse, dy: 500)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if isCollisionBetween(firstBody: firstBody, secondBody: secondBody, category1: birdCategory, category2: wallCategory) {
            handleWallCollision()
        }
        
        if isCollisionBetween(firstBody: firstBody, secondBody: secondBody, category1: birdCategory, category2: poisonCookieCategory) {
            endGame()
        }
        
        if isCollisionBetween(firstBody: firstBody, secondBody: secondBody, category1: birdCategory, category2: foodCategory) {
            updateScore()  // Increase score when food is collected
            relocateFood() // Move food to a new position
        }
        
        if isCollisionBetween(firstBody: firstBody, secondBody: secondBody, category1: birdCategory, category2: bottomBorderCategory) {
            endGame()
        }
    }
    
    private func isCollisionBetween(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody, category1: UInt32, category2: UInt32) -> Bool {
        return (firstBody.categoryBitMask == category1 && secondBody.categoryBitMask == category2) ||
        (firstBody.categoryBitMask == category2 && secondBody.categoryBitMask == category1)
    }
    
    private func handleWallCollision() {
        isMovingRight.toggle()
        let newXVelocity = isMovingRight ? bounceStrength : -bounceStrength
        birdNode.physicsBody?.velocity = CGVector(dx: newXVelocity, dy: birdNode.physicsBody!.velocity.dy)
        relocatePoisonCookie()
    }
    
    private func relocatePoisonCookie() {
        relocateSprite(poisonCookie)
    }
    
    private func relocateFood() {
        relocateSprite(food)
    }
    
    private func relocateSprite(_ sprite: SKSpriteNode) {
        let previousPhysicsBody = sprite.physicsBody
        sprite.physicsBody = nil
        let maxX = self.frame.maxX - sprite.size.width / 2
        let maxY = self.frame.maxY - sprite.size.height / 2
        let minX = self.frame.minX + sprite.size.width / 2
        let minY = self.frame.minY + sprite.size.height / 2
        let randomX = CGFloat.random(in: minX...maxX)
        let randomY = CGFloat.random(in: minY...maxY)
        sprite.position = CGPoint(x: randomX, y: randomY)
        sprite.physicsBody = previousPhysicsBody
    }
    
    private func endGame() {
        showGameOverMenu()
        birdNode.isHidden = true
        poisonCookie.isHidden = true
        food.isHidden = true
        bottomBorder.isHidden = true
        isGameOver = true  // Устанавливаем состояние игры как завершенное
    }
    
    private func restartGame() {
        // Сбросить состояние игры
        birdNode.isHidden = false
        poisonCookie.isHidden = false
        food.isHidden = false
        bottomBorder.isHidden = false
        
        // Переместить объекты в начальные позиции
        birdNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        birdNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        isMovingRight = true
        
        relocatePoisonCookie()
        relocateFood()
        
        // Сбросить счет
        score = 0
        scoreLabel.text = "Score: \(score)"
        
        // Скрыть меню
        hideGameOverMenu()
        isGameOver = false  // Сброс состояния игры
    }
    
    private func goToMainMenu() {
        // Ensure we are transitioning to the MainMenuScene
        if let view = self.view {
            let mainMenuScene = MainMenuScene(size: self.size)
            mainMenuScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view.presentScene(mainMenuScene, transition: transition)
        }
    }
}
