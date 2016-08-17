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




