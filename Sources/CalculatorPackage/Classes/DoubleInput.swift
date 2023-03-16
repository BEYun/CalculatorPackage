//
//  DoubleInput.swift
//  
//
//  Created by BEYun on 2023/03/15.
//

import Foundation

public class DoubleInput: Inputable {
    
    public typealias Val = Double
    
    public var inputNum: Double = 0.0
    
    public var state: State = .initial
    
    public var isSigned: Bool = false
    
    public func addNum(_ num: Double) {
        
        if state == .calculating {
            inputNum = 0.0
            state = .ready
        } else if state == .equaled {
            inputNum = 0.0
            state = .initial
        }
        
        if inputNum == 0.0 {
            inputNum = num
        }
        
        // 자리수 한 자리 씩 추가 미구현
//          else if isSigned {
//            // - 부호 추가
//            inputNum = num
//        } else {
//            inputNum += num
//        }
    }
    
    public func clearNum() {
        inputNum = 0.0
        state = .initial
    }

    required public init() {}
    
    deinit {
        print("DoubleNumber Instance deinitialized")
    }
}
