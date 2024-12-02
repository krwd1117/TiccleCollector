protocol TiccleRepository {
    func getTiccles() async throws -> [Ticcle]
    func saveTiccle(_ ticcle: Ticcle) async throws
    func deleteTiccle(id: String) async throws
}
