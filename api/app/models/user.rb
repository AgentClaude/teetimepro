class User < ApplicationRecord
  has_paper_trail ignore: [:encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :updated_at]

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  belongs_to :organization
  has_many :bookings, dependent: :destroy
  has_one :golfer_profile, dependent: :destroy
  has_many :tournament_entries, dependent: :destroy
  has_many :tournaments_entered, through: :tournament_entries, source: :tournament
  has_many :created_tournaments, class_name: "Tournament", foreign_key: :created_by_id, dependent: :nullify
  has_many :calendar_connections, dependent: :destroy
  has_one :loyalty_account, dependent: :destroy
  has_many :waitlist_entries, dependent: :destroy

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
