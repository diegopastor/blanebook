class Book < ApplicationRecord
  has_many :borrowings, dependent: :destroy

  validates :title, presence: true
  validates :author, presence: true
  validates :genre, presence: true
  validates :isbn, presence: true, uniqueness: true
  validates :total_copies, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :available_copies, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :available_copies_not_greater_than_total

  scope :search_by_title, ->(title) { where("LOWER(title) LIKE ?", "%#{title.downcase}%") }
  scope :search_by_author, ->(author) { where("LOWER(author) LIKE ?", "%#{author.downcase}%") }
  scope :search_by_genre, ->(genre) { where("LOWER(genre) LIKE ?", "%#{genre.downcase}%") }

  def self.search(query, field = nil)
    return all if query.blank?

    case field&.downcase
    when "title"
      search_by_title(query)
    when "author"
      search_by_author(query)
    when "genre"
      search_by_genre(query)
    else
      where("LOWER(title) LIKE :q OR LOWER(author) LIKE :q OR LOWER(genre) LIKE :q", q: "%#{query.downcase}%")
    end
  end

  def available?
    available_copies.positive?
  end

  private

  def available_copies_not_greater_than_total
    return unless available_copies && total_copies

    if available_copies > total_copies
      errors.add(:available_copies, "cannot be greater than total copies")
    end
  end
end
