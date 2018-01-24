//
//  BaseRequest.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/14/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import RxSwift
import SwiftyJSON
import Alamofire

open class BaseRequest<T: Serializable> {
    var networkDelay: Int = 3
    
    open var mockEntity = ""
    open var mockList = ""
    open var mockNextList = ""
    open var mockAll = ""

    open var options: [String: Any] = [:]
    open var count: Int?
    
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
    
    open func create(_ entity: T, url: String? = nil, options: [String : Any] = [:]) -> Observable<HttpResponse> {
        var params = entity.toDictionary()
        for (key, value) in createRequestParams(options: options) {
            params[key] = value
        }
        let progressHandler = options[Constant.RepositoryParam.progressHandler] as? ((Double) -> Swift.Void)
        return createResponseObservable(method: .post, url: url ?? self.entityUrl, params: params, mockFile: "", progressHandler: progressHandler)
    }
    
    open func update(_ entity: T, url: String? = nil, options: [String : Any] = [:]) -> Observable<HttpResponse> {
        var params = entity.toDictionary()
        for (key, value) in createRequestParams(options: options) {
            params[key] = value
        }
        return createResponseObservable(method: .put, url: url ?? self.entityUrl, params: params)
    }
    
    open func remove(_ id: DataIdType, url: String? = nil, options: [String : Any] = [:]) -> Observable<HttpResponse> {
        let params = createRequestParams(options: options)
        let removeUrl = url ?? "\(self.entityUrl)/\(id)"
        return createResponseObservable(method: .delete, url: removeUrl, params: params)
    }
    
    open func get(_ id: DataIdType, url: String? = nil, options: [String : Any] = [:]) -> Observable<HttpResponse> {
        let params = createRequestParams(options: options)
        let getUrl = url ?? "\(self.entityUrl)/\(id)"
        let progressHandler = options[Constant.RepositoryParam.progressHandler] as? ((Double) -> Swift.Void)
        return createResponseObservable(method: .get, url: getUrl, params: params, mockFile: mockEntity, progressHandler: progressHandler)
    }
    
    func createRequestParams(count: Int? = nil, options: [String: Any]) -> [String: Any] {
        self.options = options
        self.count = count
        let params = options[Constant.RepositoryParam.requestParams] as? [String: Any] ?? [:]
        return params
    }

    func createPaginationParams() -> [String: Any] {

        var params: [String: Any] = [:]
        params[Constant.RequestParam.Pagination.type] = Constant.RequestParam.Pagination.cursor
        params[Constant.RequestParam.Pagination.field] = "id"
        if let pivot = options[Constant.RepositoryParam.pivot] as? BaseEntity {
            params[Constant.RequestParam.Pagination.before] = pivot.id
        } else if let pivot = options[Constant.RepositoryParam.pivot] as? BaseDto {
            params[Constant.RequestParam.Pagination.before] = pivot.id
        }
        params[Constant.RequestParam.Pagination.limit] = count
        return params
    }

    func createDefaultParams() -> [String: Any] {
        return [:]
    }
    
    func getList(count: Int, options: [String: Any], url: String? = nil) -> Observable<HttpResponse> {
        let params = createRequestParams(count: count, options: options)
        return getList(url: url ?? self.listUrl, params: params, mockFile: self.mockList)
    }
    
    func getList(url: String, params originParams: [String: Any], mockFile: String = "") -> Observable<HttpResponse> {
        var params = createPaginationParams()
        for (key, value) in originParams {
            params[key] = value
        }
        return createResponseObservable(method: .get, url: url, params: params, mockFile: mockFile)
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
    
    open func createResponseObservable(method: HTTPMethod, url: String, params: [String: Any], mockFile: String = "", progressHandler: ((Double) -> Void)? = nil) -> Observable<HttpResponse> {
        if AppConfig.useMockResponse && !mockFile.isEmpty {
            return Observable<HttpResponse>.create({subscribe in
                self.responseMockData(mockFile: mockFile, subscribe: subscribe)
                return Disposables.create()
            })
        }
        else {
            return self.executeRequest(method: method, url: url, params: params, progressHandler: progressHandler)
        }
    }
    
    func createHeaders() -> [String: String] {
        return [:]
    }
    
    func executeRequest(method: HTTPMethod, url: String, params: [String: Any], progressHandler: ((Double) -> Void)?) -> Observable<HttpResponse> {
        var requestParams = createDefaultParams()
        for (key, value) in params {
            requestParams[key] = value
        }
        print("====================")
        print("\(method): \(url)")
        print("params: \(requestParams)")
        let headers = createHeaders()
        print("header: \(headers)")
        print("====================")
        
        return Observable<HttpResponse>.create {
            observer in
            
            // Upload
            if let fileUpload = self.getFileUpload(params: params), let name = self.getKeyWithFileUpload(params: params) {
                upload(multipartFormData: {
                    multipartFormData in
                    
                    if let data = fileUpload.data {
                        multipartFormData.append(data, withName: name, fileName: fileUpload.fileName!, mimeType: fileUpload.mimeType!)
                    }
                    else if let inputStream = fileUpload.inputStream {
                        multipartFormData.append(inputStream, withLength: fileUpload.getFileSize(), name: name, fileName: fileUpload.fileName!, mimeType: fileUpload.mimeType!)
                    }
                    else if let fileUrl = fileUpload.fileUrl {
                        multipartFormData.append(fileUrl, withName: name, fileName: fileUpload.fileName!, mimeType: fileUpload.mimeType!)
                    }
                    
                    for (key, value) in params {
                        if !(value is FileUpload), let data = String(describing: value).data(using: .utf8) {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                },
                to: url,
                headers: headers,
                encodingCompletion: {
                    encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            print(response)
                            self.processResponse(response: response, subscribe: observer)
                        }
                        if let progressHandler = progressHandler {
                            upload.uploadProgress {
                                progress in
                                progressHandler((Double)(progress.completedUnitCount) / (Double)(progress.totalUnitCount))
                            }
                        }
                    case .failure(let error):
                        print("============ AFError", (error as? AFError)?.errorDescription ?? "")
                        
                        observer.onError(error)
                    }
                })
            }
            // Download
            else if let fileDownload = self.getFileDownload(params: params) {
                var downloadRequest: DownloadRequest
                if fileDownload.isResume, let data = fileDownload.resumeData {
                    downloadRequest = download(resumingWith: data)
                }
                else {
                    var params: [String: Any] = [:]
                    for (key, value) in requestParams {
                        if !(value is FileDownload) {
                            params[key] = value
                        }
                    }
                    
                    downloadRequest = download(url, method: method, parameters: params, headers: headers) {
                        _, _ in
                        return (destinationURL: fileDownload.fileUrl!, options: .createIntermediateDirectories)
                    }
                }
                
                if let progressHandler = progressHandler {
                    downloadRequest.downloadProgress {
                        progress in
                        progressHandler((Double)(progress.completedUnitCount) / (Double)(progress.totalUnitCount))
                    }
                }
                downloadRequest.response {
                    response in
                    print(response)
                    
                    fileDownload.tempUrl = response.temporaryURL
                    
                    self.processResponse(response: response, subscribe: observer)
                }
            }
            // Other request
            else {
                request(url, method: method, parameters: requestParams, headers: headers)
                .responseJSON {
                    response in
                    print(response)
                    
                    self.processResponse(response: response, subscribe: observer)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func getFileUpload(params: [String: Any]) -> FileUpload? {
        let values = Array(params.values)
        for value in values {
            if value is FileUpload {
                return value as? FileUpload
            }
        }
        
        return nil
    }
    
    func getFileDownload(params: [String: Any]) -> FileDownload? {
        let values = Array(params.values)
        for value in values {
            if value is FileDownload {
                return value as? FileDownload
            }
        }
        
        return nil
    }
    
    func getKeyWithFileUpload(params: [String: Any]) -> String? {
        for (key, value) in params {
            if value is FileUpload {
                return key
            }
        }
        
        return nil
    }
    
    func processResponse(response: DataResponse<Any>, subscribe: AnyObserver<HttpResponse>) {
        switch response.result {
        case .success(let value):
            if let dict = value as? NSDictionary {
                let jsonResponse = HttpResponse(fromJson: JSON(dict))
                if let statusCode = response.response?.statusCode {
                    if statusCode >= 200 && statusCode < 300 {
                        subscribe.onNext(jsonResponse)
                        subscribe.onCompleted()
                    }
                    else {
                        if let meta = jsonResponse.meta {
                            meta.httpCode = statusCode
                            subscribe.on(.error(meta))
                        } else {
                            let responseData = response.response!
                            subscribe.on(.error(NSError(domain: dict["msg"] as? String ?? "", code: responseData.statusCode, userInfo: nil)))
                        }
                    }
                }
            }
        case .failure(let error):
            print(error)
            let jsonResponse = HttpResponse(fromJson: JSON(error))
            if let meta = jsonResponse.meta {
                //TODO fix me
                meta.httpCode = (error as NSError).code
                subscribe.on(.error(meta))
            } else {
                subscribe.on(.error(error))
            }
        }
    }
    
    func processResponse(response: DefaultDownloadResponse, subscribe: AnyObserver<HttpResponse>) {
        if let error = response.error {
            print(error)
            let jsonResponse = HttpResponse(fromJson: JSON(error))
            if let meta = jsonResponse.meta {
                //TODO fix me
                meta.httpCode = (error as NSError).code
                subscribe.on(.error(meta))
            } else {
                subscribe.on(.error(error))
            }
        }
        else {
            let jsonResponse = HttpResponse(fromJson: JSON(response.response!))
            subscribe.onNext(jsonResponse)
            subscribe.onCompleted()
        }
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
