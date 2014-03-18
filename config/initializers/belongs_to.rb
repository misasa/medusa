module ActiveRecord::Associations::Builder
  class BelongsTo
    def define_accessors
      super
      define_global_id_accessors
    end

    def define_global_id_accessors
      mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}_global_id
          association(:#{name}).load_target.try(:global_id)
        end

        def #{name}_global_id=(id)
          if id.present?
            record = ::RecordProperty.find_by(global_id: id).try!(:datum)
            if record.is_a? association(:#{name}).klass
              write_attribute(association(:#{name}).reflection.foreign_key, record.id)
            end
          else
            write_attribute(association(:#{name}).reflection.foreign_key, nil)
          end
        end
      CODE
    end
  end
end
