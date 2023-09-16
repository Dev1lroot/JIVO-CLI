import std/asynchttpserver, std/asyncdispatch, re, os, strutils, json, marshal, system, osproc, uri3, rdstdin, httpclient, base64, modules/types

echo "Rоbототь JIVO! (TM)"
echo "Client started"

var hostname = ""
var username = ""
var password = ""
var mode     = ""

for param in commandLineParams():
    if mode == "-h": hostname = param
    if mode == "-u": username = param
    if mode == "-p": password = param
    mode = param

proc basicAuth(client: HttpClient, username, password: string)=
    client.headers["Authorization"] = "Basic " & base64.encode(username & ":" & password)

proc newJivoClient(): HttpClient =
    var client = newHttpClient()
    client.headers["Content-Type"] = "application/json"
    client.headers["Accept-Content"] = "application/json"
    client.headers["Client-Version"] = "1.0"
    client.basicAuth(username,password)
    return client

proc dashboard()=
    try:
        var client = newJivoClient()
        var boards = parseJson($client.getContent("http://" & hostname & "/api/dashboard"))
        for task in boards.to(seq[TaskPreview]):
            try:
                echo task.code & " - " & task.title
            except:
                echo "Failed to fetch a task"
    except:
        echo "Failed to fetch tasks"

proc runtime()=
    var command = readLineFromStdin(username & ": ")

    if command == "db" or command == "dashboard" or command == "tasks":
        dashboard()
    if command == "pr" or command == "projects":
        dashboard()
    runtime()

proc authorize()=

    if hostname.len == 0: hostname = readLineFromStdin "Hostname: "
    if username.len == 0: username = readLineFromStdin "Username: "
    if password.len == 0: password = readLineFromStdin "Password: "

    try:
        var client = newJivoClient()

        try:
            echo $client.getContent("http://" & hostname & "/api/status")
        except HttpRequestError as e:
            echo e.msg
            username = ""
            password = ""
            authorize()
    except:
        echo "Remote host not found, try again"
        hostname = ""
        authorize()

    runtime()

authorize()