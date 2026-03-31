module Api
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def librarian
      return render_forbidden unless current_user.librarian?

      total_books = Book.count
      total_borrowed = Borrowing.active.count
      due_today_count = Borrowing.due_today.count

      overdue_borrowings = Borrowing.overdue.includes(:user, :book)
      members_with_overdue = overdue_borrowings.map do |borrowing|
        {
          user: {
            id: borrowing.user.id,
            name: borrowing.user.name,
            email: borrowing.user.email
          },
          book: {
            id: borrowing.book.id,
            title: borrowing.book.title
          },
          due_date: borrowing.due_date,
          days_overdue: ((Time.current - borrowing.due_date) / 1.day).to_i
        }
      end

      render json: {
        total_books: total_books,
        total_borrowed: total_borrowed,
        due_today: due_today_count,
        members_with_overdue: members_with_overdue
      }, status: :ok
    end

    def member
      return render_forbidden unless current_user.member?

      active_borrowings = current_user.borrowings.active.includes(:book)
      overdue_borrowings = current_user.borrowings.overdue.includes(:book)

      render json: {
        borrowed_books: active_borrowings.map { |b| borrowing_summary(b) },
        overdue_books: overdue_borrowings.map { |b| borrowing_summary(b) }
      }, status: :ok
    end

    private

    def borrowing_summary(borrowing)
      {
        id: borrowing.id,
        book: {
          id: borrowing.book.id,
          title: borrowing.book.title,
          author: borrowing.book.author
        },
        borrowed_at: borrowing.borrowed_at,
        due_date: borrowing.due_date,
        overdue: borrowing.overdue?,
        days_until_due: borrowing.overdue? ? nil : ((borrowing.due_date - Time.current) / 1.day).to_i
      }
    end
  end
end
