module Api
  class BooksController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_librarian!, only: [ :create, :update, :destroy ]
    before_action :set_book, only: [ :show, :update, :destroy ]

    def index
      books = Book.search(params[:search], params[:field])
      render json: { books: books.map { |book| book_response(book) } }, status: :ok
    end

    def show
      render json: { book: book_response(@book) }, status: :ok
    end

    def create
      book = Book.new(book_params)

      if book.save
        render json: { book: book_response(book) }, status: :created
      else
        render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @book.update(book_params)
        render json: { book: book_response(@book) }, status: :ok
      else
        render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @book.destroy
      render json: { message: "Book deleted successfully" }, status: :ok
    end

    private

    def set_book
      @book = Book.find(params[:id])
    end

    def book_params
      params.permit(:title, :author, :genre, :isbn, :total_copies, :available_copies)
    end

    def book_response(book)
      {
        id: book.id,
        title: book.title,
        author: book.author,
        genre: book.genre,
        isbn: book.isbn,
        total_copies: book.total_copies,
        available_copies: book.available_copies,
        available: book.available?
      }
    end
  end
end
