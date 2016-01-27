import Blade
import Sack

class TestApp : Sack.App {
    func call (req: Sack.Request) -> Sack.Response {
        let res = Sack.Response()
        res.headers.set("Content-Type", "text/html")
        res.write("<!doctype html><html><head><title>Blade</title></head><body>")
        res.write("<h1>\(req.verb) \(req.path)</h1><p>")
        for (header, values) in req.headers {
            res.write("\(header): \(values)<br>")
        }
        res.write("</p>")
        res.write("</body></html>")
        return res
    }
}

if let serv = Blade.Server(port: 8080) {
    serv.run(TestApp())
} else {
    print("Could not create server")
}
