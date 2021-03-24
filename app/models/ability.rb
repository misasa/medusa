class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :pmlame, :family, :picture, :map, :download_label, :download_card, :download, to: :read
    if user.admin?
      can :manage, :all
    end
    models = [Surface, Table, AttachmentFile, Bib, Box, Analysis, Chemistry, Place, Spot, Specimen]
    decorators = models.map{|model| Object.const_get(model.to_s + 'Decorator')}
    models_with_decorators = models.concat(decorators)
    can :manage, models_with_decorators do |record|
      record.writable?(user)
    end

    can :read, models_with_decorators do |record|
      record.readable?(user)
    end

  end
end
