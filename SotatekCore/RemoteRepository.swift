//
//  RemoveRepository.swift
//  SotatekCore
//
//  Created by Thanh Tran on 10/4/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

class RemoteRepository<T: Serializable> {
    var request: BaseRequest<T>!
    let notifier = Notifier.repositoryNotifier
    
    init(request: BaseRequest<T>) {
        self.request = request
    }
    
    open func create(_ object: T, options: [String : Any] = [:]) -> Observable<T> {
        return request.create(object, options: options)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> T in
                let entity = T(fromJson: response.data)
                return entity
            })
    }
    
    open func get(_ id: DataIdType, options: [String : Any] = [:]) -> Observable<T> {
        return request.get(id, options: options)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> T in
                let entity = T(fromJson: response.data)
                return entity
            })

    }

    open func update(_ object: T, options: [String : Any] = [:]) -> Observable<T> {
        return request.update(object, options: options)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> T in
                let entity = T(fromJson: response.data)
                return entity
            })

    }

    open func remove(_ id: DataIdType, options: [String : Any] = [:]) -> Observable<Bool> {
        return request.remove(id, options: options)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> Bool in
                return true
            })

    }
    
    func getList(count: Int, options: [String: Any] = [:]) -> Observable<ListDto<T>> {
        return request.getList(count: count, options: options)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> ListDto<T> in
                let listResponse = ListResponse<T>(fromJson: response.data)
                self.updateGlobalData(response)
                return ListDto(data: listResponse.data, pagination: response.pagination)
            })
    }
    
    func getAll(options: [String: Any] = [:]) -> Observable<ListDto<T>> {
        return request.getAll(options: options)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> ListDto<T> in
                let listResponse = ListResponse<T>(fromJson: response.data)
                self.updateGlobalData(response)
                return ListDto(data: listResponse.data, pagination: response.pagination)
            })
    }
    
    func convertJsonToList(_ json: JSON) -> [T] {
        var entities = [T]()
        let jsonArray = json.arrayValue
        for jsonObject in jsonArray {
            let entity = T(fromJson: jsonObject)
            entities.append(entity)
        }
        return entities
    }

    func updateGlobalData(_ response: HttpResponse) {
        if let data = response.global {
            notifier.notifyObservers(Constant.commandReceiveGlobalData, data: data)
        }
    }
    
    open func processMeta(response: HttpResponse) -> Observable<HttpResponse> {
        return Observable.just(response)
    }
}
