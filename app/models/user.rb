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
  
  validates :username, presence: true, length: {maximum: 255}, uniqueness: true
  validates :box, existence: true, allow_nil: true


  alias_attribute :admin?, :administrator
  
  def self.current
    Thread.current[:user]
  end
  
  def self.current=(user)
    Thread.current[:user] = user
  end
end
