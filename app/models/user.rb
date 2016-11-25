  # -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [:google_oauth2, :shibboleth]

  after_create :create_search_columns

  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members
  has_many :record_properties
  has_many :omniauths, dependent: :destroy
  has_many :search_columns
  belongs_to :box
  
  validates :username, presence: true, length: {maximum: 255}, uniqueness: true
  validates :api_key, uniqueness: true, allow_blank: true
  validates :box, existence: true, allow_nil: true

  alias_attribute :admin?, :administrator
  
  def self.current
    Thread.current[:user]
  end
  
  def self.current=(user)
    Thread.current[:user] = user
  end

  def self.find_by_token(token)
    payload, _ = JWT.decode(token, Rails.application.config.secret_key_base)
    find_by(payload)
  end
  
  def as_json(options = {})
    super({:methods => :box_global_id}.merge(options))
  end

  def omniauth_uid(provider)
    auth = omniauths.find_by_provider(provider)
    return unless auth
    auth.uid
  end

  def access_token
    payload = { api_key: api_key }
    JWT.encode(payload, Rails.application.config.secret_key_base)
  end

  protected

  def email_required?
    false
  end

  private

  def create_search_columns
    SearchColumn.master.each do |master_search_column|
      search_column = master_search_column.dup
      search_column.user = self
      search_column.save!
    end
  end
end
