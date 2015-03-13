# Description:
#   Microsoft Translator API
#   toLanguageCode description: https://msdn.microsoft.com/en-us/library/hh456380.aspx
#
# Dependencies:
#   None
#
# Commands:
#   hubot translator <toLanguageCode>
#
# Author:
#   Hirokazu Miyaji

getAccessToken = (robot, callback) ->
  clientId = process.env.MICROSOFT_TRANSLATE_CLIENT_ID
  secretKey = process.env.MICROSOFT_TRANSLATE_SECRET_KEY
  return null unless clientId
  return null unless secretKey

  clientId = encodeURIComponent clientId
  secretKey = encodeURIComponent secretKey

  robot.http("https://datamarket.accesscontrol.windows.net/v2/OAuth2-13")
    .header("ContentType", "application/x-www-form-urlencoded")
    .post("client_id=#{clientId}&client_secret=#{secretKey}&scope=http://api.microsofttranslator.com&grant_type=client_credentials") (err, res, body) ->
      return if err
      parseBody = JSON.parse body

      accessToken = "Bearer #{parseBody.access_token}"
      callback accessToken

getTransLanguage = (robot, token, text, callback) ->
  robot.http("http://api.microsofttranslator.com/V2/Ajax.svc/Detect?appId=&text=#{text}")
    .header("Authorization", token)
    .get() (err, res, body) ->
      return if err
      callback eval body

module.exports = (robot) ->
  robot.hear /translator (ar|bg|ca|zh-CHS|zh-CHT|cs|da|nl|en|et|fi|fr|de|el|ht|he|hi|mww|hu|id|it|ja|tlh|tlh-Qaak|ko|lv|lt|ms|mt|no|fa|pl|pt|ro|ru|sk|sl|es|sv|th|tr|uk|ur|vi|cy) (.*)/i, (msg) ->
    toLanguage = msg.match[1]
    message = msg.match[2]
    return unless message

    message = encodeURIComponent message

    getAccessToken robot, (token) ->
      return unless token
      getTransLanguage robot, token, message, (fromLanguage) ->
        msg.http("http://api.microsofttranslator.com/v2/Ajax.svc/Translate?text=#{message}&from=#{fromLanguage}&to=#{toLanguage}")
          .header("Authorization", token)
          .get() (err, res, body) ->
            msg.send eval body
