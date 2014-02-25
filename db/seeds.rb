# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts "SEEDING!"
first_user = User.new({:login => "Test", :password => "blahblah", :password_confirmation =>"blahblah"})

first_user.save


prediction = first_user.predictions.build(:deadline => 24.days.from_now, :initial_confidence => 24, :creator => User.first, :description => "this event will come true")
prediction.save


second_user = User.new({:login => "Second", :password => "jajaja", :password_confirmation => "jajaja"})
second_user.save

first_response = prediction.responses.build({:user => second_user, :confidence => 10})
first_response.save()


unjudged = second_user.predictions.build({:deadline => 24.days.ago, :initial_confidence => 33, :description => "this event has came past", :creator => second_user})
unjudged.save


judged = first_user.predictions.build({:deadline => 3.days.ago, :initial_confidence => 44, :description => "this event is judged", :creator => first_user})
judged.save

judgement = Judgement.new({:user_id => second_user.id, :prediction_id => judged.id,:outcome => 0})
judgement.save()
puts "END SEEDING"
