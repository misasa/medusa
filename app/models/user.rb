# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [:google_oauth2, :shibboleth]

  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members
  has_many :record_properties
  has_many :omniauths, dependent: :destroy
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
  
  def as_json(options = {})
    super({:methods => :box_global_id}.merge(options))
  end

  protected

  def email_required?
    false
  end
  
end
