http = require('http')
fs = require('fs')
path = require('path')
mime = require('mime')
cache = {}

send404 = (response) ->
  response.writeHead 404, {'Content-Type': 'text/plain'}
  response.write 'Error 404: resource not found.'
  response.end()
  
sendFile = (response, filePath, fileContents) ->
  response.writeHead 200, {'content-type': mime.lookup(path.basename(filePath))}
  response.end(fileContents)

serveStatic = (response, cache, absPath) ->
  if cache[absPath]
    sendFile(response, absPath, cache[absPath])
  else
    fs.exists absPath, (exists) ->
      if exists
        fs.readFile(absPath, (err, data) ->
          if err
            send404 response
          else
            cache[absPath] = data
            sendFile(response, absPath, data)
        )
      else
        send404 response

server = http.createServer (request, response) ->
  filePath = false
  filePath = if request.url == '/' then 'public/index.html' else "public#{request.url}"
  absPath = "./#{filePath}"
  serveStatic(response, cache, absPath)
  
# Start server
server.listen 3000, ->
  console.log 'Server listening on port 3000.'
  
  
  
