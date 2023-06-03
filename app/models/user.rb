class User < ApplicationRecord
  has_many :blogs, :dependent => :delete_all

# Remainings timeoutable :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable, :lockable
  enum role: [ :user, :admin ]
  after_initialize :set_default_role, if: :new_record?
  validates :last_name, presence: true
  validates :first_name, presence: true

  private

  def set_default_role
    self.role ||= :user
  end 
end
