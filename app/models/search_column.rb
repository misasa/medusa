class SearchColumn < ApplicationRecord

  MASTER_USER_ID = 0

  #表示種別
  module DisplayType
    # 非表示
    NONE = 0
    # 拡張時表示
    EXPAND = 1
    # 常に表示
    ALWAYS = 2
  end

  belongs_to :user

  default_scope -> { order(display_order: :asc) }
  scope :model_is, -> (model) { where(datum_type: model.to_s) }
  scope :user_is, -> (user) { where(user_id: user.id) }
  scope :master, -> { where(user_id: MASTER_USER_ID) }
  scope :display_expand, -> { where(display_type: [DisplayType::EXPAND, DisplayType::ALWAYS]) }
  scope :display_always, -> { where(display_type: DisplayType::ALWAYS) }

  def self.update_display(display_type_hash, user_id)
    ActiveRecord::Base.transaction do
      res = []
      display_type_hash.each.with_index(1) do |(id, type), index|
        search_column = find_by(id: id, user_id: user_id)
        search_column.update(display_type: type, display_order: index) if search_column
        res << search_column
      end
      res
    end
  end

  def none?
    display_type == DisplayType::NONE
  end

  def expand?
    display_type == DisplayType::EXPAND
  end

  def always?
    display_type == DisplayType::ALWAYS
  end
end
