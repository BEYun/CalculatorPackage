import Foundation



public class CalculatorPackage<T: Inputable>: Calculable {
    
    public var inputBox = T()
    
    var firstNum: Double = 0.0
    var secondNum: Double = 0.0
    var currentOp: OperationType = .none
    
    var tempOperation: [Any] = []
    
    var doubleResult: Double = 0.0
    
    public var outputResult: String {
        get {
            return getOutputResult()
        }
    }
    
    public init() {}
    
}

// MARK: 계산기 기능 메소드(사칙연산, =, AC)
extension CalculatorPackage {
    
    public func makeCalculation(_ inputOp: OperationType) {
        
        let num: Double = makeNumToDouble()
        
        switch inputBox.state {
        // case .ready : 계산 준비 완료(두 번째 피연산자 입력 O)
        case .ready:
            switch currentOp {
            case .plus, .minus:
                addTempOperation()
                firstNum = doubleResult
                secondNum = num
                doubleResult = operateByOpType(op: currentOp)

                if inputOp == .multiply || inputOp == .divide {
                    doubleResult = secondNum
                }
            case .multiply, .divide:
                firstNum = doubleResult
                secondNum = num
                doubleResult = operateByOpType(op: currentOp)

                if !tempOperation.isEmpty && (inputOp == .plus || inputOp == .minus) {
                    operateTempCase()
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
                    guard let tempOp = tempOperation[endIndex] as? OperationType else { return }
                    firstNum = tempNum
                    secondNum = num
                    doubleResult = operateByOpType(op: tempOp)
                }
                currentOp = inputOp
            default:
                doubleResult = num
                currentOp = inputOp
            }
        
        // case .equaled : 연산 완료 (두 번째 피연산자 입력 X)
        case .equaled:
            firstNum = doubleResult
            currentOp = inputOp
            inputBox.state = .calculating
            
        // case .inital : 초기 (피연산자, 연산자 입력 X)
        default:
            doubleResult = num
            currentOp = inputOp
            inputBox.state = .calculating
        }
    }
    
    public func makeEqual() {
        
        switch inputBox.state {
        case .ready, .equaled:
            let num: Double = makeNumToDouble()
            firstNum = doubleResult
            secondNum = num
            doubleResult =  operateByOpType(op: currentOp)
            
            inputBox.state = .equaled
            
        case .calculating:
            firstNum = doubleResult
            secondNum = doubleResult
            doubleResult = operateByOpType(op: currentOp)
            
            inputBox.state = .equaled
            
        default:
            break
        }
        
        if !tempOperation.isEmpty && (currentOp == .multiply || currentOp == .divide) {
            operateTempCase()
        }
        
        tempOperation = []
    }
    
    public func makeClear() {
        firstNum = 0.0
        secondNum = 0.0
        tempOperation = []
        doubleResult = 0.0
        inputBox.clearNum()
    }
    
}

// MARK: 기능 메소드 구현에 필요한 내부 메소드
extension CalculatorPackage {
    
    // T의 Type이 선언되지 않아 T.Val이라는 연관타입으로 선언되어 타입캐스팅 불가 -> Type.self로 메타 타입 값 비교
    // 만약 T의 타입이 늘어난다면...?
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
            tempOperation.append(doubleResult)
            tempOperation.append(currentOp)
        } else {
            tempOperation[tempOperation.startIndex] = doubleResult
            let endIndex = tempOperation.index(before: tempOperation.endIndex)
            tempOperation[endIndex] = currentOp
        }
    }
    
    func operateTempCase() {
            let endIndex = tempOperation.index(before: tempOperation.endIndex)
            guard let tempNum = tempOperation[tempOperation.startIndex] as? Double else { return }
            guard let tempOp = tempOperation[endIndex] as? OperationType else { return }
            
            firstNum = tempNum
            secondNum = doubleResult
            
            doubleResult = operateByOpType(op: tempOp)
    }
    
    
    func operateByOpType(op: OperationType) -> Double {
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
            result = Double.nan
            print("0으로 나눌 수 없습니다. result :", result)
            return result
        } catch CalculationError.infiniteNumber {
            result = Double.infinity
            print("수의 범위를 벗어났습니다. result :", result)
            return result
        } catch CalculationError.maxFractionDigits {
            result = Double.nan
            print("소수점 자리수를 초과했습니다. result :", result)
            return result
        } catch {
            result = Double.nan
            print("그 밖의 에러 :", error)
            return result
        }
        return result
    }
    
    func getOutputResult() -> String {
        switch inputBox.state {
        case .initial, .ready:
            let str = inputBox.inputNum as? String ?? "Error"
            guard let num = Double(str) else { return "0"}
            return makeFormatByRange(num: num)
        case .calculating, .equaled:
            return makeFormatByRange(num: doubleResult)
        }
    }
    
    func makeFormatByRange(num: Double) -> String {
        let numberformatter = NumberFormatter()
        numberformatter.maximumFractionDigits = 8
        var result: String = "0"
        
        switch num {
            
        case 0, .nMaxExponent ... .nMinExponent, .pMinExponent ... .pMaxExponent:
            numberformatter.numberStyle = .decimal
            guard let str = numberformatter.string(for: num) else { return "0"}
            result = str
            
        default:
            numberformatter.numberStyle = .scientific
            numberformatter.maximumFractionDigits = 5
            guard let str = numberformatter.string(for: num) else { return "0"}
            result = str
        }
        
        if result.count > 12 {
            let idx = result.index(result.startIndex, offsetBy: 12)
            if result[idx] == "." {
                result = String(result[..<idx])
            } else {
                result = String(result[...idx])
            }
        }
        
        return result
    }
    
}

// MARK: Calculable Protocol Stubs
extension CalculatorPackage {
    
    func makeAdd() throws -> Double {
        let result = firstNum + secondNum
        
        guard result > Double.nMax && result < Double.pMax else {
            throw CalculationError.infiniteNumber
        }
        
        return result
    }
    
    func makeSub() throws -> Double {
        let result = firstNum - secondNum
        
        guard result > Double.nMax && result < Double.pMax else {
            throw CalculationError.infiniteNumber
        }
        
        return result
    }
    
    func makeMul() throws -> Double {
        let result = firstNum * secondNum
        
        guard result > Double.nMax && result < Double.pMax else {
            throw CalculationError.infiniteNumber
        }
        if result != 0.0 {
            guard result < Double.nMaxFraction || result > Double.pMaxFraction else {
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
        guard result > Double.nMax && result < Double.pMax else {
            throw CalculationError.infiniteNumber
        }
        if result != 0.0 {
            guard result < Double.nMaxFraction || result > Double.pMaxFraction else {
                throw CalculationError.maxFractionDigits
            }
        }
        
        return result
    }
}
