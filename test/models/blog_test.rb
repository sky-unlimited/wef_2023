require 'test_helper'

class BlogTest < ActiveSupport::TestCase
  test 'Correct drafted blog should save' do
    blog = blogs(:two)
    blog.content = 'This is the content!'
    assert blog.save!
  end

  test 'None admin user should not save' do
    hash = {  user: users(:regular_user),
              title: 'My title',
              keywords: 'test' }
    blog = Blog.new(hash)
    assert_not blog.save
  end

  test 'Keywords have a maximum length' do
    hash = {  user: users(:admin_user),
              title: 'My title',
              keywords: '#test' * 100 }
    blog = Blog.new(hash)
    assert_not blog.save
  end

  test 'Post having been published cannot be unpublished' do
    blog = blogs(:one)
    blog.content = 'This is the content!'
    blog.published = false
    assert_not blog.save
  end
end
