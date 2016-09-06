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

[16-09-06 01:23:27:579 PDT] subject "{"measures":[{"name":"weight","time":"2016-09-06T08:23:20.944Z","value":"88.1","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:23:32:951 PDT] subject "{"measures":[{"name":"weight","time":"2016-09-05T08:23:27.667Z","value":"85.4","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:23:38:932 PDT] subject "{"measures":[{"name":"weight","time":"2016-09-04T08:23:33.036Z","value":"86.5","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:23:44:337 PDT] subject "{"measures":[{"name":"weight","time":"2016-09-03T08:23:39.021Z","value":"87.2","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:24:04:552 PDT] subject "{"measures":[{"name":"weight","time":"2016-09-02T08:23:44.425Z","value":"85.3","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:24:10:638 PDT] subject "{"measures":[{"name":"weight","time":"2016-09-01T08:24:04.655Z","value":"87.3","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:24:25:431 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-31T08:24:10.725Z","value":"87.1","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:24:43:450 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-30T08:24:27.638Z","value":"87.6","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:24:50:008 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-29T08:24:43.971Z","value":"85.1","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:24:54:017 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-28T08:24:50.154Z","value":"88","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:24:58:470 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-27T08:24:54.393Z","value":"88.4","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:25:05:805 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-26T08:24:58.548Z","value":"87.4","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:25:14:863 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-25T08:25:05.888Z","value":"84.9","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:25:20:439 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-24T08:25:15.398Z","value":"87.8","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:25:27:146 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-23T08:25:20.534Z","value":"87.9","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:25:42:369 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-22T08:25:28.168Z","value":"85.3","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:25:47:156 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-21T08:25:42.450Z","value":"85.2","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:25:59:176 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-20T08:25:47.237Z","value":"87.1","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:26:07:012 PDT] subject "{"measures":[{"name":"pap","time":"2016-09-06T08:25:59.424Z","value":"8.2","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:26:15:238 PDT] subject "{"measures":[{"name":"pap","time":"2016-09-05T08:26:08.455Z","value":"10.9","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:26:23:688 PDT] subject "{"measures":[{"name":"pap","time":"2016-09-04T08:26:15.469Z","value":"15.9","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:26:29:442 PDT] subject "{"measures":[{"name":"pap","time":"2016-09-03T08:26:23.773Z","value":"11.4","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:26:36:042 PDT] subject "{"measures":[{"name":"pap","time":"2016-09-02T08:26:29.562Z","value":"8.6","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:26:40:698 PDT] subject "{"measures":[{"name":"pap","time":"2016-09-01T08:26:36.202Z","value":"15.1","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:26:46:304 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-31T08:26:40.828Z","value":"14.2","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:26:55:275 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-30T08:26:46.421Z","value":"11.9","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:26:59:089 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-29T08:26:55.359Z","value":"14.2","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:27:04:280 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-28T08:26:59.174Z","value":"10.5","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:27:08:141 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-27T08:27:04.357Z","value":"8.3","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:27:12:394 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-26T08:27:08.257Z","value":"11.3","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:27:18:926 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-25T08:27:12.499Z","value":"15.2","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:27:30:002 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-24T08:27:19.041Z","value":"12.3","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:27:40:638 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-23T08:27:33.384Z","value":"9.4","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:27:46:448 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-22T08:27:40.743Z","value":"11.3","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:27:51:634 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-21T08:27:46.583Z","value":"15.8","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
[16-09-06 01:27:56:118 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-20T08:27:51.750Z","value":"15.3","unit":"mm","source":"E356297_virtual_device","user":"E356297"}]}".
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




