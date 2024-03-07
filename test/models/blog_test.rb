require 'test_helper'

class BlogTest < ActiveSupport::TestCase
  test 'Correct blog should save' do
    blog = blogs(:one)
    assert blog.save
  end

  test 'None admin user should not save' do
    hash = {  user: users(:regular_user),
              title: 'My title',
              keywords: '#test',
              status: 0 }
    blog = Blog.new(hash)
    assert_not blog.save
  end

  test "email publication  can't be before blog publication" do
    hash = {  user: users(:admin_user),
              title: 'My title',
              keywords: '#test',
              status: 0,
              blog_publication_date: Time.now,
              email_publication_date: Time.now - 1.day }
    blog = Blog.new(hash)
    assert_not blog.save
  end

  test 'Status can only be in draft when creating ' do
    hash = {  user: users(:admin_user),
              title: 'My title',
              keywords: '#test',
              status: 1 }
    blog = Blog.new(hash)
    assert_not blog.save
  end
end
