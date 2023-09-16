type
    TaskStatus* = enum
        Active,
        InProgress,
        UnderReview,
        Completed
    User* = object
        username*: string
        password*: string
        local*:    bool
    Task* = object
        title*:string
        status*: int
        #description*:string
        assignees*: seq[string]
        watchers*: seq[string]
    Project* = object
        code*: string
        title*: string
        #description*:string
        items*: seq[Task]
    ProjectPreview* = object
        code*: string
        title*: string
    TaskPreview* = object
        code*: string
        status*: int
        title*: string