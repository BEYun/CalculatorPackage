//
//  DoubleExtension.swift
//  
//
//  Created by BEYun on 2023/03/16.
//

import Foundation

// MARK: Doubled Number & Decimal Range Constraint
extension Double {
    // Overflow Range
    static var pMax: Double {
        return 1.0e161
    }
    
    static var nMax: Double {
        return -1.0e161
    }
    
    static var pMaxFraction: Double {
        return 1.0e-91
    }
    
    static var nMaxFraction: Double {
        return -1.0e-91
    }
    
    // Exponential Range
    static var nMaxExponent: Double {
        return -999999999
    }
    
    static var nMinExponent: Double {
        return -0.00000001
    }
    
    static var pMinExponent: Double {
        return 0.00000001
    }
    
    static var pMaxExponent: Double {
        return 999999999
    }
}
