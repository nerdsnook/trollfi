

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)

   local rnrn=0
   local Status = 0
   local responseBytes = 0
   local method=""
   local url=""
   local vars=""

   conn:on("receive",function(conn, payload)

    if Status==0 then
        _, _, method, url, vars = string.find(payload, "([A-Z]+) /([^?]*)%??(.*) HTTP")
        -- print(method, url, vars)
    end


    -- Check if wifi-credentials have been supplied
    if vars~=nil and parse_TROLLFI(vars) then
        node.restart()
    end

    if url == "favicon.ico" then
        conn:send("HTTP/1.1 404 file not found")
        responseBytes = -1
        return
    end

    -- Only support one sending one file
    url="wifi.html"
    responseBytes = 0

    conn:send("HTTP/1.1 200 OK\r\n\r\n")

  end)

  conn:on("sent",function(conn)
    if responseBytes>=0 and method=="GET" then
        if file.open(url, "r") then
            file.seek("set", responseBytes)
            local line=file.read(512)
            file.close()
            if line then
                conn:send(line)
                responseBytes = responseBytes + 512

                if (string.len(line)==512) then
                    return
                end
            end
        end
    end

    conn:close()
  end)
end)
print("HTTP Server: Started")


function parse_TROLLFI(vars)
    if vars == nil or vars == "" then
        return false
    end

    local _, _, wifi_ssid = string.find(vars, "wifi_ssid\=([^&]+)")

    file.open("TROLLFI", "w+")
    file.writeline(wifi_ssid)


    file.flush()
    file.close()
    return true
end

    local wifi_ssid

    if file.open("TROLLFI", "r") then
        wifi_ssid = file.read("\n")
        wifi_ssid = string.format("%s", wifi_ssid:match( "^%s*(.-)%s*$" ))
        file.close()
    end
   
     cfg={}
     cfg.ssid=wifi_ssid
     wifi.ap.config(cfg)
        print("ok")
         wifi.setmode(wifi.SOFTAP)
