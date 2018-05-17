# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def clean_database
  User.delete_all
  Prediction.delete_all
  Judgement.delete_all
  Response.delete_all
  DeadlineNotification.delete_all
end

def random_future_day
  random_int.days.from_now
end

def random_past_day
  Random.rand(15).days.ago
end

def random_int
  Random.rand(100)
end

puts 'SEEDING!'

start_time = Time.current

DATA_SIZE = 500

clean_database

first_user = User.create!(
  login: 'First',
  password: 'blahblah',
  password_confirmation: 'blahblah',
  email: 'first@example.com'
)
first_user.confirm

second_user = User.create!(
  login: 'Second',
  password: 'jajaja',
  password_confirmation: 'jajaja',
  email: 'second@example.com'
)
second_user.confirm

puts 'creating future unjudged'
DATA_SIZE.times do
  is_private = random_int > 80
  confidence = random_int
  prediction = Prediction.new(
    creator: first_user,
    initial_confidence: confidence,
    deadline: random_future_day,
    description: "I'm #{confidence} confident that this #{is_private ? "private " : ""}future event will come true",
    visibility: is_private ? Visibility::VALUES[:visible_to_creator] : Visibility::VALUES[:visible_to_everyone]
  )
  prediction.save!
  prediction.responses.create!(user: second_user, confidence: random_int) unless is_private and random_int < 75
end

puts 'creating past unjudged'
DATA_SIZE.times do
  is_private = random_int > 80
  confidence = random_int
  prediction = Prediction.new(
    creator: second_user,
    initial_confidence: confidence,
    deadline: random_past_day,
    description: "I'm #{confidence} confident that this #{is_private ? "private " : ""}past event will come true",
    visibility: is_private ? Visibility::VALUES[:visible_to_creator] : Visibility::VALUES[:visible_to_everyone]
  )
  prediction.save!
  prediction.responses.create!(user: first_user, confidence: random_int) unless is_private and random_int < 75
end

puts 'creating past judged'
DATA_SIZE.times do
  is_private = random_int > 80
  confidence = random_int
  prediction = Prediction.new(
    creator: first_user,
    initial_confidence: confidence,
    deadline: random_past_day,
    description: "I was #{confidence} confident that this #{is_private ? "private " : ""}past event would come true",
    visibility: is_private ? Visibility::VALUES[:visible_to_creator] : Visibility::VALUES[:visible_to_everyone]
  )
  prediction.save!
  prediction.responses.create!(user: second_user, confidence: random_int) unless is_private and random_int < 75

  Judgement.create!(
    user: is_private ? first_user : second_user,
    prediction: prediction,
    outcome: random_int < prediction.initial_confidence
  )
end

puts 'creating future commented'
DATA_SIZE.times do
  is_private = random_int > 80
  confidence = random_int
  prediction = Prediction.new(
    creator: first_user,
    initial_confidence: confidence,
    deadline: random_future_day,
    description: "I'm #{confidence} confident that this #{is_private ? "private " : ""}interesting future event will come true",
    visibility: is_private ? Visibility::VALUES[:visible_to_creator] : Visibility::VALUES[:visible_to_everyone]
  )
  prediction.save!

  prediction.responses.create!(
    user: second_user,
    comment: 'No way this will happen!'
  ) unless is_private and random_int < 75
end

finish_time = Time.current

puts 'END SEEDING'
puts "Seeding the database took #{finish_time - start_time} seconds."
