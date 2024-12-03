import Foundation
import Combine

enum StorageKey: String {
    case budgets = "budgets"
    case expenses = "expenses"
}

enum StorageError: Error {
    case encodingFailed
    case decodingFailed
    case unknown
}

protocol Storage {
    func save<T: Encodable>(_ value: T, for key: StorageKey) -> AnyPublisher<Void, Error>
    func load<T: Decodable>(_ type: T.Type, for key: StorageKey) -> AnyPublisher<T, Error>
}

final class UserDefaultsStorage: Storage {
    private let defaults: UserDefaults
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(
        defaults: UserDefaults = .standard,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.defaults = defaults
        self.decoder = decoder
        self.encoder = encoder
        
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }
    
    func save<T: Encodable>(_ value: T, for key: StorageKey) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else {
                    promise(.failure(StorageError.unknown))
                    return
                }
                
                do {
                    let data = try self.encoder.encode(value)
                    self.defaults.set(data, forKey: key.rawValue)
                    promise(.success(()))
                } catch {
                    promise(.failure(StorageError.encodingFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func load<T: Decodable>(_ type: T.Type, for key: StorageKey) -> AnyPublisher<T, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else {
                    promise(.failure(StorageError.unknown))
                    return
                }
                
                guard let data = self.defaults.data(forKey: key.rawValue) else {
                    promise(.failure(StorageError.decodingFailed))
                    return
                }
                
                do {
                    let value = try self.decoder.decode(T.self, from: data)
                    promise(.success(value))
                } catch {
                    promise(.failure(StorageError.decodingFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
