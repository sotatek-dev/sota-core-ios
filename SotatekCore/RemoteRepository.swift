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
    
    open func create(_ object: T) -> Observable<T> {
        return request.create(object)
            .flatMap(processMeta)
            .map({(json: JSON) -> T in
                let entity = T(fromJson: json)
                return entity
            })
    }
    
    open func get(_ id: Int) -> Observable<T> {
        return request.get(id)
            .flatMap(processMeta)
            .map({(json: JSON) -> T in
                let entity = T(fromJson: json)
                return entity
            })

    }
    
    func getList(count: Int, options: [String: Any] = [:]) -> Observable<[T]> {
        return request.getList(count: count, options: options)
            .flatMap(processMeta)
            .map({(json: JSON) -> [T] in
                let listDto = ListDto<T>(fromJson: json)
                self.updateGlobalData(listDto)
                return listDto.data
            })
    }
    
    func convertJsonToList(_ json: JSON) -> [T] {
//        var entities = [T]()
//        let jsonArray = json[T.pluralName].arrayValue
//        for jsonObject in jsonArray {
//            let entity = T(fromJson: jsonObject)
//            entities.append(entity)
//        }
//        return entities
        var entities = [T]()
        let jsonArray = json.arrayValue
        for jsonObject in jsonArray {
            let entity = T(fromJson: jsonObject)
            entities.append(entity)
        }
        return entities
    }
    
//    func getNextList(pivot: T, count: Int, options: [String: Any] = [:]) -> Observable<[T]> {
//        var newOptions = options
//        newOptions[Constant.RepositoryParam.pivot] = pivot
//        return getList(count: count, options: newOptions)
//    }
    
    func updateGlobalData(_ listDto: ListDto<T>) {
        if let data = listDto.global {
            notifier.notifyObservers(Constant.commandReceiveGlobalData, data: data)
        }
    }
    
    open func processMeta(response: HttpResponse) -> Observable<JSON> {
        return Observable.just(response.data)
    }
}
