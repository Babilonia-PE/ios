//
//  APIRequestProxy.swift
//  Core
//
//

import YALAPIClient

public class APIRequestProxy: MultipartAPIRequest {
    
    public var path: String
    public var method: APIRequestMethod
    public var encoding: APIRequestEncoding?
    public var parameters: [String: Any]?
    public var headers: [String: String]?
    public var multipartFormData: ((MultipartFormDataType) -> Void)
    public var progressHandler: ProgressHandler?
    
    public init(request: APIRequest) {
        path = request.path
        method = request.method
        encoding = request.encoding
        parameters = request.parameters
        headers = request.headers
        multipartFormData = (request as? MultipartAPIRequest)?.multipartFormData ?? { _ in }
        progressHandler = (request as? DownloadAPIRequest)?.progressHandler
    }
}
