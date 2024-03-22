# Manage the blog publications
class Blog < ApplicationRecord
  has_rich_text :content
  has_one_attached :picture do |attachable|
    attachable.variant :thumb, resize_to_fill: [100, 100]
    attachable.variant :thumb_big, resize_to_limit: [200, 200]
  end

  belongs_to :user

  has_one_attached :picture do |attachable|
    attachable.variant :thumb, resize_to_fill: [100, 100]
    attachable.variant :thumb_big, resize_to_limit: [200, 200]
  end

  validates :title, presence: true, length: { minimum: 3 }
  validates :content, presence: true, length: { minimum: 10 }
  validates :keywords, length: { maximum: 100 }

  validate :picture_format
  validate :user_admin
  validate :unpublishing, on: :update

  def user_admin
    return if user&.admin?

    errors.add(:user, 'Only admins can create blogs')
  end

  private

  def unpublishing
    published_before = Blog.find(id).published
    return unless published_before == true && published == false

    errors.add(:pubished, 'Published post cannot be unpublished')
  end

  def picture_format
    return unless picture.attached?

    if picture.blob.content_type.start_with? 'image/'
      if picture.blob.byte_size > 5.megabytes
        # errors.add(:picture, I18n.t('blogs.errors.image_size'))
        errors.add(:picture, 'image size error')
        picture.purge
      end
    else
      picture.purge
      # errors.add(:picture, I18n.t('blogs.errors.file_type'))
      errors.add(:picture, 'image size error')
    end
  end
end
