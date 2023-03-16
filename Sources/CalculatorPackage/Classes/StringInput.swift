//
//  StringInput.swift
//  
//
//  Created by BEYun on 2023/03/13.
//

import Foundation

public class StringInput: Inputable {

    public typealias Val = String
    
    public var inputNum: String = "0"
    
    public var state: State = .initial
    
    public func addNum(_ num: String) {
        
        if state == .calculating {
            inputNum = "0"
            state = .ready
        } else if state == .equaled {
            inputNum = "0"
            state = .initial
        }
        
        if inputNum.count < 10 {
            switch inputNum {
            case "0":
                inputNum = num
            case "-0":
                inputNum = "-" + num
            default:
                inputNum += num
            }
        }
        
    }
    
    required public init() {}
    
    deinit {
        print("StringNumber Instance deinitialized")
    }
}
