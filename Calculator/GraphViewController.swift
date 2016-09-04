//
//  GraphViewController.swift
//  Calculator
//
//  Created by Talha Baig on 7/8/16.
//  Copyright © 2016 Talha Baig. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView! { didSet{
        graphView.addGestureRecognizer(UIPinchGestureRecognizer(target:graphView,
            action: #selector(GraphView.changeScale(_:))))        
        graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView,
            action: #selector(GraphView.pan(_:))))
        graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView,
            action: #selector(GraphView.tap(_:))))
    }}
    
    var graphingFunction: (CGFloat -> CGFloat)?
    var brain: CalculatorBrain? = nil
    var program: CalculatorBrain.PropertyList? = nil
    var equationDescription: String? = nil
    
    override func viewDidLoad() {
        //navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        if brain != nil && program !=  nil {
            //navigationController?.setNavigationBarHidden(false, animated: true)
            navigationItem.title = brain?.returnDescription()
            graphingFunction = { [weak weakSelf = self] in
                weakSelf?.brain!.variableValues["M"] = Double($0)
                weakSelf?.brain!.program = self.program!
                return CGFloat(self.brain!.result)
            }
            graphView.graphingFunction = graphingFunction
        }
    }

    
}
