//
//  ViewController.swift
//  Calculator
//
//  Created by Talha Baig on 6/26/16.
//  Copyright © 2016 Talha Baig. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate {
    
    @IBOutlet weak private var display: UILabel!
    @IBOutlet weak var descriptionOfOperandsAndOperations: UILabel!
    private var userIsInTheMiddleOfTyping = false;
    private var decimalIsPressed = false;
    private var brain = CalculatorBrain();
    private var savedProgram: CalculatorBrain.PropertyList?
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue);
        }
    }
    override func viewDidLoad() {
        descriptionOfOperandsAndOperations.text = ""
        splitViewController?.delegate =  self
        navigationItem.title = "Calculator"
    }
    
    /* Calls private function below to display a digit on display
    */
    @IBAction private func digitIsPressed(sender: UIButton) {
        decimalOrDigitPressed(sender)
    }
    
    /* Calls the private function below except makes sure that
        the decimal is only pressed once by using decimalIsPressed
     */
    @IBAction private func decimalPressed(sender: UIButton) {
        if decimalIsPressed {
            return
        }
        decimalIsPressed = true;
        decimalOrDigitPressed(sender)
        
    }
    
    /* Special condition where clear is pressed. Resets all values and
    instatiates a new brain to "forget" everything before
    */
    @IBAction private func clearPressed(sender: UIButton) {
        displayValue = 0;
        decimalIsPressed = false
        userIsInTheMiddleOfTyping = false
        descriptionOfOperandsAndOperations.text = ""
        brain.clear()
    }
    
    
    /* Is called when an operation is pressed including "="
        if userIsInTheMiddleOfTyping then the controller will send to
        the brain the operand already on the screen. The brain will then
        perform the operation and display it
     */
    @IBAction private func operationPerformed(sender: UIButton) {
        decimalIsPressed = false
        if userIsInTheMiddleOfTyping{
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false;
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            descriptionOfOperandsAndOperations.text = brain.returnDescription()
        }
        displayValue = brain.result
        savedProgram = brain.program
    }
    
    @IBAction func undo() {
        if userIsInTheMiddleOfTyping {
            if display.text?.characters.count == 2{
                userIsInTheMiddleOfTyping = false
            }
            display.text =
                display.text?.substringToIndex((display.text?.endIndex.predecessor())!)
        }
        else{
            brain.undo()
            displayValue = brain.result
            descriptionOfOperandsAndOperations.text = brain.returnDescription()
        }
    }
    
    @IBAction func save() {
        if savedProgram != nil {
            brain.variableValues["M"] = displayValue
            userIsInTheMiddleOfTyping = false
            brain.program = savedProgram!
            displayValue = brain.result
            descriptionOfOperandsAndOperations.text = brain.returnDescription()
        }
    }
    
    
    @IBAction func restore() {
        brain.setOperand("M")
        //savedProgram = brain.program
        displayValue = brain.result
        //descriptionOfOperandsAndOperations.text = brain.returnDescription()
    }
    
    /* Performs segue by pressing the button and if it is not a partial result
     */
    
    @IBAction func goToGraph() {
        if !brain.isPartialResult{
            performSegueWithIdentifier("Graph Segue", sender: nil)
        }
    }
    
    
    /* Sends the brain and the program over
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let graphvc = segue.destinationViewController.contentViewController as? GraphViewController {
            graphvc.brain = brain
            graphvc.program = savedProgram
            
        }
    }
    
    
    /* So the splitView will collapse the detail onto the master in the beginning also why SplitviewControllerDelegate is implemented
     and why view did load has myself as a delegate
     */
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        if let graphvc = secondaryViewController.contentViewController as? GraphViewController {
            if graphvc.graphingFunction == nil {
                return true
            }
        }
        return false
    }
    
    /* This is the function which places a digit or decimal
        on the display. If userInTheMiddleOfTyping then add
        it on. If not then its the first digit and replace the
        zero with the digit
    */
    private func decimalOrDigitPressed(sender: UIButton){
        if userIsInTheMiddleOfTyping {
            display.text = display.text! + sender.currentTitle!
            
        }
        else{
            display.text = sender.currentTitle!
            userIsInTheMiddleOfTyping = true;
        }
    }
}



/* An extension that will return the top view controller of a navigation controller or itself
 */
extension UIViewController {
    var contentViewController: UIViewController {
        get{
            var contentvc = self
            if let navcon  = self as? UINavigationController{
                contentvc = navcon.topViewController ?? self
            }
            return contentvc
        }
    }
}

