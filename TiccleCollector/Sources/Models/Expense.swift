//
//  Expense.swift
//  TiccleCollector
//
//  Created by 김정완 on 1/31/25.
//

import Foundation

struct Expense: Identifiable {
    let id: UUID
    let amount: Double
    let category: String
    let memo: String?
    let date: Date
}
