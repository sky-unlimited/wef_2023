# Manage the blog publications
class Blog < ApplicationRecord
  has_rich_text :content
  belongs_to :user

  has_one_attached :picture do |attachable|
    attachable.variant :thumb, resize_to_fill: [100, 100]
    attachable.variant :thumb_big, resize_to_limit: [200, 200]
  end

  enum status: { 'draft' => 0, 'ready_to_publish' => 1,
                 'scheduled' => 2, 'published' => 3,
                 'email_scheduled' => 4, 'email_sent' => 5 }

  validates :title, presence: true, length: { minimum: 3 }
  validates :content, presence: true, length: { minimum: 10 }

  validate :picture_format
  validate :user_admin
  validate :publications_order
  validate :status_daft, on: :create

  def user_admin
    return if user&.admin?

    errors.add(:user, 'Only admins can create blogs')
  end

  private

  def status_daft
    return if status == :draft

    errors.add(:status, 'Status should be draft on creation')
  end

  def publications_order
    if !blog_publication_date.nil? &&
       !email_publication_date.nil? &&
       (email_publication_date < blog_publication_date)

      errors.add(:email_publication_date, 'Cannot be before blog publication')
    end
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
