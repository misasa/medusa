class Omniauth < ApplicationRecord
  belongs_to :user
  
  validates :provider, presence: true, length: { maximum: 255 }
  validates :uid, presence: true, length: { maximum: 255 }, uniqueness: { scope: [:provider] }
  validates :user, presence: true
  
  def self.find_user_by_auth(auth)
    find_by(provider: auth.provider, uid: auth.uid).try(:user)
  end
end
