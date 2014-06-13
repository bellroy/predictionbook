# -*- coding: utf-8 -*-
require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_many :responses
  delegate :wagers, :to => :responses
  has_many :predictions,
    :through => :responses,
    :uniq => true,
    :conditions => "responses.#{Response::WAGER_CONDITION}",
    :order => 'responses.updated_at DESC'
  has_many :deadline_notifications
  has_many :response_notifications

  nillify_blank :email, :name

  validates_presence_of     :login
  validates_length_of       :login,    :maximum => 255
  validates_uniqueness_of   :login,    :case_sensitive => false
  validates_format_of       :login,    :with => Authentication.login_regex, :message => "Readable characters only please"

  validates_length_of       :name,     :maximum => 255, :allow_nil => true
  validates_format_of       :name,     :with => Authentication.name_regex, :message => "Readable characters only please"

  validates_length_of       :email,    :within => 6..100, :allow_nil => true #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false, :allow_nil => true
  validates_format_of       :email,    :with => /\A#{Authentication.email_name_regex}@[-A-Z0-9\._]+\z/i, :message => Authentication.bad_email_message, :allow_nil => true

  #NOTE: You can't set anything via mass assignment that is not in this list
  ## eg. User.new(:foo => 'bar') # will not assign foo
  attr_accessible :login, :email, :name, :password, :password_confirmation, :timezone, :private_default
  attr_accessible :login, :email, :name, :admin, :as => :admin

  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # find by login
  def self.[](login)
    raise(ActiveRecord::RecordNotFound, "Login is blank") if login.blank?
    find_by_login!(login.gsub("[dot]","."))
  end

  delegate :statistics, :to => :wagers

  def statistics_image_url
    statistics.image_url
  end

  def email_with_name
    %{"#{to_s}" <#{email}>}
  end

  def notify_on_overdue?
    has_email?
  end

  def notify_on_judgement?
    has_email?
  end

  def has_email?
    !email.blank?
  end

  def has_overdue_judgements?
    !!predictions.index { |x| x.due_for_judgement?}
  end

  def authorized_for(prediction)
    if prediction.private?
      self == prediction.creator
    else
      admin? || self == prediction.creator
    end
  end

  def admin?
    %w[matt gwern].include?(login)  # I can imagine this method being slightly more complicated…
  end

  def to_param
    login.gsub(".", "[dot]")
  end

  def to_s
    name || login
  end

  def remember_me
    remember_me_for 2.years
  end

  def reset_password
    self.password = self.password_confirmation = SecureRandom.hex(6)
    self.save!

    UserMailer.password_reset(self).deliver
  end
end
