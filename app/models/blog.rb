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

  enum status: { draft: 0, published: 1, email_sent: 2 }

  validates :title, presence: true, length: { minimum: 3 }
  validates :content, presence: true, length: { minimum: 10 }
  validates :keywords, length: { maximum: 100 }

  validate :picture_format
  validate :user_admin
  validate :publications_order
  validate :status_draft, on: :create
  validate :status_cycle

  def user_admin
    return if user&.admin?

    errors.add(:user, 'Only admins can create blogs')
  end

  private

  def status_draft
    return if status.to_sym == :draft

    errors.add(:status, 'Status should be draft on creation')
  end

  def status_cycle
    return if id.nil?

    # Can't go from published to draft
    #   Check former status
    status_before = Blog.find(id).status
    if status.to_sym == :draft &&
       (status_before.to_sym == :published ||
         status_before.to_sym == :email_sent)
      errors.add(:status,
                 'Cannot go back to draft status. Post already published')
    end

    # email_sent status can't be set manually
    if  status.to_sym == :email_sent &&
        email_publication_date.nil?
      errors.add(:status,
                 'You cannot set manualy status to email_sent')
    end
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
