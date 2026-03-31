module Api
  class BorrowingsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_borrowing, only: [ :show, :return_book ]

    def index
      borrowings = if current_user.librarian?
                     Borrowing.includes(:user, :book).all
                   else
                     current_user.borrowings.includes(:book)
                   end

      borrowings = borrowings.active if params[:active] == "true"
      borrowings = borrowings.overdue if params[:overdue] == "true"

      render json: { borrowings: borrowings.map { |b| borrowing_response(b) } }, status: :ok
    end

    def show
      render json: { borrowing: borrowing_response(@borrowing) }, status: :ok
    end

    def create
      return render_forbidden unless current_user.member?

      book = Book.find(params[:book_id])
      borrowing = current_user.borrowings.build(book: book)

      if borrowing.save
        book.decrement!(:available_copies)
        render json: { borrowing: borrowing_response(borrowing) }, status: :created
      else
        render json: { errors: borrowing.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def return_book
      return render_forbidden unless current_user.librarian?

      if @borrowing.returned?
        render json: { error: "Book already returned" }, status: :unprocessable_entity
      elsif @borrowing.mark_as_returned!
        render json: { borrowing: borrowing_response(@borrowing) }, status: :ok
      else
        render json: { errors: @borrowing.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_borrowing
      @borrowing = Borrowing.find(params[:id])
    end

    def borrowing_response(borrowing)
      response = {
        id: borrowing.id,
        borrowed_at: borrowing.borrowed_at,
        due_date: borrowing.due_date,
        returned_at: borrowing.returned_at,
        overdue: borrowing.overdue?,
        book: {
          id: borrowing.book.id,
          title: borrowing.book.title,
          author: borrowing.book.author
        }
      }

      if current_user.librarian?
        response[:user] = {
          id: borrowing.user.id,
          name: borrowing.user.name,
          email: borrowing.user.email
        }
      end

      response
    end
  end
end
