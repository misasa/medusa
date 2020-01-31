FactoryGirl.define do
    factory :surface_layer do
        #association :surface_image, factory: :surface_image
        association :surface, factory: :surface
        sequence(:name) { |n| "layer_#{n}" }
        opacity 100
        priority 1
    end    
end