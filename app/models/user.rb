# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :group_members
  has_many :groups, through: :group_members
  has_many :record_properties
  belongs_to :box
  #TODO バリデーション:ユーザーにはBoxが必須？

  alias_attribute :admin?, :administrator
end
