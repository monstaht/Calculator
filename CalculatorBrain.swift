//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Talha Baig on 6/27/16.
//  Copyright © 2016 Talha Baig. All rights reserved.
//

import Foundation


class CalculatorBrain{
    
    private var accumulator = 0.0
    private var description = "" //string which holds all the operations and operands done
    private var pending: PendingBinaryOperationInfo? //Holds information for a pending Binary Operation
    private var internalProgram = [AnyObject]() //Holds the stored variable as a number not a string
    typealias PropertyList = AnyObject
    private var internalVariable = ""
    private var operandTypedIn = false //lets the brain know if an operand was typed in
    
    

    /* computed variable which looks at if a pending binary operation exists then partialResult will
     be true
     */
    private var isPartialResult: Bool{
        get{
            if pending != nil{
                return true
            }
            else{
                return false
            }
        }
    }
    
    /* all the stuff that has happened in the program 
     */
    var program: PropertyList {
        get{
            return internalProgram
        }
        set{
            clear()
            if let arrayOfOps = newValue as? [AnyObject]{
                for op in arrayOfOps{
                    if let operand = op as? Double {
                        setOperand(operand)
                    }
                    if let operation = op as? String{
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    /* clears the calculator
     */
    func clear(){
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        description = ""
        variableValues.removeAll()
    }
    
    /* sets the operand to the accumulator
     */
    func setOperand(operand: Double){
        accumulator = operand
        internalProgram.append(operand)
        addOperandToDescription(String(operand))
        operandTypedIn =  true
    }
    
    /* Sets a variable value to the most recent accumulator value NOT DONE
     */
    func setOperand(variableName: String){
        if let operand = variableValues[variableName]{
            accumulator = operand
            internalProgram.append(operand)
        }

    }
    
    /* public variable to get accumulator since we dont want it to be set
    */
    var result: Double {
        get{
            return accumulator
        }
        
    }
    
    /* gives back the description based on value of isPartialResult
     */
    func returnDescription() -> String{
        if isPartialResult {
            return description + "..."
        }
        else{
            return description + "="
        }
    }
    
    
    /* Performs the operation based on which type of opeartion it is and also appends items to description
     */
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol]{
            switch operation {
            case .Constant(let value):
                addOperationToDescription(symbol, closure: {
                    self.description += $0
                    self.operandTypedIn = true
                })
                accumulator = value
            case .UnaryOperator(let function):
                addOperationToDescription(symbol, closure: {self.descriptionForUnaryOperation($0)})
                accumulator = function(accumulator)
            case .BinaryOperator(let function):
                addOperationToDescription(symbol, closure: {
                    self.description += $0
                    self.operandTypedIn = false
                })
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                addOperationToDescription(symbol, closure: { (whatever) in
                  self.descriptionForEqualsOperation()
                })
                executePendingBinaryOperation()

            }
        }
    }
    
    /* a dictionary that mathces a variable with a Double
     */
    var variableValues: [String: Double] = [:]
    
    /* adds an operand to the description
     */
    private func addOperandToDescription(operand: String) -> String {
        var returningOperand = operand
        //if this string is double with .0 just display an int
        if let double  = Double(operand) {
            if double % 1 == 0 {
                returningOperand =  (String(Int(double)))
            }
        }
        if isPartialResult{
            description += returningOperand
        }
        else{
            description = returningOperand
        }
        return returningOperand
    }
    
    /* adds Operation to the description 
     */
    private func addOperationToDescription(symbol: String, closure: (String) -> ()){
        closure(symbol);
    }

    /* edit description for a unary operator according to is partial result and if an operand is typed in
     */
    private func descriptionForUnaryOperation(symbol: String){
        if isPartialResult{
            //add the unary operator to the last operand put in
            description = description.substringWithRange(description.startIndex..<description.endIndex.predecessor()) +
                symbol + "(" + description.substringFromIndex(description.endIndex.predecessor()) + ")"
        }
        else{
            //add the unary operator to the whole description
            if !operandTypedIn {
                description = symbol + "(" + addOperandToDescription(String(accumulator)) +  ")"
                operandTypedIn = true
            }
            else{
                description = symbol + "(" + description + ")"
            }
        }
    }

    /* returns description for EqualsOperation 
     */
    private func descriptionForEqualsOperation(){
        if !operandTypedIn {
            addOperandToDescription(String(accumulator))
            operandTypedIn = true
        }
    }

    
    /* execute the binary operation which is wating for the second opearnd
     */
    private func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil;
        }
    }
    

    /* a dictionary that matches the string with an operation
    */
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "+" : Operation.BinaryOperator({$0 + $1}),
        "=" : Operation.Equals,
        "÷" : Operation.BinaryOperator({$0 / $1}),
        "-" : Operation.BinaryOperator({$0 - $1}),
        "×" : Operation.BinaryOperator({$0 * $1}),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperator(sqrt),
        "^" : Operation.BinaryOperator({pow($0, $1)}),
        "%" : Operation.BinaryOperator({$0 % $1})
    ]
    
    
    /* enum which splits the Operations into four cases and gives associated values
     */
    private enum Operation{
        case Constant(Double)
        case UnaryOperator(Double -> Double)
        case BinaryOperator((Double, Double) -> Double)
        case Equals
    }
    
    /* Defines a pendingBinaryOperatationInfo which just holds a function and
     stores the firstOperand
     */
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        
    }

    
    
}
