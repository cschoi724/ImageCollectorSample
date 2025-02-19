//
//  ImageRepositoryImpl.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Combine
import CoreData

final class ImageRepositoryImpl: ImageRepository {
    let networkService: NetworkService
    let coreDataManager: CoreDataManagerProtocol
    
    init(networkService: NetworkService, coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared) {
        self.networkService = networkService
        self.coreDataManager = coreDataManager
    }
}

extension ImageRepositoryImpl {
    func fetchImageList() -> AnyPublisher<[ImageInfo], ServiceError> {
        let request = SearchRequest(limit: 100)
        let endpoint = APIEndpoints.fetchImageList(request: request)
        
        return networkService.request(endpoint)
            .tryMap { [weak self] (response: [ImageDTO]) in
                let imageList = response.map { $0.domain }
                self?.saveImagesToCoreData(imageList)
                return imageList
            }
            .catch { [weak self] error -> AnyPublisher<[ImageInfo], ServiceError> in
                guard let self = self else {
                    return Fail(error: ServiceError.unknownError("기존 컨텍스트가 존재하지 않음"))
                        .eraseToAnyPublisher()
                }
                return self.fetchImagesFromCoreData()
            }
            .mapError { error in self.resolveAPIError(error) }
            .eraseToAnyPublisher()
    }

    private func saveImagesToCoreData(_ images: [ImageInfo]) {
        let context = coreDataManager.context
        context.perform {
            let fetchRequest: NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
            do {
                let existingEntities = try context.fetch(fetchRequest)
                let existingMap = Dictionary(uniqueKeysWithValues: existingEntities.map { ($0.id!, $0) })
                
                for imageInfo in images {
                    Task {
                        let imageData = try await self.downloadImageData(from: imageInfo.url)
                        let imageInfo = ImageInfo(
                            id: imageInfo.id,
                            url: imageInfo.url,
                            width: imageInfo.width,
                            height: imageInfo.height,
                            imageData: imageData
                        )
                        context.performAndWait {
                            if let existingEntity = existingMap[imageInfo.id] {
                                existingEntity.update(from: imageInfo)
                            } else {
                                if let newEntity = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: context) as? ImageEntity {
                                    newEntity.update(from: imageInfo)
                                }
                            }
                            do {
                                try context.save()
                            } catch {
                                print("Core Data 저장 실패: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            } catch {
                print("Core Data 저장 실패: \(error.localizedDescription)")
            }
        }
    }

    private func fetchImagesFromCoreData() -> AnyPublisher<[ImageInfo], ServiceError> {
        let context = coreDataManager.context
        return Future { promise in
            context.perform {
                do {
                    let countFetchRequest: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: "ImageEntity")
                    countFetchRequest.resultType = .countResultType
                    let totalCount = try context.count(for: countFetchRequest)
                    guard totalCount > 0 else {
                        promise(.success([]))
                        return
                    }

                    let maxOffset = max(totalCount - 10, 0)
                    let randomOffset = Int.random(in: 0...maxOffset)

                    let fetchRequest: NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
                    fetchRequest.fetchLimit = 10
                    fetchRequest.fetchOffset = randomOffset
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
                    let result = try context.fetch(fetchRequest)
                    let images = result.compactMap { entity -> ImageInfo? in
                        guard let id = entity.id,
                              let url = entity.url else { return nil }
                        return ImageInfo(
                            id: id,
                            url: url,
                            width: Int(entity.width),
                            height: Int(entity.height),
                            imageData: entity.imageData
                        )
                    }
                    promise(.success(images))
                } catch {
                    print("Core Data 조회 실패: \(error.localizedDescription)")
                    promise(.failure(.databaseError("Core Data 조회 실패")))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func resolveAPIError(_ error: Error) -> ServiceError {
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidURL:
                return .networkError("유효하지 않은 URL입니다.")
            case .badServerResponse(let statusCode):
                return statusCode >= 400 && statusCode < 500
                    ? .clientError(statusCode, "클라이언트 요청 오류")
                    : .serverError(statusCode, "서버 응답 오류")
            case .decodingError(let message):
                return .decodingError("데이터 처리 오류: \(message)")
            case .networkError(let error):
                return .networkError(error.localizedDescription)
            case .invalidBody:
                return .networkError("유효하지 않은 Body입니다.")
            }
        }

        return .unknownError("알 수 없는 에러 발생: \(error.localizedDescription)")
    }
    
    private func downloadImageData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
