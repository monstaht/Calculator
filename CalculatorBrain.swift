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
    
    private var description = ""
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
    private var pending: PendingBinaryOperationInfo?
    
    var result: Double {
        get{
            return accumulator
        }
        
    }
    
    func addToDescription(s: String){
        description += s
    }
    
    func returnDescription() -> String{
        if isPartialResult {
            return description + "..."
        }
        else{
            return description
        }
    }
    

    
    var operations: Dictionary<String, Operation> = [
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
    
    enum Operation{
        case Constant(Double)
        case UnaryOperator(Double -> Double)
        case BinaryOperator((Double, Double) -> Double)
        case Equals
    }
    
    func setOperand(operand: Double){
        accumulator = operand
    }
    
    func performOperation(symbol: String) {
        addToDescription(symbol)
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
    
    private func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil;
        }
    }
    
    struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        
    }
    
    
}
