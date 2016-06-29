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
    
    /* sets the operand to the accumulator
     */
    func setOperand(operand: Double){
        //addToDescription(String(operand))
        accumulator = operand
    }
    
    /* public variable to get accumulator since we dont want it to be set
    */
    var result: Double {
        get{
            return accumulator
        }
        
    }

    /* adds on to the description
    */
    func addToDescription(s: String){
        description += s
    }
    
    /* gives back the description based on value of isPartialResult
    */
    func returnDescription() -> String{
        if isPartialResult {
            return description + "..."
        }
        else{
            return description
        }
    }
    
    /* Performs the operation based on which type of opeartion it is
     */
    func performOperation(symbol: String) {
        if let operation = operations[symbol]{
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperator(let function):
                accumulator = function(accumulator)
            case .BinaryOperator(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
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
