//
//  MainMenuScene.swift
//  Runner
//
//  Created by Muhd Mirza on 17/11/17.
//  Copyright © 2017 muhdmirzamz. All rights reserved.
//

import UIKit
import CoreData
import SpriteKit

class MainMenuScene: SKScene {
	
	var newGameButton: SKSpriteNode?
	var loadGameButton: SKSpriteNode?
	
	override func didMove(to view: SKView) {
		self.backgroundColor = UIColor.blue
		
		let title = SKLabelNode.init(text: "Runner")
		title.position = CGPoint.init(x: self.size.width / 2, y: 250)
		title.fontSize = 50
		self.addChild(title)
		
		self.newGameButton = SKSpriteNode.init(color: UIColor.black, size: CGSize.init(width: 400, height: 50))
		// if you have doubts, position specifies origin point which is center point
		self.newGameButton?.position = CGPoint.init(x: self.size.width / 2, y: 200)
		self.addChild(self.newGameButton!)
		
		let newGameButtonLabel = SKLabelNode.init(text: "New Game")
		newGameButtonLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
		newGameButtonLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
		self.newGameButton?.addChild(newGameButtonLabel)
		
		self.loadGameButton = SKSpriteNode.init(color: UIColor.black, size: CGSize.init(width: 400, height: 50))
		// if you have doubts, position specifies origin point which is center point
		self.loadGameButton?.position = CGPoint.init(x: self.size.width / 2, y: 120)
		self.addChild(self.loadGameButton!)
		
		let loadGameButtonLabel = SKLabelNode.init(text: "Load Game")
		loadGameButtonLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
		loadGameButtonLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
		self.loadGameButton?.addChild(loadGameButtonLabel)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first?.location(in: self) {
			if (self.newGameButton?.contains(touch))! {
				let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
				let fetchReq = NSFetchRequest<Record>.init(entityName: "Record")
				
				do {
					let items = try context.fetch(fetchReq)
					
					for item in items {
						context.delete(item)
					}
					
					do {
						try context.save()
						
						let transition = SKTransition.fade(withDuration: 1)
						let gameScene = GameScene.init(size: self.size)
						
						self.view?.presentScene(gameScene, transition: transition)
					} catch {
						print("Delete failed!")
					}
				} catch {
					print("Fetch failed!")
				}
			}
			
			if (self.loadGameButton?.contains(touch))! {
				let transition = SKTransition.fade(withDuration: 1)
				let gameScene = GameScene.init(size: self.size)
				
				self.view?.presentScene(gameScene, transition: transition)
			}
		}
	}
}
