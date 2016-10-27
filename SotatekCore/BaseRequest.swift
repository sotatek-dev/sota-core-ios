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
    var id: Int = 0
    
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
    
    open func create(_ entity: T) -> Observable<T> {
        return Observable<T>.create({subscribe in
            self.delay({
                self.id += 1
//                entity.id = self.id
                subscribe.onNext(entity)
                subscribe.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    open func update(_ entity: T) -> Observable<T> {
        return Observable<T>.create({subscribe in
            self.delay({
                subscribe.onNext(entity)
                subscribe.onCompleted()
            })
            return Disposables.create()
        })
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
    
    open func get(_ id: Int) -> Observable<HttpResponse> {
        return Observable<HttpResponse>.create({subscribe in
            if AppConfig.useMockResponse && !self.mockEntity.isEmpty {
                self.delay({
                    [weak self] in
                    guard let this = self else { return }
                    //subscribe.onNext(self.createDummyEntity(id)!)
                    let json = this.readFile(name: this.mockEntity)
                    let response = HttpResponse(fromJson: JSON.parse(json))
                    subscribe.onNext(response)
                    subscribe.onCompleted()
                })
            } else {
                self.executeRequest(method: .GET, url: "\(self.entityUrl)/\(id)", params: [:], {response in
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
                })
            }
            return Disposables.create()
        })
    }
    
    func getList(count: Int, options: [String: Any]) -> Observable<HttpResponse> {
        return Observable<HttpResponse>.create({subscribe in
            if AppConfig.useMockResponse && !self.mockList.isEmpty {
                self.delay({
                    let json = self.readFile(name: self.mockList)
                    print(json)
                    let response = HttpResponse(fromJson: JSON.parse(json))
                    subscribe.onNext(response)
                    subscribe.onCompleted()
                })
            } else {
                self.executeRequest(method: .GET, url: self.listUrl, params: [:], {response in
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
                })
            }
            return Disposables.create()
        })
    }
    
    func getNextList(pivot: T, count: Int, options: [String: Any]) -> Observable<HttpResponse> {
        return Observable<HttpResponse>.create({subscribe in
            if AppConfig.useMockResponse && !self.mockNextList.isEmpty {
                self.delay({
                    let json = self.readFile(name: self.mockNextList)
                    print(json)
                    let response = HttpResponse(fromJson: JSON.parse(json))
                    subscribe.onNext(response)
                    subscribe.onCompleted()
                })
            } else {
                self.executeRequest(method: .GET, url: self.listUrl, params: [:], {response in
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
                })
            }
            return Disposables.create()
        })
    }
    
    func getAll(options: [String: Any]) -> Observable<HttpResponse> {
        return Observable<HttpResponse>.create({subscribe in
            self.delay({
                if !self.mockAll.isEmpty {
                    let json = self.readFile(name: self.mockAll)
                    print(json)
                    
                    let response = HttpResponse(fromJson: JSON.parse(json))
                    print(response)
                    
                    subscribe.onNext(response)
                }
                subscribe.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func createDummyEntity(_ id: Int, options: [String: Any] = [:]) -> T? {
        self.id += 1
        let contact = ContactEntity(id: id, name: "Contact \(id)", avatarPath: "", online: true)
        let conversation = ConversationEntity(id: id, ownerId: 0, name: "Conversation \(id)", participantId: 1, createdAt: 0, unreadCount: 0, lastUpdate: 0, status: Int(0))
        let message = MessageEntity(id: self.id, conversationId: 0, timestamp: Util.currentTime() + id, text: "Message \(id)", senderId: 0, status: 0)
        
        if let contact = contact as? T {
            print("Get contact \(id) from server")
            return contact
        } else if let conversation = conversation as? T {
            print("Get conversation \(id) from server")
            return conversation
        } else if let m = message as? T {
            print("Get message \(id) from server")
            message.conversationId = options[Constant.repositoryGroupId] as! Int
            return m
        }
        return nil
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
        if let filepath = Bundle.main.path(forResource: name, ofType: "js") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        return ""
    }
    
    func executeRequest(method: HTTPVerb, url: String, params: [String: AnyObject], _ completionHandler:@escaping ((Response) -> Void)) {
        do {
            var requestParams = params
            requestParams[Constant.requestAuthToken] = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOjEsImVtYWlsIjoic2FpdGFtYUBvbmUuY29tIiwiZXhwIjoxNDc3OTk3MjU4NzYxfQ.RvjsOJJlzSd4QTGV3nuUd5QvV6jKAUCphkBlxcx2wqs" as AnyObject?
            print(url)
            print(requestParams)
            let opt = try HTTP.New(url, method: method, parameters: requestParams)
            opt.start(completionHandler)
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
}
