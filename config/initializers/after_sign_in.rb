Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  Analytics.identify(
      user_id: '019mr8mf4r',
      traits: { email: "#{ user.email }", friends: 872 },
      context: {ip: '8.8.8.8'})
end