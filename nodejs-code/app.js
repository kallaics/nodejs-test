let http = require('http')
server = http.createServer(function(request, response) {
    response.write('Hello World')
    response.end()
})

server.listen(3000)
console.log ("Server Running")
