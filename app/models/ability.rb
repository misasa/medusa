class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :pmlame, :family, :picture, :map, :download_label, :download_card, :download, to: :read

    if user.admin?
      can :manage, :all
    end

    can :manage, [Surface, Table, AttachmentFile, Bib, Box, Analysis, Chemistry, Place, Spot, Specimen] do |record|
      record.writable?(user)
    end
    can :read, [Surface, Table, AttachmentFile, Bib, Box, Analysis, Chemistry, Place, Spot, Specimen] do |record|
      record.readable?(user)
    end

  end
end
