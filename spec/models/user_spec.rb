# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string           not null
#  is_public              :boolean          default(TRUE), not null
#  last_name              :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  def create_users_list (quantity)
    raise Exception.new "Quantity must be greater then 0" if quantity < 1
    [*1..quantity].map { |item| create(:user) }
  end

  EMAIL = "adam@example.org"

  describe "#valid?" do
    it "is valid when email is unique" do
      user1 = create(:user)
      user2 = create(:user)
      expect(user2.email).not_to be user1.email
      expect(user2).to be_valid
    end

    it "is invalid if the email is taken" do
      create(:user, email: EMAIL)
      user = User.new
      user.email = EMAIL
      expect(user).not_to be_valid
    end

    USERNAME = "Finn"

    it "is invalid if the username is taken" do
      user = create(:user, first_name: "Adam", email: "adam@example.org", username: "adam12")
      another_user  = create(:user, first_name: "Finn", email: "finn@example.org", username: "finn42")
      expect(user).to be_valid
      expect(another_user).to be_valid
      another_user.username = "adam12"
      expect(another_user).not_to be_valid
    end

    it "is invalid if user's first name is blank" do
      user = create(:user)
      expect(user).to be_valid
      user.first_name = ""
      expect(user).not_to be_valid
      user.first_name = nil
      expect(user).not_to be_valid
    end
  end

  describe "email" do
    it "is valid" do
      VALID_EMAILS = ["f.o.o.b.a.r@example.com", "foo+bar@example.com", "foo.bar@sub.example.co.id" ]
      user = create(:user)
      expect(user).to be_valid

      VALID_EMAILS.each do |email|
        user.email = email
        expect(user).to be_valid
      end
    end

    it "is invalid" do
      INVALID_EMAILS = ["", "foo.bar", "foo.bar#example.com"]
      user = create(:user)

      INVALID_EMAILS.each do |email|
        user.email = email
        expect(user).not_to be_valid
      end
    end
  end

  describe "#following" do
    it "can list all  of the user's followings" do
      user = create(:user)
      friends = create_users_list(3)
      states = [Bond::FOLLOWING, Bond::FOLLOWING, Bond::REQUESTING]
      states.each_with_index { |state, i| Bond.create(user: user, friend: friends[i], state: state) }
      
      expect(user.followings).to include(friends.first, friends.second)
      expect(user.follow_requests).to include(friends.last)
    end
  end

  describe "#followers" do
    it "can list all of the user's followers" do
      users = create_users_list(2)
      followers_1 = create_users_list(2)
      followers_2 = create_users_list(2)
      followers_1.each do |follower|
        Bond.create(user: follower, friend: users.first, state: Bond::FOLLOWING)
      end

      Bond.create(user: followers_2.first, friend: users.second, state: Bond::FOLLOWING)
      Bond.create(user: followers_2.second, friend: users.second, state: Bond::REQUESTING)

      expect(users.first.followers).to eq(followers_1)
      expect(users.second.followers).to eq([followers_2.first])


    end
  end

  describe "#save" do
    it "capitalized the name correctly" do
      user = create(:user)
      user.first_name = "AdaM"
      user.last_name = "van der Berg"
      user.save
      expect(user.first_name).to eq "Adam"
      expect(user.last_name).to eq "van der Berg"
    end
  end
end
