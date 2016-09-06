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

[16-09-06 00:44:57:580 PDT] subject "{"measures":[{"name":"weight","time":"2016-09-06T07:44:44.314Z","value":"74.5","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:45:13:384 PDT] subject "{"measures":[{"name":"weight","time":"2016-09-05T07:44:57.664Z","value":"74.3","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:45:24:992 PDT] subject "{"measures":[{"name":"weight","time":"2016-09-04T07:45:14.146Z","value":"74.4","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:45:35:872 PDT] subject "{"measures":[{"name":"weight","time":"2016-09-03T07:45:26.739Z","value":"74.4","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:45:43:447 PDT] subject "{"measures":[{"name":"weight","time":"2016-09-02T07:45:36.011Z","value":"75.2","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:45:48:507 PDT] subject "{"measures":[{"name":"weight","time":"2016-09-01T07:45:43.597Z","value":"74.8","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:45:54:193 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-31T07:45:48.652Z","value":"74.1","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:46:00:028 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-30T07:45:54.392Z","value":"74.2","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:46:05:215 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-29T07:46:00.108Z","value":"75.2","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:46:10:870 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-28T07:46:05.388Z","value":"74.3","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:46:16:099 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-27T07:46:10.956Z","value":"74.2","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:46:22:247 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-26T07:46:16.188Z","value":"75.1","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:46:27:175 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-25T07:46:22.353Z","value":"74.3","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:46:32:914 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-24T07:46:27.323Z","value":"74.6","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:46:41:817 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-23T07:46:33.094Z","value":"74","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:46:47:725 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-22T07:46:41.921Z","value":"66.4","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:46:57:404 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-21T07:46:47.842Z","value":"65.7","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:47:02:339 PDT] subject "{"measures":[{"name":"weight","time":"2016-08-20T07:46:57.498Z","value":"66.3","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:47:07:263 PDT] subject "{"measures":[{"name":"pap","time":"2016-09-06T07:47:02.431Z","value":"3.7","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:47:11:460 PDT] subject "{"measures":[{"name":"pap","time":"2016-09-05T07:47:07.370Z","value":"2.9","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:47:16:330 PDT] subject "{"measures":[{"name":"pap","time":"2016-09-04T07:47:11.549Z","value":"7.5","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:47:21:204 PDT] subject "{"measures":[{"name":"pap","time":"2016-09-03T07:47:16.420Z","value":"4.2","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:47:26:134 PDT] subject "{"measures":[{"name":"pap","time":"2016-09-02T07:47:21.390Z","value":"2.8","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:47:31:904 PDT] subject "{"measures":[{"name":"pap","time":"2016-09-01T07:47:26.216Z","value":"7.4","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:47:37:952 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-31T07:47:32.031Z","value":"3.4","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:47:42:695 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-30T07:47:38.038Z","value":"7.1","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:48:19:373 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-29T07:47:43.272Z","value":"7.5","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:48:26:985 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-28T07:48:19.459Z","value":"2.6","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:48:35:876 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-27T07:48:27.945Z","value":"6.7","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:49:00:631 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-26T07:48:36.796Z","value":"2.8","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:49:46:142 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-25T07:49:00.799Z","value":"5.8","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:49:59:477 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-24T07:49:47.064Z","value":"4.7","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:50:06:294 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-23T07:49:59.556Z","value":"6.8","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:50:18:544 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-22T07:50:06.377Z","value":"3.6","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:50:22:580 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-21T07:50:18.633Z","value":"7.6","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
[16-09-06 00:50:27:249 PDT] subject "{"measures":[{"name":"pap","time":"2016-08-20T07:50:22.674Z","value":"3.4","unit":"mm","source":"E397367_virtual_device","user":"E397367"}]}".
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




