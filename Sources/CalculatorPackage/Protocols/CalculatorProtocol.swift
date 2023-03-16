//
//  CalculatorProtocol.swift
//  
//
//  Created by BEYun on 2023/03/10.
//

import Foundation

public protocol Inputable {
    
    associatedtype Val
    
    var inputNum: Val { get set }
    
    var state: State { get set }
    
    func addNum(_ num: Val)
    
    func clearNum()
    
    init()
    
}

protocol Calculable: Adding, Substracting, Multiplying, Dividing {
    // 연산자, 피연산자, 임시 저장
    var firstNum: Double { get set }
    var secondNum: Double { get set}
    var currentOp: OperationType { get set }
    var tempOperation: [Any] { get set }
}

protocol Adding {
    associatedtype T
    func makeAdd() throws -> T
}

protocol Substracting {
    associatedtype T
    func makeSub() throws -> T
}

protocol Multiplying {
    associatedtype T
    func makeMul() throws -> T
}

protocol Dividing {
    associatedtype T
    func makeDiv() throws -> T
}


