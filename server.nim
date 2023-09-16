import jester, json, marshal, libraries/basic_auth, re, os, system, sequtils, modules/types

proc authorized(request: Request): bool =
    try:
        var auth = request.basicAuth()
        if auth.username.len > 0:
            try:
                var users = parseJson(readFile("storage/users.json"))
                for user_id, user in users.to(seq[User]):
                    try:
                        if user.username == auth.username and user.password == auth.password:
                            return true
                    except:
                        echo "Failet to fetch user at position " & $user_id
            except:
                echo "Failed to fetch users.json"
    except:
        echo "Failed to authenticate"

    return false

proc fetchSuitableTasksByUsername(username: string): JsonNode =
    let board = parseJson("[]")
    let projects = parseJson(readFile("storage/tasks.json"))
    try:
        for project_id, project in projects.to(seq[Project]):
            try:
                for task_id, task in project.items:
                    var valid = false
                    try:
                        for member in task.assignees:
                            if member == username: valid = true
                        for member in task.watchers:
                            if member == username: valid = true
                        if valid:
                            board.add %*{
                                "code": project.code & "-" & $task_id,
                                "status": task.status,
                                "title": task.title
                            }
                    except:
                        echo "Failed to fetch task " & project.title & "-" & $task_id
            except:
                echo "Failed to fetch project at position " & $project_id
    except:
        echo "Failed to fetch tasks.json"
    return board

proc fetchProjects(username: string): JsonNode =
    let projects = parseJson(readFile("storage/tasks.json"))
    return %projects.to(seq[ProjectPreview])

settings:
    port = Port(3080)

routes:

    get "/api/status":
        if not request.authorized(): halt Http401, {"WWW-Authenticate": "Basic here"}, "auth required"
        resp %*{ "status": true }

    get "/api/dashboard":
        if not request.authorized(): halt Http401, {"WWW-Authenticate": "Basic here"}, "auth required"
        resp fetchSuitableTasksByUsername(request.basicAuth().username)
    
    get "/api/projects":
        if not request.authorized(): halt Http401, {"WWW-Authenticate": "Basic here"}, "auth required"
        resp fetchProjects(request.basicAuth().username)

    post "/api/dashboard":
        if not request.authorized(): halt Http401, {"WWW-Authenticate": "Basic here"}, "auth required"
        resp Http201, "boop"