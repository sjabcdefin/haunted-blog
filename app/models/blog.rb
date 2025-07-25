# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true

  scope :published, -> { where('secret = FALSE') }

  scope :owned_by, ->(user) { where(user:) }

  scope :search, lambda { |term|
    sanitized_term = sanitize_sql_like(term.to_s)
    where('title LIKE :term OR content LIKE :term', term: "%#{sanitized_term}%")
  }

  scope :default_order, -> { order(id: :desc) }

  def owned_by?(target_user)
    user == target_user
  end
end
