desc "This task is called by the Heroku scheduler add-on"

task :update_measures => :environment do

  require 'google/apis/gmail_v1'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'


  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'Gmail API Ruby Quickstart'
  CLIENT_SECRETS_PATH = 'client_secret.json'
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                               "gmail-ruby-quickstart.yaml")
  SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_MODIFY

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
    client_id = Google::Auth::ClientId.from_hash("installed" => {"client_id" => "115991364553-lo8i94ai8j134mpn8um9och6lqm4vbof.apps.googleusercontent.com", "project_id" => "focus-terra-136423", "auth_uri" => "https://accounts.google.com/o/oauth2/auth", "token_uri" => "https://accounts.google.com/o/oauth2/token", "auth_provider_x509_cert_url" => "https://www.googleapis.com/oauth2/v1/certs", "client_secret" => "_ODOItwhJJzoB06stZJaKdu5", "redirect_uris" => ["urn:ietf:wg:oauth:2.0:oob", "http://localhost"]})
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
        client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(
          base_url: OOB_URI)
      puts "Open the following URL in the browser and enter the " +
               "resulting code after authorization"
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI)
    end
    credentials
  end

# Initialize the API
  service = Google::Apis::GmailV1::GmailService.new
  service.client_options.application_name = APPLICATION_NAME
  service.authorization = authorize

# Show the user's labels
  user_id = 'me'
#result = service.list_user_labels(user_id)

#query = "subject:measures AND subject:Daily"
  query = "subject:measures AND subject:name AND subject:time AND subject:value AND is:unread"

  result = service.list_user_messages(user_id, q: query)

  puts result
  unless result.messages.nil?
    result.messages.each { |message|
      body = service.get_user_message(user_id, message.id).snippet.to_s

      # part messages header name subject value
      puts service.get_user_thread(user_id, message.thread_id).id.to_s
      temp = service.get_user_thread(user_id, message.thread_id).messages
      tempStr = temp.to_s
      tempStr = tempStr.split("\"Subject").last
      tempStr = tempStr.split("Google").first
      subject = tempStr[11.. -7].gsub('\"', '"')
      begin
        subjectJSON = JSON.parse(subject.to_s)
        datetime = DateTime.parse(subjectJSON["measures"][0]["time"])
        name = subjectJSON["measures"][0]["name"]
        value = subjectJSON["measures"][0]["value"].tr(',', '')
        thingname = subjectJSON["measures"][0]["user"]
        unit = subjectJSON["measures"][0]["unit"]
        source = subjectJSON["measures"][0]["source"]
        comment = ""
        if Measure.where(name: name, datetime: datetime, thingname: thingname).exists?
          @measure = Measure.where(datetime: datetime, thingname: thingname).first
          @measure.title = subject
          @measure.value = value
          @measure.thingname = thingname
          @measure.save #
        else
          @measure = Measure.new("title" => subject, "body" => body, "datetime" => datetime, "name" => name, "value" => value, "thingname" => thingname, "unit" => unit, "source" => source, "comment" => comment, "active" => true)
          @measure.save
        end
        modifyRequest = Google::Apis::GmailV1::ModifyMessageRequest.new
        modifyRequest.remove_label_ids = ["UNREAD"]
        service.modify_message(user_id, message.id, modifyRequest).update!
      rescue
        puts "inside rescue..."
        next
      end
    }
    puts "Finished..."
  end
end

task :update_measures_text => :environment do

  require 'fileutils'


  array = '

[16-09-09 06:16:34:698 BST] subject "{"measures":[{"name":"ivc_diameter_max","time":"2016-09-07T05:16:31.142Z","value":"18","unit":"mm","source":"E347689_virtual_device","user":"E347689"}]}".
[16-09-09 06:16:38:225 BST] subject "{"measures":[{"name":"ivc_diameter_min","time":"2016-09-07T05:16:34.777Z","value":"8","unit":"mm","source":"E347689_virtual_device","user":"E347689"}]}".
[16-09-09 06:16:41:944 BST] subject "{"measures":[{"name":"weight","time":"2016-09-07T05:16:38.302Z","value":"63.1","unit":"mm","source":"E347689_virtual_device","user":"E347689"}]}".
[16-09-09 06:16:45:190 BST] subject "{"measures":[{"name":"pap","time":"2016-09-07T05:16:42.024Z","value":"7.1","unit":"mm","source":"E347689_virtual_device","user":"E347689"}]}".
[16-09-09 06:17:03:002 BST] subject "{"measures":[{"name":"ivc_diameter_max","time":"2016-09-07T05:16:45.301Z","value":"20","unit":"mm","source":"E452901_virtual_device","user":"E452901"}]}".
[16-09-09 06:17:07:183 BST] subject "{"measures":[{"name":"ivc_diameter_min","time":"2016-09-07T05:17:03.093Z","value":"12","unit":"mm","source":"E452901_virtual_device","user":"E452901"}]}".
[16-09-09 06:17:14:649 BST] subject "{"measures":[{"name":"weight","time":"2016-09-07T05:17:07.294Z","value":"84.9","unit":"mm","source":"E452901_virtual_device","user":"E452901"}]}".
[16-09-09 06:17:18:471 BST] subject "{"measures":[{"name":"pap","time":"2016-09-07T05:17:14.725Z","value":"3.2","unit":"mm","source":"E452901_virtual_device","user":"E452901"}]}".
[16-09-09 06:17:22:063 BST] subject "{"measures":[{"name":"ivc_diameter_max","time":"2016-09-07T05:17:18.580Z","value":"23","unit":"mm","source":"E299845_virtual_device","user":"E299845"}]}".
[16-09-09 06:17:27:749 BST] subject "{"measures":[{"name":"ivc_diameter_min","time":"2016-09-07T05:17:22.139Z","value":"11","unit":"mm","source":"E299845_virtual_device","user":"E299845"}]}".
[16-09-09 06:17:34:558 BST] subject "{"measures":[{"name":"weight","time":"2016-09-07T05:17:27.825Z","value":"72.2","unit":"mm","source":"E299845_virtual_device","user":"E299845"}]}".
[16-09-09 06:17:38:035 BST] subject "{"measures":[{"name":"pap","time":"2016-09-07T05:17:34.641Z","value":"12.6","unit":"mm","source":"E299845_virtual_device","user":"E299845"}]}".
[16-09-09 06:17:43:322 BST] subject "{"measures":[{"name":"ivc_diameter_max","time":"2016-09-07T05:17:38.167Z","value":"16","unit":"mm","source":"E321859_virtual_device","user":"E321859"}]}".
[16-09-09 06:17:46:473 BST] subject "{"measures":[{"name":"ivc_diameter_min","time":"2016-09-07T05:17:43.398Z","value":"7","unit":"mm","source":"E321859_virtual_device","user":"E321859"}]}".
[16-09-09 06:17:50:643 BST] subject "{"measures":[{"name":"weight","time":"2016-09-07T05:17:46.550Z","value":"80.4","unit":"mm","source":"E321859_virtual_device","user":"E321859"}]}".
[16-09-09 06:17:54:346 BST] subject "{"measures":[{"name":"pap","time":"2016-09-07T05:17:50.725Z","value":"4","unit":"mm","source":"E321859_virtual_device","user":"E321859"}]}".
[16-09-09 06:17:57:721 BST] subject "{"measures":[{"name":"ivc_diameter_max","time":"2016-09-07T05:17:54.595Z","value":"15","unit":"mm","source":"E437382_virtual_device","user":"E437382"}]}".
[16-09-09 06:18:01:084 BST] subject "{"measures":[{"name":"ivc_diameter_min","time":"2016-09-07T05:17:57.796Z","value":"8","unit":"mm","source":"E437382_virtual_device","user":"E437382"}]}".
[16-09-09 06:18:04:510 BST] subject "{"measures":[{"name":"weight","time":"2016-09-07T05:18:01.158Z","value":"66","unit":"mm","source":"E437382_virtual_device","user":"E437382"}]}".
[16-09-09 06:18:07:990 BST] subject "{"measures":[{"name":"pap","time":"2016-09-07T05:18:04.590Z","value":"6","unit":"mm","source":"E437382_virtual_device","user":"E437382"}]}".
[16-09-09 06:18:11:486 BST] subject "{"measures":[{"name":"ivc_diameter_max","time":"2016-09-07T05:18:08.104Z","value":"17","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-09 06:18:15:529 BST] subject "{"measures":[{"name":"ivc_diameter_min","time":"2016-09-07T05:18:11.570Z","value":"8","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-09 06:18:20:250 BST] subject "{"measures":[{"name":"weight","time":"2016-09-07T05:18:15.605Z","value":"74.2","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-09 06:18:24:382 BST] subject "{"measures":[{"name":"pap","time":"2016-09-07T05:18:20.337Z","value":"7.4","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-09 06:18:28:479 BST] subject "{"measures":[{"name":"ivc_diameter_max","time":"2016-09-07T05:18:24.514Z","value":"18","unit":"mm","source":"E401673_virtual_device","user":"E401673"}]}".
[16-09-09 06:18:32:186 BST] subject "{"measures":[{"name":"ivc_diameter_min","time":"2016-09-07T05:18:28.570Z","value":"9","unit":"mm","source":"E401673_virtual_device","user":"E401673"}]}".
[16-09-09 06:18:35:410 BST] subject "{"measures":[{"name":"weight","time":"2016-09-07T05:18:32.256Z","value":"58.9","unit":"mm","source":"E401673_virtual_device","user":"E401673"}]}".
[16-09-09 06:18:38:697 BST] subject "{"measures":[{"name":"pap","time":"2016-09-07T05:18:35.484Z","value":"4","unit":"mm","source":"E401673_virtual_device","user":"E401673"}]}".
[16-09-09 06:18:42:017 BST] subject "{"measures":[{"name":"ivc_diameter_max","time":"2016-09-07T05:18:38.805Z","value":"19","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-09 06:18:45:271 BST] subject "{"measures":[{"name":"ivc_diameter_min","time":"2016-09-07T05:18:42.097Z","value":"18","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-09 06:18:48:565 BST] subject "{"measures":[{"name":"weight","time":"2016-09-07T05:18:45.348Z","value":"87.3","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-09 06:18:51:975 BST] subject "{"measures":[{"name":"pap","time":"2016-09-07T05:18:48.650Z","value":"15.1","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
xxxxxxxxxxxxxxxxxxxxxxxxxxxxsubjectxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
'.split(/subject/)


  array.each do |item|

      begin

        item = item[2...-31]
        subjectJSON = JSON.parse(item.to_s)
        datetime = DateTime.parse(subjectJSON["measures"][0]["time"])
        name = subjectJSON["measures"][0]["name"]
        value = subjectJSON["measures"][0]["value"].tr(',', '')
        thingname = subjectJSON["measures"][0]["user"]
        unit = subjectJSON["measures"][0]["unit"]
        source = subjectJSON["measures"][0]["source"]
        comment = ""
        if Measure.where(name: name, datetime: datetime, thingname: thingname).exists?
          @measure = Measure.where(datetime: datetime, thingname: thingname).first
          @measure.title = subject
          @measure.value = value
          @measure.thingname = thingname
          @measure.save #
        else
          @measure = Measure.new("title" => item, "body" => "", "datetime" => datetime, "name" => name, "value" => value, "thingname" => thingname, "unit" => unit, "source" => source, "comment" => comment, "active" => true)
          @measure.save
        end
      rescue
        puts "inside rescue..."
        next
      end

      end
    puts "Finished..."
  end




