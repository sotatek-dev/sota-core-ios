//
//  FileUpload.swift
//  Exclusiv
//
//  Created by Thanh Tran on 10/31/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import MobileCoreServices

class FileUpload:  NSObject, NSCoding {
    private(set) var fileUrl: URL?
    private(set) var mimeType: String?
    private(set) var data: Data?
    private(set) var fileName: String?
    private var size: UInt64 = 0
    
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
            return size
        }
        
        guard let url = fileUrl else {
            if let data = getData() {
                size = UInt64(data.count)
            }
            
            return size
        }
        
        do {
            let resource = try url.resourceValues(forKeys: [.fileSizeKey])
            size = UInt64(resource.fileSize!)
        } catch {
            print("================== File error", error.localizedDescription)
        }
        
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
}
