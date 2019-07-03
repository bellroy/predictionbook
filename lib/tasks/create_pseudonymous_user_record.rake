namespace :db do
  desc 'Create the pseudonymous user record'
  task create_pseudonymous_user_record: :environment do
    User.find_or_initialize_by(login: User::PSEUDONYMOUS_LOGIN).tap do |user|
      password = User.generate_api_token
      user.password = password
      user.password_confirmation = password
      user.email = 'pseudonymous-user@predictionbook.com'
    end.save! and puts 'Successfully created the pseudonymous user record!'
  end
end
