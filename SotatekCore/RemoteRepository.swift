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
    
    open func get(_ id: Int) -> Observable<T> {
        return request.get(id).map({(json: JSON) -> T in
            let entity = T(fromJson: json)
            return entity
        })

    }
    
    func getList(count: Int, options: [String: Any] = [:]) -> Observable<[T]> {
        return request.getList(count: count, options: options).map({(json: JSON) -> [T] in
            let listDto = ListDto<T>(fromJson: json)
            self.updateGlobalData(listDto)
            return listDto.data
        })
    }
    
    func convertJsonToList(_ json: JSON) -> [T] {
        var entities = [T]()
        let jsonArray = json[T.pluralName].arrayValue
        for jsonObject in jsonArray {
            let entity = T(fromJson: jsonObject)
            entities.append(entity)
        }
        return entities
    }
    
    func getNextList(pivot: T, count: Int, options: [String: Any] = [:]) -> Observable<[T]> {
        return request.getNextList(pivot: pivot, count: count, options: options).map({(json: JSON) -> [T] in
            let listDto = ListDto<T>(fromJson: json)
            self.updateGlobalData(listDto)
            return listDto.data
        })
    }
    
    func updateGlobalData(_ listDto: ListDto<T>) {
        if let data = listDto.global {
            notifier.notifyObservers(Constant.commandReceiveGlobalData, data: data)
        }
    }
}