import Foundation

extension URL {

    public init(
        userSessionID: String,
        directory: FileManager.SearchPathDirectory = .documentDirectory
    ) {
        self = URL.userSessionsDirectory(in: directory) + userSessionID
    }
    
    public init?(directory: FileManager.SearchPathDirectory) {
        if let value = NSSearchPathForDirectoriesInDomains(
            directory, .userDomainMask, true).first.map({ URL(fileURLWithPath: $0) }
            ) {
            self = value
        } else {
            return nil
        }
    }

    static func userSessionsDirectory(
        in directory: FileManager.SearchPathDirectory = .documentDirectory
    ) -> URL {
        let url = URL(directory: directory)!
        return url + IDGen.default + "usersessions"
    }
}

public func += (url: inout URL, component: String) {
    url.appendPathComponent(component)
}

public func + (url: URL, component: String) -> URL {
    return url.appendingPathComponent(component)
}
