//
//  FileUpload.swift
//  Exclusiv
//
//  Created by Thanh Tran on 10/31/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Photos
import AVKit
import MobileCoreServices
import AssetsLibrary
import PHAssetResourceInputStream

class FileUpload:  NSObject, NSCoding {
    private(set) var fileUrl: URL?
    private(set) var mimeType: String?
    private(set) var data: Data?
    private(set) var fileName: String?
    private(set) var inputStream: InputStream?
    private var size: UInt64 = 0
    
    var asset: PHAsset? {
        didSet {
            guard let asset = self.asset else {
                return
            }
            
            let resources = PHAssetResource.assetResources(for: asset)
            if let resource = resources.first {
                inputStream = InputStream.inputStream(withAssetResource: resource)
                
                if #available(iOS 10, *) {
                    if let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong {
                        size = UInt64(unsignedInt64)
                    }
                }
                else {
                    guard let fileUrl = self.fileUrl else {
                        return
                    }
                    
                    var keys = Set<URLResourceKey>()
                    keys.insert(URLResourceKey.totalFileSizeKey)
                    keys.insert(URLResourceKey.fileSizeKey)
                    do {
                        let URLResourceValues = try fileUrl.resourceValues(forKeys: keys)
                        if let fileSize = URLResourceValues.fileSize {
                            size = UInt64(fileSize)
                        }
                    }
                    catch {}
                }
            }
        }
    }
    
    func reloadInputStreamFromAssetData(_ completion: (() -> Void)? = nil) {
        guard let asset = self.asset else {
            return
        }
        
        ImageUtil.loadOnlyData(asset, completion: {
            _data in
            if let data = _data {
                self.inputStream = InputStream(data: data)
                completion?()
            }
        })
    }
    
    /**
     Tries to determine the mime type from the fileUrl extension.
     */
    private func getMimeType() {
        mimeType = "application/octet-stream"
        guard let url = fileUrl else { return }
        #if os(iOS) || os(OSX) //for watchOS support
            guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, url.pathExtension as CFString, nil) else { return }
            guard let str = UTTypeCopyPreferredTagWithClass(UTI.takeRetainedValue(), kUTTagClassMIMEType) else { return }
            mimeType = str.takeRetainedValue() as String
        #endif
    }
    
    /**
     Reads the data from disk or from memory. Throws an error if no data or file is found.
     */
    func getData() -> Data? {
        if let d = data {
            return d
        }
        guard let url = fileUrl else { return nil}
        fileName = url.lastPathComponent
        do {
            let d = try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
            data = d
            getMimeType()
            return d
        }
        catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func getFileSize() -> UInt64 {
        if size > 0 {
            print("============== File size", size)
            
            return size
        }
        
        if let asset = self.asset {
            if let resource = PHAssetResource.assetResources(for: asset).first {
                let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                size = UInt64(unsignedInt64!)
                
                return size
            }
        }
        
        guard let url = fileUrl else {
            if let data = getData() {
                size = UInt64(data.count)
            }
            
            print("============== File size", size)
            return size
        }
        
        do {
            let resource = try url.resourceValues(forKeys: [.fileSizeKey])
            size = UInt64(resource.fileSize!)
        } catch {
            print("================== File error", error.localizedDescription)
            
            if let data = getData() {
                size = UInt64(data.count)
            }
            
            print("============== File size", size)
            return size
        }
        
        print("============== File size", size)
        return size
    }
    
    /**
     Standard NSCoder support
     */
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.fileUrl, forKey: "fileUrl")
        aCoder.encode(self.mimeType, forKey: "mimeType")
        aCoder.encode(self.fileName, forKey: "fileName")
        aCoder.encode(self.data, forKey: "data")
    }
    
    /**
     Required for NSObject support (because of NSCoder, it would be a struct otherwise!)
     */
    override init() {
        super.init()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        fileUrl = aDecoder.decodeObject(forKey: "fileUrl") as? URL
        mimeType = aDecoder.decodeObject(forKey: "mimeType") as? String
        fileName = aDecoder.decodeObject(forKey: "fileName") as? String
        data = aDecoder.decodeObject(forKey: "data") as? Data
    }
    
    /**
     Initializes a new Upload object with a fileUrl. The fileName and mimeType will be infered.
     
     -parameter fileUrl: The fileUrl is a standard url path to a file.
     */
    convenience init(fileUrl: URL, fileName: String, size: UInt64 = 0) {
        self.init()
        self.fileUrl = fileUrl
        self.fileName = fileName
        self.size = size
        getMimeType()
    }
    
    /**
     Initializes a new Upload object with a data blob.
     
     -parameter data: The data is a NSData representation of a file's data.
     -parameter fileName: The fileName is just that. The file's name.
     -parameter mimeType: The mimeType is just that. The mime type you would like the file to uploaded as.
     */
    ///upload a file from a a data blob. Must add a filename and mimeType as that can't be infered from the data
    convenience init(data: Data, fileName: String, mimeType: String) {
        self.init()
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
    
    func copyToLocal() {
        guard let fileUrl = self.fileUrl else {
            return
        }
        
        let fileManager = FileManager.default
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let directoryURL = tempDirectoryURL.appendingPathComponent("org.alamofire.manager/multipart.form.data")
        let destinationURL = directoryURL.appendingPathComponent(UUID().uuidString)
        
        do {
            // Create directory inside serial queue to ensure two threads don't do this in parallel
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("========== File error", error.localizedDescription)
        }
        
        do {    // but just copy from the video URL to the destination URL
            try fileManager.copyItem(at: fileUrl, to: destinationURL)
            self.fileUrl = destinationURL
        }
        catch {
            print("========== File error", error.localizedDescription)
        }
    }
    
    func removeLocal() {
        guard let fileUrl = self.fileUrl else {
            return
        }
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: fileUrl)
        }
        catch {
            print("========== File error", error.localizedDescription)
        }
    }
}
