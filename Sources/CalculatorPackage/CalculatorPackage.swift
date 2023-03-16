import Foundation



public class CalculatorPackage<T: Inputable>: Calculable {

    public var inputBox = T()
    
    var firstNum: Double = 0.0
    var secondNum: Double = 0.0
    var currentOp: Operation = .none

    var tempOperation: [Any] = []
    
    public var result: Double = 0.0 {
        didSet {
            result = round(result * 100000000) / 100000000
        }
    }
    
    public init() {}
    
}

// MARK: 계산기 기능 메소드(사칙연산, =)
extension CalculatorPackage {
    
    public func makeCalculation(_ inputOp: Operation) {
        // MARK: T의 Type이 선언되지 않아 T.Val이라는 연관타입으로 선언되어 타입캐스팅 불가
        // String으로 타입캐스팅 후 Double로 변환, 만약 String이 아닐 시 생각해보기
        // AssociatedType에 Double로 변환 가능하게 하는 프로토콜을 제약으로 채택하면??
        // Error 1) guard let str = Double(inputBox.currentNum) else { return } // T.Val 타입이 StringProtocol을 준수해야 함
        // Error 2) guard let str = inputBox.currentNum as? Double else { return } // 타입캐스팅 오류
        
        let num: Double = makeNumToDouble()
        
        switch inputBox.state {
        // case .ready : 계산 준비 완료(두 번째 피연산자 입력 O)
        case .ready:
            switch currentOp {
                
            case .plus, .minus:
                addTempOperation()
                firstNum = result
                secondNum = num
                result = operateByCase(op: currentOp)

                if inputOp == .multiply || inputOp == .divide {
                    result = secondNum
                }
                
            case .multiply, .divide:
                firstNum = result
                secondNum = num
                result = operateByCase(op: currentOp)

                if !tempOperation.isEmpty && (inputOp == .plus || inputOp == .minus) {
                    operateTemp()
                }
                
            default:
                break
            }
            
            currentOp = inputOp
            inputBox.state = .calculating
        
        // case .calculating : 연산중 (두 번째 피연산자 입력 X)
        case .calculating:
            switch inputOp {
                
            case currentOp:
                return
                
            case .plus, .minus:
                if !tempOperation.isEmpty && (currentOp == .multiply || currentOp == .divide) {
                    let endIndex = tempOperation.index(before: tempOperation.endIndex)
                    guard let tempNum = tempOperation[tempOperation.startIndex] as? Double else { return }
                    guard let tempOp = tempOperation[endIndex] as? Operation else { return }
                    firstNum = tempNum
                    secondNum = num
                    result = operateByCase(op: tempOp)
                }
                currentOp = inputOp
                
            default:
                result = num
                currentOp = inputOp
            }
        
        // case .inital, .equaled : 초기 또는 연산 완료 (피연산자, 연산자 입력 X or 두 번째 피연산자 입력 X)
        default:
            result = num
            currentOp = inputOp
            inputBox.state = .calculating
        }
    }
    
    public func makeEqual() {
        
        switch inputBox.state {
        case .ready, .equaled:
            let num: Double = makeNumToDouble()
            firstNum = result
            secondNum = num
            result =  operateByCase(op: currentOp)
            
            if !tempOperation.isEmpty && (currentOp == .multiply || currentOp == .divide) {
                operateTemp()
            }
            
            inputBox.state = .equaled
            
        case .calculating:
            firstNum = result
            secondNum = result
            result = operateByCase(op: currentOp)
            inputBox.state = .equaled
            
        default:
            break
        }
    }
    
}

// MARK: 기능 메소드 구현에 필요한 내부 메소드
extension CalculatorPackage {
    
    func makeNumToDouble() -> Double {
        var num: Double = 0.0
        
        if T.Val.self == Double.self {
            num = inputBox.inputNum as? Double ?? 0.0
        } else if T.Val.self == String.self {
            let str = inputBox.inputNum as? String ?? "0"
            num = Double(str) ?? 0.0
        }
        
        return num
    }
    
    func addTempOperation() {
        if tempOperation.isEmpty {
            tempOperation.append(result)
            tempOperation.append(currentOp)
        } else {
            tempOperation[tempOperation.startIndex] = result
            let endIndex = tempOperation.index(before: tempOperation.endIndex)
            tempOperation[endIndex] = currentOp
        }
    }
    
    func operateTemp() {
            let endIndex = tempOperation.index(before: tempOperation.endIndex)
            guard let tempNum = tempOperation[tempOperation.startIndex] as? Double else { return }
            guard let tempOp = tempOperation[endIndex] as? Operation else { return }
            
            firstNum = tempNum
            secondNum = result
            
            result = operateByCase(op: tempOp)
    }
    
    
    func operateByCase(op: Operation) -> Double {
        var result: Double = 0.0
        do {
            switch op {
            case .plus:
                result = try makeAdd()
            case .minus:
                result = try makeSub()
            case .multiply:
                result = try makeMul()
            case.divide:
                result = try makeDiv()
            default:
                break
            }
            
        } catch CalculationError.dividedByZero {
            print("0으로 나눌 수 없습니다. result :", result)
        } catch CalculationError.infiniteNumber {
            print("수의 범위를 벗어났습니다. result :", result)
        } catch CalculationError.maxFractionDigits {
            print("소수점 자리수를 초과했습니다. result :", result)
        } catch {
            print("그 밖의 에러 :", error)
        }
        return result
    }
    
}

// MARK: Calculable Protocol Stubs
extension CalculatorPackage {
    
    func makeAdd() throws -> Double {
        let result = firstNum + secondNum
        
        guard result > Double.min && result < Double.max else {
            throw CalculationError.infiniteNumber
        }
        
        return result
    }
    
    func makeSub() throws -> Double {
        let result = firstNum - secondNum
        
        guard result > Double.min && result < Double.max else {
            throw CalculationError.infiniteNumber
        }
        
        return result
    }
    
    func makeMul() throws -> Double {
        let result = firstNum * secondNum
        
        guard result > Double.min && result < Double.max else {
            throw CalculationError.infiniteNumber
        }
        if result != 0.0 {
            guard result < Double.nMaxFractionDigits || result > Double.pMaxFractionDigits else {
                throw CalculationError.maxFractionDigits
            }
        }
        
        return result
    }
    
    func makeDiv() throws -> Double {
        let result = firstNum / secondNum
        
        guard !result.isNaN else {
            throw CalculationError.dividedByZero
        }
        guard result > Double.min && result < Double.max else {
            throw CalculationError.infiniteNumber
        }
        if result != 0.0 {
            guard result < Double.nMaxFractionDigits || result > Double.pMaxFractionDigits else {
                throw CalculationError.maxFractionDigits
            }
        }
        
        return result
    }
}

// MARK: Doubled Number & Decimal Range Constraint
extension Double {
    static var max: Double {
        return 1.0e161
    }
    static var min: Double {
        return -1.0e161
    }
    static var pMaxFractionDigits: Double {
        return 1.0e-91
    }
    static var nMaxFractionDigits: Double {
        return -1.0e-91
    }

}