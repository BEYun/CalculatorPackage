import XCTest
@testable import CalculatorPackage

final class CalculatorPackageTests: XCTestCase {
    
    private var stringTest: CalculatorPackage<StringInput>!
    private var doubleTest: CalculatorPackage<DoubleInput>!
    
    // MARK: 모든 테스트가 깨끗한 상태(state)로 시작하는지 확인하기 위해서 setUp()에서 SUT(System Under Test) 객체를 생성하고, tearDown()에서 해제하는 것이 가장 좋은 방법
    override func setUp() {
        stringTest = CalculatorPackage()
        doubleTest = CalculatorPackage()
        super.setUp()
    }
    
    override func tearDown() {
        stringTest = nil
        doubleTest = nil
        super.tearDown()
    }
    
    // MARK: Input Class의 addNum() 테스트
    func testAddNumber() throws {
        // stringTest : -10.3000 입력
        
        // 1. given (-10.3000)
        stringTest.inputBox.addNum("-1")
        stringTest.inputBox.addNum("0")
        stringTest.inputBox.addNum(".")
        stringTest.inputBox.addNum("3")
        stringTest.inputBox.addNum("0")
        stringTest.inputBox.addNum("0")
        stringTest.inputBox.addNum("0")
        
        // 2. when
        let result = stringTest.inputBox.inputNum
        
        // 3. then
        XCTAssertEqual(result, "-10.3000")
        
        // doubleTest : 44.0 입력
        
        // 1. given (44.0)
        doubleTest.inputBox.addNum(44.0)
        
        // 2. when
        let result2 = doubleTest.inputBox.inputNum
        
        // 3. then
        XCTAssertEqual(result2, 44.0)
        
    }
    
    // MARK: CalculatorPackage Class의 makeCalculation() 테스트 (연속된 연산자 X)
    func testMakeCalNotConsecutiveOp() throws {
        // stringTest : 1+1+1*5+5*5*5*5 = 632
        
        // 1. given (1+1+1*5+5*5*5*5)
        stringTest.inputBox.addNum("1")
        stringTest.makeCalculation(.plus)
        stringTest.inputBox.addNum("1")
        stringTest.makeCalculation(.plus)
        stringTest.inputBox.addNum("1")
        stringTest.makeCalculation(.multiply)
        stringTest.inputBox.addNum("5")
        stringTest.makeCalculation(.plus)
        stringTest.inputBox.addNum("5")
        stringTest.makeCalculation(.multiply)
        stringTest.inputBox.addNum("5")
        stringTest.makeCalculation(.multiply)
        stringTest.inputBox.addNum("5")
        stringTest.makeCalculation(.multiply)
        stringTest.inputBox.addNum("5")
        
        // 2. when
        stringTest.makeEqual()
        
        // 3. then
        XCTAssertEqual(stringTest.outputResult, "632")
        
        // doubleTest : 55+3*4+6.1*24+3 = 216.4
        
        // 1. given (55+3*4+6.1*24+3)
        doubleTest.inputBox.addNum(55.0)
        doubleTest.makeCalculation(.plus)
        doubleTest.inputBox.addNum(3.0)
        doubleTest.makeCalculation(.multiply)
        doubleTest.inputBox.addNum(4.0)
        doubleTest.makeCalculation(.plus)
        doubleTest.inputBox.addNum(6.1)
        doubleTest.makeCalculation(.multiply)
        doubleTest.inputBox.addNum(24)
        doubleTest.makeCalculation(.plus)
        doubleTest.inputBox.addNum(3)
        
        // 2. when
        doubleTest.makeEqual()
        
        // 3. then
        XCTAssertEqual(doubleTest.outputResult, "216.4")
    }
    
    // MARK: CalculatorPackage Class의 makeCalculation() 테스트 (연속된 연산자 O)
    func testMakeCalConsecutiveOp() throws {
        // stringTest : 1+1+1+***/+**5 = 7
        
        // 1. given (1+1+1+***/+**5)
        stringTest.inputBox.addNum("1")
        stringTest.makeCalculation(.plus)
        stringTest.inputBox.addNum("1")
        stringTest.makeCalculation(.plus)
        stringTest.inputBox.addNum("1")
        stringTest.makeCalculation(.plus)
        stringTest.makeCalculation(.multiply)
        stringTest.makeCalculation(.multiply)
        stringTest.makeCalculation(.multiply)
        stringTest.makeCalculation(.divide)
        stringTest.makeCalculation(.plus)
        stringTest.makeCalculation(.multiply)
        stringTest.makeCalculation(.multiply)
        stringTest.inputBox.addNum("5")
        
        // 2. when
        stringTest.makeEqual()
        
        // 3. then
        XCTAssertEqual(stringTest.outputResult, "7")
        
        
        // doubleTest : 3***4++2--35-*+23.232 = 2.232
        
        // 1. given (3***4++2--35-*+23.232)
        doubleTest.inputBox.addNum(3.0)
        doubleTest.makeCalculation(.multiply)
        doubleTest.makeCalculation(.multiply)
        doubleTest.makeCalculation(.multiply)
        doubleTest.inputBox.addNum(4.0)
        doubleTest.makeCalculation(.plus)
        doubleTest.makeCalculation(.plus)
        doubleTest.inputBox.addNum(2.0)
        doubleTest.makeCalculation(.minus)
        doubleTest.makeCalculation(.minus)
        doubleTest.inputBox.addNum(35)
        doubleTest.makeCalculation(.minus)
        doubleTest.makeCalculation(.multiply)
        doubleTest.makeCalculation(.plus)
        doubleTest.inputBox.addNum(23.232)
        
        // 2. when
        doubleTest.makeEqual()
        
        // 3. then
        XCTAssertEqual(doubleTest.outputResult, "2.232")
    }
    
    // MARK: CalculatorPackage Class의 makeEqual() 테스트
    func testMakeEqual() throws {
        // stringTest1 : 1+== -> result : 3
        // stringTest2 : 1+2= -> result : 3
        // stringTest3 : 1+-*-+3+-*-+= -> result : 8
        // stringTest4 : 1+3=== -> result : 10
        
        // stringTest 1
        // 1. given (1+)
        stringTest.inputBox.addNum("1")
        stringTest.makeCalculation(.plus)
        // 2. when
        stringTest.makeEqual()
        stringTest.makeEqual()
        // 3. then
        XCTAssertEqual(stringTest.outputResult, "3")
        
        // stringTest 2
        // 1. given (1+2)
        stringTest.inputBox.addNum("1")
        stringTest.makeCalculation(.plus)
        stringTest.inputBox.addNum("2")
        // 2. when
        stringTest.makeEqual()
        // 3. then
        XCTAssertEqual(stringTest.outputResult, "3")
        
        // stringTest 3
        // 1. given (1+-*-+3+-*-+)
        stringTest.inputBox.addNum("1")
        stringTest.makeCalculation(.plus)
        stringTest.makeCalculation(.minus)
        stringTest.makeCalculation(.multiply)
        stringTest.makeCalculation(.minus)
        stringTest.makeCalculation(.plus)
        stringTest.inputBox.addNum("3")
        stringTest.makeCalculation(.plus)
        stringTest.makeCalculation(.minus)
        stringTest.makeCalculation(.multiply)
        stringTest.makeCalculation(.minus)
        stringTest.makeCalculation(.plus)
        // 2. when
        stringTest.makeEqual()
        // 3. then
        XCTAssertEqual(stringTest.outputResult, "8")
        
        // stringTest 4
        // 1. given (1+3)
        stringTest.inputBox.addNum("1")
        stringTest.makeCalculation(.plus)
        stringTest.inputBox.addNum("3")
        // 2. when
        stringTest.makeEqual()
        stringTest.makeEqual()
        stringTest.makeEqual()
        // 3. then
        XCTAssertEqual(stringTest.outputResult, "10")
        
        // doubleTest1 : 1.2+== -> result : 3.6
        // doubleTest2 : 2.4+4.8= -> result : 7.2
        // doubleTest3 : 2323.12151**-++-*+= -> result : 4646.24302
        // doubleTest4 : 27.351+568.23=== -> result : 1732.041
        
        // doubleTest 1
        // 1. given (1.2+)
        doubleTest.inputBox.addNum(1.2)
        doubleTest.makeCalculation(.plus)
        // 2. when
        doubleTest.makeEqual()
        doubleTest.makeEqual()
        // 3. then
        XCTAssertEqual(doubleTest.outputResult, "3.6")
        
        // doubleTest 2
        // 1. given (2.4+4.8)
        doubleTest.inputBox.addNum(2.4)
        doubleTest.makeCalculation(.plus)
        doubleTest.inputBox.addNum(4.8)
        // 2. when
        doubleTest.makeEqual()
        // 3. then
        XCTAssertEqual(doubleTest.outputResult, "7.2")
        
        // doubleTest 3
        // 1. given (2323.12151**-++-*+)
        doubleTest.inputBox.addNum(2323.12151)
        doubleTest.makeCalculation(.multiply)
        doubleTest.makeCalculation(.multiply)
        doubleTest.makeCalculation(.minus)
        doubleTest.makeCalculation(.plus)
        doubleTest.makeCalculation(.plus)
        doubleTest.makeCalculation(.minus)
        doubleTest.makeCalculation(.multiply)
        doubleTest.makeCalculation(.plus)
        // 2. when
        doubleTest.makeEqual()
        // 3. then
        XCTAssertEqual(doubleTest.outputResult, "4,646.24302")
        
        // doubleTest 4
        // 1. given (27.351+568.23)
        doubleTest.inputBox.addNum(27.351)
        doubleTest.makeCalculation(.plus)
        doubleTest.inputBox.addNum(568.23)
        // 2. when
        doubleTest.makeEqual()
        doubleTest.makeEqual()
        doubleTest.makeEqual()
        // 3. then
        XCTAssertEqual(doubleTest.outputResult, "1,732.041")
        
    }
    
    // MARK: CalculatorPackage의 outputResult 결과 테스트
    func testOutputResult() throws {
        // test 123+456+*+= -> 123+(123) 456(456)+(579)*(456)+(579)=(1158)
        
        // 1. given (123)
        stringTest.inputBox.addNum("1")
        stringTest.inputBox.addNum("2")
        stringTest.inputBox.addNum("3")
        // 2. when
        stringTest.makeCalculation(.plus)
        // 3. then
        XCTAssertEqual(stringTest.outputResult, "123")
        
        // 1. given (456)
        stringTest.inputBox.addNum("4")
        stringTest.inputBox.addNum("5")
        stringTest.inputBox.addNum("6")
        // 2. when
        stringTest.makeCalculation(.plus)
        // 3. then
        XCTAssertEqual(stringTest.outputResult, "579")
        
        // 1. given (579)
        // 2. when
        stringTest.makeCalculation(.multiply)
        // 3. then
        XCTAssertEqual(stringTest.outputResult, "456")
        
        // 1. given (456)
        // 2. when
        stringTest.makeCalculation(.plus)
        // 3. then
        XCTAssertEqual((stringTest.outputResult), "579")
        
        // 1. given (579)
        // 2. when
        stringTest.makeEqual()
        // 3. then
        XCTAssertEqual(stringTest.outputResult, "1,158")
    }
}
