//
//  ARViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Janhon on 2018/12/17.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import AVFoundation


class ARViewController: UIViewController,ARSCNViewDelegate {

    @IBOutlet weak var copyRightField: UILabel!
    @IBOutlet weak var musicCopyRightField: UILabel!
    
    @IBOutlet weak var sceneView: ARSCNView!
    var kiloMeter = Double()
    var audioPlayer : AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var locationmanager = CLLocationManager()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        if kiloMeter >= 3000 {
            let scene = SCNScene(named: "art.scnassets/model.obj")!  //Pepijn Rijnders
            sceneView.scene = scene
            copyRightField.text = "© Pepijn Rijnders"
            musicCopyRightField.text = "© K'NAAN - Wavin' Flag"
            
            copyRightField.clipsToBounds = true
            copyRightField.layer.cornerRadius = 3
            musicCopyRightField.clipsToBounds = true
            musicCopyRightField.layer.cornerRadius = 3
    
            playSound(soundFileName: "My audio2")
            
        } else {
            let scene = SCNScene(named: "art.scnassets/flag1.obj")!  //Pepijn Rijnders
            sceneView.scene = scene
            copyRightField.text = "© Benjamin Farrell"
            musicCopyRightField.text = "© K'NAAN - Wavin' Flag"
            
            copyRightField.clipsToBounds = true
            copyRightField.layer.cornerRadius = 3
            musicCopyRightField.clipsToBounds = true
            musicCopyRightField.layer.cornerRadius = 3
            
            playSound(soundFileName: "My Audio")
            
        }
        
        
        // Set The scene to the view
        sceneView.autoenablesDefaultLighting = true
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        print("Session is supported = \(ARConfiguration.isSupported)")
        print("World Tracking is supported = \(ARWorldTrackingConfiguration.isSupported)")
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if !results.isEmpty {
                print("touched the plane")
            } else {
                print("touched somewhere else")
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        if anchor is ARPlaneAnchor{

            let planeAnchor = anchor as! ARPlaneAnchor
            
//            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))

            let planeNode = SCNNode()

            planeNode.position = SCNVector3(x: planeAnchor.center.x, y:0, z: planeAnchor.center.z)

            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)

//            let gridmaterial = SCNMaterial()

//            gridmaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")

//            plane.materials = [gridmaterial]

//            planeNode.geometry = plane

            node.addChildNode(planeNode)

        } else {
            return
        }

    }
    
    func playSound(soundFileName : String) {
        let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: "wav")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
        }
        catch  {
            print(error)
        }
        audioPlayer.play()
    }

}
