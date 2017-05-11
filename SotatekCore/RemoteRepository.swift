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
            .do(onError: onError)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> T in
                let entity = T(fromJson: response.data)
                return entity
            })
    }

    var getMap: [DataIdType: Observable<T>] = [:]
    open func get(_ id: DataIdType, options: [String : Any] = [:]) -> Observable<T> {
        if let observable = getMap[id] {
            return observable
        }

        let result = request.get(id, options: options)
            .do(onError: onError)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> T in
                let entity = T(fromJson: response.data)
                return entity
            }).shareReplay(1)
        
        getMap[id] = result

        _ = result
            .subscribe(
                onError: { error in
                    self.getMap[id] = nil
            },
                onCompleted: {
                    self.getMap[id] = nil
            }
        )
        return result
    }

    open func update(_ object: T, options: [String : Any] = [:]) -> Observable<T> {
        return request.update(object, options: options)
            .do(onError: onError)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> T in
                let entity = T(fromJson: response.data)
                return entity
            })

    }

    open func remove(_ id: DataIdType, options: [String : Any] = [:]) -> Observable<Bool> {
        return request.remove(id, options: options)
            .do(onError: onError)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> Bool in
                return true
            })

    }
    
    func getList(count: Int, options: [String: Any] = [:]) -> Observable<ListDto<T>> {
        return request.getList(count: count, options: options)
            .do(onError: onError)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> ListDto<T> in
                let listResponse = ListResponse<T>(fromJson: response.data)
                self.updateGlobalData(response)
                return ListDto(data: listResponse.data, pagination: response.pagination)
            })
    }
    
    func getAll(options: [String: Any] = [:]) -> Observable<ListDto<T>> {
        return request.getAll(options: options)
            .do(onError: onError)
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

    open func onError(error: Error) {
    }
}
