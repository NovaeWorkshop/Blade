import Foundation
import Sack

class HttpParser {
    class SocketBuffer {
        private var socket  : Int32
        private var buffer  : NSMutableData

        init (_ aSocket: Int32) {
            socket = aSocket
            buffer = NSMutableData()
        }

        func read (size: Int, _ aBuffer: NSMutableData) -> Int {
            if (buffer.length > 0) {
                let s = size > buffer.length ? buffer.length : size
                aBuffer.appendData(buffer.subdataWithRange(NSMakeRange(0, s)))
                buffer = NSMutableData(data: buffer.subdataWithRange(NSMakeRange(s, buffer.length - s)))
                return s
            } else {
                let buf = NSMutableData(capacity: size)!
                let s = recv(socket, buf.mutableBytes, size, 0)
                aBuffer.appendBytes(buf.bytes, length: s)
                return s
            }
        }

        func unread (data: NSData) {
            buffer.appendData(data)
        }
    }

    init () {

    }
    
    func parse (socket: Int32) -> Sack.Request? {
        let sock = SocketBuffer(socket)
        let reqOpt = readRequestHeaders(sock)
        if (reqOpt == nil) {
            return nil
        }
        let req = reqOpt!
        let buffer = String(data: req, encoding: NSUTF8StringEncoding)!
        var lines = buffer.componentsSeparatedByString("\r\n")
        let http = lines[0].componentsSeparatedByString(" ")
        let sackReq = Sack.Request(http[0], http[1])
        lines.removeAtIndex(0)
        for l in lines {
            let r = l.rangeOfString(":")
            if (r == nil) {
                continue
            }
            let header = l.substringWithRange(l.startIndex..<r!.startIndex)
            let value = l.substringWithRange(r!.endIndex..<l.endIndex)
            let valueArray = value.componentsSeparatedByString(",")
            for v in valueArray {
                let trimVal = v.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                sackReq.headers.add(header, trimVal)
            }
        }
        if let hSize = sackReq.headers.get("Content-Length")?[0] {
            if let s = Int(hSize) {
                if (s > 0) {
                    sackReq.body = readRequestBody(sock, size: s)
                }
            }
        }
        return sackReq
    }

    private func readRequestHeaders (socket: SocketBuffer) -> NSData? {
        let readSize = 32768
        let request = NSMutableData()
        let term: [UInt8] = [13, 10, 13, 10]
        let termData = NSData(bytes: term, length: 4)
        while (true)
        {
            let size = socket.read(readSize, request)
            if (size == 0) {
                return nil
            }
            let range = request.rangeOfData(termData, options: [], range: NSMakeRange(0, request.length))
            if (range.location != NSNotFound) {
                let headers = request.subdataWithRange(NSMakeRange(0, range.location))
                let data = request.subdataWithRange(NSMakeRange(range.location + 4, request.length - (range.location + 4)))
                socket.unread(data)
                return headers
            }
        }
    }

    private func readRequestBody (socket: SocketBuffer, size: Int) -> NSData {
        var s = 0
        let data = NSMutableData(capacity: size)!
        while (s < size) {
            s += socket.read(size - s, data)
        }
        return data
    }
}
