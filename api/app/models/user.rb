class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  belongs_to :organization
  has_many :bookings, dependent: :destroy
  has_one :golfer_profile, dependent: :destroy

  enum :role, { golfer: 0, staff: 1, pro_shop: 2, manager: 3, admin: 4, owner: 5 }

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def can_manage_course?
    manager? || admin? || owner?
  end

  def can_manage_bookings?
    staff? || pro_shop? || can_manage_course?
  end
end
