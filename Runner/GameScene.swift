//
//  GameScene.swift
//  Runner
//
//  Created by Muhd Mirza on 4/9/17.
//  Copyright © 2017 muhdmirzamz. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

	let backgroundImage = SKSpriteNode.init(imageNamed: "building")
	let backgroundImage2 = SKSpriteNode.init(imageNamed: "building")
	
	let player = SKSpriteNode.init(imageNamed: "player")
	
	var score = 0
	var scoreLabel: SKLabelNode? = nil
	
	// a way to access the block to test if block has passed player
	var shapeArr = [SKShapeNode]()
	
	// interesting to note:
	// https://stackoverflow.com/questions/21505660/physics-bodies-not-responding-to-bitmask-settings#comment60916704_21508132
	// do not compare 0 or UInt32.max
	// it ain't gonna work
	struct Collision {
		let Border: UInt32 = 1
		let Player: UInt32 = 2
		let Block: UInt32 = 3
	}
	
    override func didMove(to view: SKView) {
		self.physicsWorld.contactDelegate = self
		self.physicsWorld.gravity = .zero
		
		self.physicsBody = SKPhysicsBody.init(edgeLoopFrom: self.frame)
		self.physicsBody?.categoryBitMask = Collision().Border
		self.physicsBody?.collisionBitMask = Collision().Player
		
		self.scoreLabel = SKLabelNode.init(text: "Score: \(score)")
		self.scoreLabel?.fontColor = UIColor.red
		self.scoreLabel?.position = CGPoint.init(x: self.size.width - 200, y: 10)
		self.scoreLabel?.zPosition = 3
		self.addChild(self.scoreLabel!)
	
//		self.backgroundImage.size = CGSize.init(width: self.size.width, height: self.size.height)
//		self.backgroundImage.position = CGPoint.init(x: self.size.width / 2, y: self.size.height / 2)
//		self.addChild(self.backgroundImage)
//		
//		self.backgroundImage2.size = CGSize.init(width: self.size.width, height: self.size.height)
//		self.backgroundImage2.position = CGPoint.init(x: (self.size.width / 2) + self.size.width , y: self.size.height / 2)
//		self.addChild(self.backgroundImage2)
	
		self.player.position = CGPoint.init(x: 50, y: 50)
		self.player.size = CGSize.init(width: 100, height: 100)
//		self.player.zPosition = 3
		
		self.addChild(self.player)
		
		self.player.physicsBody = SKPhysicsBody.init(rectangleOf: self.player.size)
		self.player.physicsBody?.categoryBitMask = Collision().Player
		self.player.physicsBody?.collisionBitMask = Collision().Border
//		self.player.physicsBody?.contactTestBitMask = Collision().Block
		
//		let actionBlock = SKAction.run { 
//			self.spawnBlock()
//		}
//		
//		let wait = SKAction.wait(forDuration: 4)
//		let sequence = SKAction.sequence([actionBlock, wait])
//		let forever = SKAction.repeatForever(sequence)
//		
//		run(forever)
    }
	
	func spawnBlock() {
		let block = SKShapeNode.init(rectOf: CGSize.init(width: 100, height: 100))
		
		let n = arc4random_uniform(UInt32(2))
		print("Rand number: \(n)")
		
		var spawnHeight: CGFloat = 0
		
		if n == 0 {
			spawnHeight = 100 / 2
		} else if n == 1 {
			spawnHeight = self.size.height - (100 / 2)
		}
		
		
		block.position = CGPoint.init(x: self.size.width, y: spawnHeight)
		block.fillColor = UIColor.green
		block.zPosition = 3
		
		self.addChild(block)
		self.shapeArr.append(block)
		
		block.physicsBody = SKPhysicsBody.init(rectangleOf: block.frame.size)
		block.physicsBody?.categoryBitMask = Collision().Block
		block.physicsBody?.contactTestBitMask = Collision().Player
		
		let action = SKAction.move(to: CGPoint.init(x: -100, y: block.position.y), duration: 3)
		let remove = SKAction.removeFromParent()
		let removeFromArray = SKAction.run {
			self.shapeArr.remove(at: self.shapeArr.startIndex)
		}

		let sequence = SKAction.sequence([action, remove, removeFromArray])
		
		block.run(sequence)
	}
	
	public func didBegin(_ contact: SKPhysicsContact) {
		if (contact.bodyA.categoryBitMask == Collision().Player && contact.bodyB.categoryBitMask == Collision().Block) || (contact.bodyA.categoryBitMask == Collision().Block && contact.bodyB.categoryBitMask == Collision().Player) {
			let remove = SKAction.removeFromParent()
		
			contact.bodyA.node?.run(remove)
			contact.bodyB.node?.run(remove)
			
			self.shapeArr.remove(at: self.shapeArr.startIndex)
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touchLocation = touches.first?.location(in: self)

		let moveAction = SKAction.moveTo(y: (touchLocation?.y)!, duration: 1)
		
		self.player.run(moveAction)
	}
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
		
//		self.backgroundImage.position.x -= 1
//		self.backgroundImage2.position.x -= 1
//		
//		if self.backgroundImage.position.x + self.backgroundImage.size.width <= (self.size.width / 2) {
//			self.backgroundImage.position.x = self.size.width / 2
//			self.backgroundImage2.position.x = (self.size.width / 2) + self.size.width
//		}
		
		if let firstShape = self.shapeArr.first {
			// okay so you have to round the coords up to an int for it to detect an equality in value
			// cgfloats just dont do the trick
			
			if Int(firstShape.position.x) == Int((self.player.position.x + (self.player.size.width / 2))) {
				self.score += 1
				
				self.scoreLabel?.text = "Score: \(score)"
			}
		}
    }
}
