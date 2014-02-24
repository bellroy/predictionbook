# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

u = User.new({:login => "Test", :password => "blahblah", :password_confirmation =>"blahblah"})

u.save


p = u.predictions.build(:deadline => 24.days.from_now, :initial_confidence => 24, :creator => User.first, :description => "this event will come true")
p.save

