Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  Analytics.identify(
      user_id: user.id,
      user_name: user.name,
      traits: {
          email: "#{ user.email }",
          datetime: DateTime.now
      }
  )
end