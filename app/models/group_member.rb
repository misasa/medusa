class GroupMember < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :group, presence: true
  # TODO groupの新規作成時にexistenceバリデーションが掛かるためコメントアウト
  # validates :user, existence: true
end
