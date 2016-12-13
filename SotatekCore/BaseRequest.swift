//
//  BaseRequest.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/14/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import SwiftHTTP

open class BaseRequest<T: Serializable> {
    var networkDelay: Int = 1
    
    open var mockEntity = ""
    open var mockList = ""
    open var mockNextList = ""
    open var mockAll = ""
    
    open var entityUrl: String {
        get {
            return AppConfig.server + T.pluralName
        }
    }
    
    open var listUrl: String {
        get {
            return AppConfig.server + T.pluralName
        }
    }
    
    open func create(_ entity: T, url: String? = nil) -> Observable<HttpResponse> {
        var params = entity.toDictionary()
        for (key, value) in createRequestParams(options: [:]) {
            params[key] = value
        }
        return createResponseObservable(method: .POST, url: url ?? self.entityUrl, params: params, mockFile: "")
    }
    
    open func update(_ entity: T, url: String? = nil) -> Observable<HttpResponse> {
        var params = entity.toDictionary()
        for (key, value) in createRequestParams(options: [:]) {
            params[key] = value
        }
        return createResponseObservable(method: .PUT, url: url ?? self.entityUrl, params: params)
    }
    
    open func remove(_ entity: T) -> Observable<T> {
        return Observable<T>.create({subscribe in
            self.delay({
                if Int.random() % 2 == 0 {
                    subscribe.onNext(entity)
                } else {
                    subscribe.onError(NSError())
                }
                subscribe.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    open func get(_ id: DataIdType, options: [String : Any] = [:]) -> Observable<HttpResponse> {
        let params = createRequestParams(options: options)
        return createResponseObservable(method: .GET, url: "\(self.entityUrl)/\(id)", params: params, mockFile: mockEntity)
    }
    
    func createRequestParams(options: [String: Any]) -> [String: Any] {
        var params = options[Constant.RepositoryParam.requestParams] as? [String: Any] ?? [:]
        params[Constant.RequestParam.Pagination.type] = Constant.RequestParam.Pagination.cursor
        params[Constant.RequestParam.Pagination.field] = "id"
        if let pivot = options[Constant.RepositoryParam.pivot] as? BaseEntity {
            params[Constant.RequestParam.Pagination.before] = pivot.id
        } else if let pivot = options[Constant.RepositoryParam.pivot] as? BaseDto {
            params[Constant.RequestParam.Pagination.before] = pivot.id
        }

        return params
    }

    func createDefaultParams() -> [String: Any] {
        return [:]
    }
    
    func getList(count: Int, options: [String: Any]) -> Observable<HttpResponse> {
        var params = createRequestParams(options: options)
        params[Constant.RequestParam.Pagination.limit] = count
        return getList(url: self.listUrl, params: params, mockFile: self.mockList)
    }
    
    func getList(url: String, params: [String: Any], mockFile: String = "") -> Observable<HttpResponse> {
        return createResponseObservable(method: .GET, url: url, params: params, mockFile: mockFile)
    }
    
    func getAll(options: [String: Any]) -> Observable<HttpResponse> {
        let params = createRequestParams(options: options)
        return getList(url: self.listUrl, params: params, mockFile: self.mockAll)
    }
    
    func delay(_ f: @escaping () -> Void) {
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.asyncAfter(deadline: .now() + Double(networkDelay)) {
            DispatchQueue.main.async(execute: { () -> Void in
                f()
            })
        }
    }
    
    func readFile(name: String) -> String {
        return Util.readTextFile(name: name, type: "js")
    }
    
    open func createResponseObservable(method: HTTPVerb, url: String, params: [String: Any], mockFile: String = "") -> Observable<HttpResponse> {
        return Observable<HttpResponse>.create({subscribe in
            if AppConfig.useMockResponse && !mockFile.isEmpty {
                self.responseMockData(mockFile: mockFile, subscribe: subscribe)
            } else {
                self.executeRequest(method: method, url: url, params: params, {response in
                    self.processResponse(response: response, subscribe: subscribe)
                })
            }
            return Disposables.create()
        })
    }

    func createHeaders() -> [String: String] {
        return [:]
    }
    
    func executeRequest(method: HTTPVerb, url: String, params: [String: Any], _ completionHandler:@escaping ((Response) -> Void)) {
        do {
            var requestParams = createDefaultParams()
            for (key, value) in params {
                requestParams[key] = value
            }
            print(url)
            print(requestParams)
            let headers = createHeaders()
            let opt = try HTTP.New(url, method: method, parameters: requestParams, headers: headers)
            opt.start(completionHandler)
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    func processResponse(response: Response, subscribe: AnyObserver<HttpResponse>) {
        if let error = response.error {
            print(error)
            subscribe.on(.error(error))
        } else {
            let json = response.text!
            print(json)
            let jsonResponse = HttpResponse(fromJson: JSON.parse(json))
            subscribe.onNext(jsonResponse)
        }
        subscribe.onCompleted()
    }
    
    func responseMockData(mockFile: String, subscribe: AnyObserver<HttpResponse>) {
        self.delay({
            let json = self.readFile(name: mockFile)
            print(json)
            let response = HttpResponse(fromJson: JSON.parse(json))
            subscribe.onNext(response)
            subscribe.onCompleted()
        })
    }
}
