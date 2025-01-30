import Foundation
import SwiftData

// @Model: SwiftData의 영구 저장소에 저장될 예산 모델
// 사용자의 월간 예산과 일일 예산을 관리하는 클래스
@Model
final class Budget {
    // 월간 예산 금액
    var monthlyAmount: Double
    // 일일 기본 예산 금액 (월간 예산을 해당 월의 일수로 나눈 값)
    var dailyAmount: Double
    // 예산 시작일
    var startDate: Date
    // 수정된 일일 예산을 저장하는 딕셔너리 [날짜: 수정된 금액]
    var modifiedDailyBudgets: [Date: Double]
    var createdAt: Date
    
    // 초기화: 월간 예산과 시작일을 받아 일일 예산을 계산
    init(monthlyAmount: Double, startDate: Date = Date()) {
        self.monthlyAmount = monthlyAmount
        self.startDate = startDate
        self.modifiedDailyBudgets = [:]
        
        // 현재 월의 일수를 계산하여 일일 예산 설정
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        self.dailyAmount = monthlyAmount / Double(range.count)
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