import jester, base64, strutils

type
  Credentials = ref object
    username*: string
    password*: string 

proc basicAuth*(request: Request): Credentials =
  var r = Credentials()
  try:
    # Проверяем что метод авторизации является Basic Auth
    if request.headers["Authorization"].startswith("Basic "):
      
      # Декодируем Base64
      let credentialsBase64 = request.headers["Authorization"][6..request.headers["Authorization"].len-1]
      let credentials = base64.decode(credentialsBase64)

      # Парсим логин и пароль для входа
      let credentialsParts = credentials.split(":", 2)
      if credentialsParts.len == 2:
        r.username = credentialsParts[0]
        r.password = credentialsParts[1]
  except:
    # do nothing
    let x = 1
  return r