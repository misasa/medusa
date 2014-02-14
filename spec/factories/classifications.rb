FactoryGirl.define do
  factory :classification do
    name "分類１"
    full_name "分類１"
    description "説明１"
    parent_id ""
    lft 1
    rgt 1
  end
  factory :classification_parent,class: Classification do
    name "parent"
    full_name ""
    description "parent description"
    parent_id ""
  end
  factory :classification_child,class: Classification do
    name "child"
    full_name ""
    description "child description"
    parent_id ""
  end
  factory :classification_grandchild,class: Classification do
    name "grandchild"
    full_name ""
    description "grandchild description"
    parent_id ""
  end
end
