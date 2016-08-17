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

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
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
  puts "asfd"
  result.messages.each { |message|
    puts "inside message"
    puts "body"
    body = service.get_user_message(user_id, message.id).snippet.to_s

    # part messages header name subject value
    puts "header"
    puts service.get_user_thread(user_id, message.thread_id).id.to_s
    temp = service.get_user_thread(user_id, message.thread_id).messages
    tempStr = temp.to_s
    tempStr = tempStr.split("\"Subject").last
    tempStr = tempStr.split("Google").first
    subject = tempStr[11.. -7].gsub('\"', '"')
    begin

      subjectJSON = JSON.parse(subject.to_s)
      puts subjectJSON
      datetime = DateTime.parse(subjectJSON["measures"][0]["time"])
      name = subjectJSON["measures"][0]["name"]
      value = subjectJSON["measures"][0]["value"].tr(',', '')
      user_id = subjectJSON["measures"][0]["user"]
      unit = subjectJSON["measures"][0]["unit"]
      source = subjectJSON["measures"][0]["source"]
      comment = ""

      puts 1
     puts "count measures"
      puts Measure.count
      puts "after count"
      if Measure.where(datetime: datetime, name: name, user_id: 1).exists?
        puts 4
        @measure = Measure.where(time: datetime, name: name).first
        @measure.title = subject
        @measure.value = value
        @measure.save
      else
        puts 3
        @measure = Measure.new("title" => subject, "body" => body, "datetime" => datetime, "name" => name, "value" => value, "user_id" => 1, "unit" => unit, "source" => source, "comment" => comment, "active" => true)
        puts 5
        @measure.save
        puts 6
      end
      modifyRequest = Google::Apis::GmailV1::ModifyMessageRequest.new
      modifyRequest.remove_label_ids = ["UNREAD"]
      service.modify_message(user_id, message.id, modifyRequest).update!
    rescue
      puts 2
      next
    end
  }
  puts "Finished..."
end