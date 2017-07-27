
http = {}


function http.callback(code, msg)
    if code == 200 then
        http._callback(true, msg)
        return
    else 
		http._callback(false, msg)
	end
end


function http.get(url, filename, callback)
    http._callback = callback
    http._url = url
    local request = network.createHTTPRequest( function( event )
        local ok = (event.name == "completed")
        local request =  event.request
		local code = nil
		local response = ""
		
        if not ok then
			code = request:getErrorCode()
			response = request:getErrorMessage()
       
        else 
			code = request:getResponseStatusCode()
			if code == 200 then
				if not filename then
					response = request:getResponseString()
				else
					request:saveResponseData( filename )
				end
			else
			
			end
		end

		request:release()
        return http.callback(code, response)
    end, url, "GET" )
	
    request:addRequestHeader( "Connection: Keep-Alive" )
    request:setTimeout( 30 )
    request:start()
end

function http.download(url, filename, callback)
    print("download url", url)
    http.get(url, filename, callback)
end
