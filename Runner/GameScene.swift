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
	
	var topCollisionBlock: SKShapeNode?
	var bottomCollisionBlock: SKShapeNode?
	
	// interesting to note:
	// https://stackoverflow.com/questions/21505660/physics-bodies-not-responding-to-bitmask-settings#comment60916704_21508132
	// do not use 0 or UInt32.max
	// comparing with 0's will give a zero value
	// only non-zero values cause collision
	struct Collision {
		let Border: UInt32 = 1
		let Player: UInt32 = 2
		let Block: UInt32 = 3
		let TopBlock: UInt32 = 4
		let BottomBlock: UInt32 = 5
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
	
		self.backgroundImage.size = CGSize.init(width: self.size.width, height: self.size.height)
		self.backgroundImage.position = CGPoint.init(x: self.size.width / 2, y: self.size.height / 2)
		self.addChild(self.backgroundImage)
		
		self.backgroundImage2.size = CGSize.init(width: self.size.width, height: self.size.height)
		self.backgroundImage2.position = CGPoint.init(x: (self.size.width / 2) + self.size.width , y: self.size.height / 2)
		self.addChild(self.backgroundImage2)
	
		self.player.position = CGPoint.init(x: 50, y: 50)
		self.player.size = CGSize.init(width: 100, height: 100)
		self.player.zPosition = 3
		
		self.addChild(self.player)
		
		self.player.physicsBody = SKPhysicsBody.init(rectangleOf: self.player.size)
		self.player.physicsBody?.categoryBitMask = Collision().Player
		self.player.physicsBody?.contactTestBitMask = Collision().Block
		self.player.physicsBody?.collisionBitMask = Collision().Border
		
		let actionBlock = SKAction.run { 
			self.spawnBlock()
		}
		
		let wait = SKAction.wait(forDuration: 4)
		let sequence = SKAction.sequence([actionBlock, wait])
		let forever = SKAction.repeatForever(sequence)
		
		run(forever)
		
		// same size as blocks
		self.topCollisionBlock = SKShapeNode.init(rectOf: CGSize.init(width: 50, height: 50))
		self.topCollisionBlock?.isHidden = true
		self.topCollisionBlock?.fillColor = UIColor.red
		// point of origin is center
		self.topCollisionBlock?.position = CGPoint.init(x: 25, y: self.size.height - 25)
		self.topCollisionBlock?.zPosition = 3
		self.addChild(self.topCollisionBlock!)
		
		self.topCollisionBlock?.physicsBody = SKPhysicsBody.init(rectangleOf: (self.topCollisionBlock?.frame.size)!)
		self.topCollisionBlock?.physicsBody?.categoryBitMask = Collision().TopBlock
		self.topCollisionBlock?.physicsBody?.collisionBitMask = 0
		self.topCollisionBlock?.physicsBody?.contactTestBitMask = Collision().Block
		
//		self.bottomCollisionBlock = SKShapeNode.init(rectOf: CGSize.init(width: 50, height: 50))
//		self.bottomCollisionBlock?.isHidden = true
//		self.bottomCollisionBlock?.fillColor = UIColor.red
//		self.bottomCollisionBlock?.position = CGPoint.init(x: self.player.position.x - 20, y: 25)
//		self.bottomCollisionBlock?.zPosition = 3
//		self.addChild(self.bottomCollisionBlock!)
		
//		self.bottomCollisionBlock?.physicsBody = SKPhysicsBody.init(rectangleOf: (self.bottomCollisionBlock?.frame.size)!)
//		self.bottomCollisionBlock?.physicsBody?.categoryBitMask = Collision().BottomBlock
//		self.bottomCollisionBlock?.physicsBody?.contactTestBitMask = Collision().Block
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
		block.physicsBody?.contactTestBitMask = Collision().Player | Collision().TopBlock | Collision().BottomBlock
		block.physicsBody?.isDynamic = false
		
		let action = SKAction.move(to: CGPoint.init(x: -100, y: block.position.y), duration: 3)
		let remove = SKAction.removeFromParent()
		let removeFromArray = SKAction.run {
			self.shapeArr.remove(at: self.shapeArr.startIndex)
		}

		let sequence = SKAction.sequence([action, remove, removeFromArray])
		
		block.run(sequence)
	}
	
	public func didBegin(_ contact: SKPhysicsContact) {
		// player and block
		if (contact.bodyA.categoryBitMask == Collision().Player && contact.bodyB.categoryBitMask == Collision().Block) || (contact.bodyA.categoryBitMask == Collision().Block && contact.bodyB.categoryBitMask == Collision().Player) {
			let remove = SKAction.removeFromParent()
		
			contact.bodyA.node?.run(remove)
			contact.bodyB.node?.run(remove)
			
			self.shapeArr.remove(at: self.shapeArr.startIndex)
		}
		
		if (contact.bodyA.categoryBitMask == Collision().TopBlock && contact.bodyB.categoryBitMask == Collision().Block) || (contact.bodyA.categoryBitMask == Collision().Block && contact.bodyB.categoryBitMask == Collision().TopBlock) {
			self.score += 1
			self.scoreLabel?.text = "Score: \(score)"
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touchLocation = touches.first?.location(in: self)

		let moveAction = SKAction.moveTo(y: (touchLocation?.y)!, duration: 1)
		
		self.player.run(moveAction)
	}
	
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
		
		self.backgroundImage.position.x -= 1
		self.backgroundImage2.position.x -= 1
		
		if self.backgroundImage.position.x + self.backgroundImage.size.width <= (self.size.width / 2) {
			self.backgroundImage.position.x = self.size.width / 2
			self.backgroundImage2.position.x = (self.size.width / 2) + self.size.width
		}
    }
}
