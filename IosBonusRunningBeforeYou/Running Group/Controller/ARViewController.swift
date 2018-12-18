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

class ARViewController: UIViewController,ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    var kiloMeter = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        var locationmanager = CLLocationManager()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        if kiloMeter == 0 {
            let scene = SCNScene(named: "art.scnassets/flag1.obj")!  //Pepijn Rijnders
            sceneView.scene = scene
        } else {
            let scene = SCNScene(named: "art.scnassets/model.obj")!  //Pepijn Rijnders
            sceneView.scene = scene
        }
        
        // Set The scene to the view
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
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

}
