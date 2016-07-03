//
//  ViewController.swift
//  Calculator
//
//  Created by Talha Baig on 6/26/16.
//  Copyright © 2016 Talha Baig. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
    }
    
    @IBAction func save() {
        brain.variableValues["M"] = displayValue
        savedProgram = brain.program
    }
    
    
    @IBAction func restore() {
        if savedProgram != nil{
            brain.setOperand("M")
            displayValue = brain.result
        }
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

