class Divide < ActiveRecord::Base
  belongs_to :before_specimen_quantity, class_name: "SpecimenQuantity"
  has_one :before_specimen, through: :before_specimen_quantity, source: :specimen
  has_one :before, through: :before_specimen_quantity, source: :divide
  has_many :specimen_quantities, :dependent => :destroy
  has_many :specimens, through: :specimen_quantities, source: :specimen
  has_many :afters, through: :specimen_quantities, source: :after_divide

  default_scope -> { order(:updated_at) }

  scope :specimen_id_is, -> (id) { includes(:before_specimen_quantity).where(specimen_quantities: { specimen_id: id }) }

  accepts_nested_attributes_for :specimen_quantities

  def after_specimens
    @after_specimens ||= afters.inject([]){|ary, after| ary + after.specimens }
  end

  def parent_specimen_quantity
    @parent_specimen_quantity ||= specimen_quantities.to_a.find do |specimen_quantity|
      before_specimen.blank? || before_specimen == specimen_quantity.specimen
    end
  end

  def parent_specimen
    @parent_specimen ||= parent_specimen_quantity.try(:specimen)
  end

  def child_specimen_quantities
    @child_specimen_quantities ||= specimen_quantities.to_a.select do |specimen_quantity|
      before_specimen.present? && before_specimen != specimen_quantity.specimen
    end
  end

  def child_specimens
    @child_specimens ||= child_specimen_quantities.select {|specimen_quantity| specimen_quantity.specimen }
  end

  def divided_parent_quantity
    children_decimal_quantity = child_specimen_quantities.inject(0.to_d) do |sum, specimen_quantity|
      sum + specimen_quantity.decimal_quantity
    end
    before_specimen_quantity.decimal_quantity - children_decimal_quantity
  end

  def divided_loss
    divided_parent_quantity - parent_specimen_quantity.decimal_quantity
  end

  def update
    ActiveRecord::Base.transaction do
      self.record_timestamps = false
      save!
      specimen_quantities.each do |specimen_quantity|
        if after_specimens.exclude?(specimen_quantity.specimen)
          specimen_quantity.specimen.update_columns(
            quantity: specimen_quantity.quantity,
            quantity_unit: specimen_quantity.quantity_unit
          )
        end
      end
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      parent_specimen.update_columns(
        quantity: before_specimen_quantity.try(:quantity),
        quantity_unit: before_specimen_quantity.try(:quantity_unit)
      )
      if divide_flg
        child_specimen_quantities.each {|specimen_quantity| specimen_quantity.specimen.destroy }
      end
      super
    end
  end

  def chart_updated_at
    (updated_at.to_i + 9.hours) * 1000
  end

  def updated_at_str
    updated_at.strftime("%Y/%m/%d %H:%M:%S")
  end
end
