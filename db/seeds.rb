# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def random_future_day
  random_int.days.from_now
end

def random_past_day
  random_int.days.ago
end

def random_int
  Random.rand(100)
end

puts "SEEDING!"

User.delete_all
Prediction.delete_all
Judgement.delete_all
Response.delete_all

first_user = User.new({:login => "Test", :password => "blahblah", :password_confirmation =>"blahblah"})
first_user.save!

second_user = User.new({:login => "Second", :password => "jajaja", :password_confirmation => "jajaja"})
second_user.save!

DATA_SIZE = 1000

puts "creating future unjudged"
DATA_SIZE.times do
  prediction = first_user.predictions.build(
    :deadline => random_future_day,
    :initial_confidence => random_int,
    :creator => User.first,
    :description => "this event will come true"
  )
  prediction.save!
  prediction.responses.create!(:user => second_user, :confidence => random_int)
end

puts "creating past unjudged"
DATA_SIZE.times do
  prediction = second_user.predictions.build(
    :deadline => random_past_day,
    :initial_confidence => random_int,
    :description => "this event has came past",
    :creator => second_user
  )
  prediction.save!
end

puts "creating past judged"
DATA_SIZE.times do
  judged = first_user.predictions.build(
    :deadline => random_past_day,
    :initial_confidence => random_int,
    :description => "this event is judged",
    :creator => first_user
  )
  judged.save!

  Judgement.create!(
    :user => second_user,
    :prediction => judged,
    :outcome => random_int % 2
  )
end

puts "creating future commented"
DATA_SIZE.times do
  commented = first_user.predictions.build(
    :deadline => random_future_day,
    :initial_confidence => random_int,
    :description => "commented prediction",
    :creator => first_user
  )
  commented.save!

  commented.responses.create!(
    :user => second_user,
    :confidence => random_int,
    :comment => "No way this will happen!"
  )
end

puts "END SEEDING"
