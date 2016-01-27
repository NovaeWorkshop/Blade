import Foundation
import Sack

public class Server {
    private var port        : UInt16
    private var sock        : Int32
    private var httpParser  = HttpParser()
    private var httpWriter  = HttpWriter()
    
    //private var running : Bool

    public init? (port aPort: UInt16, address: String = "0.0.0.0") {
        port = aPort
        sock = socket(PF_INET, SOCK_STREAM, 0)

        var addr = sockaddr_in()
        addr.sin_len = UInt8(sizeofValue(addr))
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = aPort.bigEndian
        inet_aton(address, &addr.sin_addr)
        let err = withUnsafePointer(&addr) {
            return bind(sock, UnsafePointer($0), UInt32(sizeofValue(addr)))
        }
        if (err == -1) {
            return nil
        }
    }

    public func run (app: Sack.App) {
        listen(sock, 256)
        while (true) {
            let client = accept(sock, nil, nil)
            let req = httpParser.parse(client)
            if (req != nil) {
                let res = app.call(req!)
                httpWriter.write(client, res)
            }
            close(client)
        }
    }
}
