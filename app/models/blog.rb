# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true

  before_save :clear_random_eyecatch_unless_premium

  scope :published, -> { where('secret = FALSE') }

  scope :search, lambda { |term|
    sanitized_term = sanitize_sql_like(term.to_s)
    where('title LIKE :term OR content LIKE :term', term: "%#{sanitized_term}%")
  }

  scope :default_order, -> { order(id: :desc) }

  def owned_by?(target_user)
    user == target_user
  end

  private

  def clear_random_eyecatch_unless_premium
    self.random_eyecatch = false unless user.premium?
  end
end
