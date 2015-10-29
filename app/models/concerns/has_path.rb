module HasPath
  extend ActiveSupport::Concern

  included do
    has_many :paths, -> { order(brought_in_at: :desc) }, as: :datum, dependent: :destroy
    after_save :store_new_path, if: -> { path_changed? }
  end

  module ClassMethods

    def recursive_path_update
      @recursive_path_update
    end

    private

    def recursive_path_update=(flag)
      @recursive_path_update = !!flag
    end

  end

  def store_new_path
    now = Time.now
    paths.current.first.update_attributes!(brought_out_at: now, brought_out_by: User.current) if paths.current.present?
    paths.create!(ids: path_ids, brought_in_at: now, brought_in_by: User.current)
    if recursive?
      descendants.each(&:store_new_path)
      stones.each(&:store_new_path)
    end
  end

  private

  def path_changed?
    raise NotImplementedError, "You must implement #{self.class.name}#path_ids method."
  end

  def path_ids
    raise NotImplementedError, "You must implement #{self.class.name}#path_ids method."
  end

  def recursive?
    self.class.recursive_path_update
  end
end
