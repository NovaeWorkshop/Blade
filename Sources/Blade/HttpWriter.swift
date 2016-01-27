import Foundation
import Sack

class HttpWriter {
    /* TODO: add full messages */
    static let statusMsg: [Int: String] = [
        200: "Ok",
        404: "Not Found"
    ]

    init () {

    }

    func write (socket: Int32, _ res: Sack.Response) {
        let status = HttpWriter.statusMsg[res.status] != nil ? HttpWriter.statusMsg[res.status]! : "Unknown"
        var buffer = "HTTP/1.1 \(res.status) \(status)\r\n"
        for (header, values) in res.headers {
            if (values.isEmpty) {
                continue
            }
            buffer += header + ": "
            var str : String? = nil
            for v in values {
                if (str == nil) {
                    str = v
                } else {
                    str = str! + ", " + v
                }
            }
            buffer += str!
            buffer += "\r\n"
        }
        buffer += "\r\n"
        write(socket, buffer)
        for b in res.body {
            write(socket, b)
        }
    }

    private func write (socket: Int32, _ data: NSData) {
        send(socket, data.bytes, data.length, 0)
    }

    private func write (socket: Int32, _ string: String) {
        write(socket, string.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
}
