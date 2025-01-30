import Foundation
import SwiftData

// @Model: SwiftData의 영구 저장소에 저장될 예산 모델
// 사용자의 월간 예산과 일일 예산을 관리하는 클래스
@Model
final class Budget {
    // 일일 기본 예산 금액
    var dailyAmount: Double
    // 수정된 일일 예산을 저장하는 딕셔너리 [날짜: 수정된 금액]
    var modifiedDailyBudgets: [Date: Double]
    // 예산 시작일
    var startDate: Date
    // 생성일
    var createdAt: Date
    
    // 초기화: 월간 예산과 시작일을 받아 일일 예산을 계산
    init(dailyAmount: Double, startDate: Date = Date()) {
        self.dailyAmount = dailyAmount
        self.modifiedDailyBudgets = [:]
        self.startDate = Date()
        self.createdAt = Date()
    }
    
    // 특정 날짜의 일일 예산을 반환
    // 수정된 예산이 있다면 수정된 값을, 없다면 기본 일일 예산을 반환
    func getDailyBudget(for date: Date) -> Double {
        if let modified = modifiedDailyBudgets[date] {
            return modified
        }
        return dailyAmount
    }
    
    // 특정 날짜의 일일 예산을 수정
    func modifyDailyBudget(_ amount: Double, for date: Date) {
        modifiedDailyBudgets[date] = amount
    }
}
