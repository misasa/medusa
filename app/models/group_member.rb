class GroupMember < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates :group, existence: true
  # TODO groupの新規作成時にexistenceバリデーションが掛かるためコメントアウト
  # validates :user, existence: true
end
