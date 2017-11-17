//
//  GameViewController.swift
//  Runner
//
//  Created by Muhd Mirza on 4/9/17.
//  Copyright © 2017 muhdmirzamz. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainMenuScene = MainMenuScene.init(size: self.view.frame.size)
		mainMenuScene.scaleMode = .resizeFill
		
		let skView = self.view as! SKView
		skView.ignoresSiblingOrder = true

		skView.presentScene(mainMenuScene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
