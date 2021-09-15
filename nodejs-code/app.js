const TXT = process.env.TXT || 'Hello world!';

let http = require('http')
server = http.createServer(function(request, response) {
    response.write(TXT)
    response.end()
})

server.listen(3000)
console.log ("Server Running")
