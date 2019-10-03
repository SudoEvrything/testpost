require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
  	@user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
  	assert @user.valid?
  end

  test "name should be present" do
  	@user.name = ""
  	assert_not @user.valid?
  end

  test "email should be present" do
  	@user.email = " "
  	assert_not @user.valid?
  end

  test "name should not be too long" do
  	@user.name = "a" * 51
  	assert_not @user.valid?
  end

  test "email should not be too long" do
  	@user.email = "a" * 244 + "@example.com"
  	assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
  	valid_addresses = %w[user@example.com USER@foo.com A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
  	valid_addresses.each do |valid_addresses|
  		@user.email = valid_addresses
  		assert @user.valid?, "#{valid_addresses.inspect} should be valid"
  	end
  end

  test "should reject invalid addresses" do
  	invalid_addresses = %w[user@example,com user_at_gmail_dot_com user@gmaildotcom foo@bar_baz.com foo@bar+baz.com]
  	invalid_addresses.each do |invalid_addresses|
  		@user.email = invalid_addresses
  		assert_not @user.valid?, "#{invalid_addresses.inspect} should be invalid"
  	end
  end

  test "email addresses should be unique" do
  	duplicate_user = @user.dup
  	duplicate_user.email = @user.email.upcase
  	@user.save
  	assert_not duplicate_user.valid?
  end

  # test "password should be present (non blank)" do
  # 	@user.password = @user.password_confirmation = " " * 6
  # 	assert_not @user.valid?
  # end

  test "password should be atleat six character" do
  	@user.password = @user.password_confirmation = "a" * 5
  	assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    jeth = users(:jether)
    archer = users(:archer)
    assert_not jeth.following?(archer)
    jeth.follow(archer)
    assert jeth.following?(archer)
    assert archer.followers.include?(jeth)
    jeth.unfollow(archer)
    assert_not jeth.following?(archer)
  end

  test "feed should have the right posts" do
    jether= users(:jether)
    archer = users(:archer)
    lana = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert jether.feed.include?(post_following)
    end
    # Post from self
    jether.microposts.each do |post_self|
      assert jether.feed.include?(post_self)
    end
    # Posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not jether.feed.include?(post_unfollowed)
    end
  end
end
