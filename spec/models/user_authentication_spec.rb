require 'spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe User do
  let(:user) { create_user(@attributes) }
  let(:errors) { user.valid?; user.errors }

  describe 'validations' do
    it 'requires login' do
      @attributes = { login: nil }
      expect { errors[:login].should_not be_empty }.to_not change(User, :count)
    end

    describe 'allows legitimate logins:' do
      ['123', '1234567890_234567890_234567890_234567890',
       'hello.-_there@funnychar.com'].each do |login_str|
        it "'#{login_str}'" do
          @attributes = { login: login_str }
          expect { expect(errors[:login]).to be_empty }.to change(User, :count).by(1)
        end
      end
    end

    describe 'disallows illegitimate logins:' do
      ["tab\t", "newline\n"].each do |login_str|
        it "'#{login_str}'" do
          @attributes = { login: login_str }
          expect { expect(errors[:login].length).to eq 1 }.to_not change(User, :count)
        end
      end
    end

    it 'requires password' do
      @attributes = { password: nil }
      expect { expect(errors[:password]).to_not be_empty }.to_not change(User, :count)
    end

    it 'requires password confirmation' do
      @attributes = { password_confirmation: nil }
      expect { expect(errors[:password_confirmation].length).to eq 1 }.to_not change(User, :count)
    end

    describe 'allows legitimate emails:' do
      ['', nil, 'foo@bar.com', 'foo@newskool-tld.museum', 'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
       'r@a.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
       'hello.-_there@funnychar.com', 'uucp%addr@gmail.com', 'hello+routing-str@gmail.com',
       'domain@can.haz.many.sub.doma.in',
      ].each do |email_str|
        it "'#{email_str}'" do
          @attributes = { email: email_str }
          expect { expect(errors[:email]).to be_empty }.to change(User, :count).by(1)
        end
      end
    end

    describe 'disallows illegitimate emails' do
      ['!!@nobadchars.com', "tab\t", "newline\n",
       'r@.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail2.com',
       # these are technically allowed but not seen in practice:
       'uucp!addr@gmail.com', 'semicolon;@gmail.com', 'quote"@gmail.com', 'tick\'@gmail.com', 'backtick`@gmail.com', 'space @gmail.com', 'bracket<@gmail.com', 'bracket>@gmail.com'
      ].each do |email_str|
        it "'#{email_str}'" do
          @attributes = { email: email_str }
          expect { expect(errors[:email]).to_not be_empty }.to_not change(User, :count)
        end
      end
    end

    describe 'allows legitimate names:' do
      [ '', nil, 'Andre The Giant (7\'4", 520 lb.) -- has a posse',
       '', '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890',
      ].each do |name_str|
        it "'#{name_str}'" do
          @attributes = { name: name_str }
          expect { expect(errors[:name]).to be_empty }.to change(User, :count).by(1)
        end
      end
    end
    describe "disallows illegitimate names" do
      ["tab\t", "newline\n"].each do |name_str|
        it "'#{name_str}'" do
          @attributes = { name: name_str }
          expect { expect(errors[:name].length).to eq 1 }.to_not change(User, :count)
        end
      end
    end
  end

  describe 'Authentication' do
    before do
      @user = create_user(
        :login => 'quentin',
        :email => 'quentin@example.com',
        :password => 'monkey', :password_confirmation => 'monkey'
      )
    end

    it 'resets password' do
      @user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
      User.authenticate('quentin', 'new password').should == @user
    end

    it 'does not rehash password' do
      @user.update_attributes(:login => 'quentin2')
      User.authenticate('quentin2', 'monkey').should == @user
    end

    it 'authenticates user' do
      User.authenticate('quentin', 'monkey').should == @user
    end

    it "doesn't authenticates user with bad password" do
      User.authenticate('quentin', 'monkey').should == @user
    end

    # New installs should bump this up and set REST_AUTH_DIGEST_STRETCHES to give a 10ms encrypt time or so
    desired_encryption_expensiveness_ms = 0.1
    it "takes longer than #{desired_encryption_expensiveness_ms}ms to encrypt a password" do
     test_reps = 100
     start_time = Time.now; test_reps.times{ User.authenticate('quentin', 'monkey'+rand.to_s) }; end_time   = Time.now
     auth_time_ms = 1000 * (end_time - start_time)/test_reps
     auth_time_ms.should > desired_encryption_expensiveness_ms
    end

    it 'sets remember token' do
      @user.remember_me
      @user.remember_token.should_not be_nil
      @user.remember_token_expires_at.should_not be_nil
    end

    it 'unsets remember token' do
      @user.remember_me
      @user.remember_token.should_not be_nil
      @user.forget_me
      @user.remember_token.should be_nil
    end

    it 'remembers me for one week' do
      before = 1.week.from_now.utc
      @user.remember_me_for 1.week
      after = 1.week.from_now.utc
      @user.remember_token.should_not be_nil
      @user.remember_token_expires_at.should_not be_nil
      @user.remember_token_expires_at.between?(before, after).should be true
    end

    it 'remembers me until one week' do
      time = 1.week.from_now.utc
      @user.remember_me_until time
      @user.remember_token.should_not be_nil
      @user.remember_token_expires_at.should_not be_nil
      @user.remember_token_expires_at.should == time
    end

    it 'remembers me default two years' do
      before = 2.years.from_now.utc
      @user.remember_me
      after = 2.years.from_now.utc
      @user.remember_token.should_not be_nil
      @user.remember_token_expires_at.should_not be_nil
      @user.remember_token_expires_at.between?(before, after).should be true
    end
  end

protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save
    record
  end
end
