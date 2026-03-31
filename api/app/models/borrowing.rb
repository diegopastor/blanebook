class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :borrowed_at, presence: true
  validates :due_date, presence: true
  validate :user_cannot_borrow_same_book_twice, on: :create
  validate :book_must_be_available, on: :create

  before_validation :set_dates, on: :create

  scope :active, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }
  scope :overdue, -> { active.where("due_date < ?", Time.current) }
  scope :due_today, -> { active.where(due_date: Time.current.beginning_of_day..Time.current.end_of_day) }

  def overdue?
    returned_at.nil? && due_date < Time.current
  end

  def returned?
    returned_at.present?
  end

  def mark_as_returned!
    return false if returned?

    transaction do
      update!(returned_at: Time.current)
      book.increment!(:available_copies)
    end
  end

  private

  def set_dates
    self.borrowed_at ||= Time.current
    self.due_date ||= borrowed_at + 2.weeks
  end

  def user_cannot_borrow_same_book_twice
    return unless user && book

    existing = Borrowing.active.where(user: user, book: book).exists?
    errors.add(:base, "You have already borrowed this book") if existing
  end

  def book_must_be_available
    return unless book

    errors.add(:base, "This book is not available") unless book.available?
  end
end
