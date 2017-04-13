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

DATA_SIZE = 1000

clean_database

first_user = User.create!(
  login: 'Test',
  password: 'blahblah',
  password_confirmation: 'blahblah',
  email: 'dude@email.com'
)

second_user = User.create!(
  login: 'Second',
  password: 'jajaja',
  password_confirmation: 'jajaja',
  email: 'mang@email.com'
)

puts 'creating future unjudged'
DATA_SIZE.times do
  prediction = Prediction.new(
    deadline: random_future_day,
    initial_confidence: random_int,
    creator: first_user,
    description: 'this event will come true'
  )
  prediction.save!
  prediction.responses.create!(user: second_user, confidence: random_int)
end

puts 'creating past unjudged'
DATA_SIZE.times do
  prediction = Prediction.new(
    deadline: random_past_day,
    initial_confidence: random_int,
    description: 'this event has came past',
    creator: second_user
  )
  prediction.save!
end

puts 'creating past judged'
DATA_SIZE.times do
  judged = Prediction.new(
    deadline: random_past_day,
    initial_confidence: random_int,
    description: 'this event is judged',
    creator: first_user
  )
  judged.save!

  Judgement.create!(
    user: second_user,
    prediction: judged,
    outcome: random_int % 2
  )
end

puts 'creating future commented'
DATA_SIZE.times do
  commented = Prediction.new(
    deadline: random_future_day,
    initial_confidence: random_int,
    description: 'commented prediction',
    creator: first_user
  )
  commented.save!

  commented.responses.create!(
    user: second_user,
    confidence: random_int,
    comment: 'No way this will happen!'
  )
end

finish_time = Time.current

puts 'END SEEDING'
puts "Seeding the database took #{finish_time - start_time} seconds."
