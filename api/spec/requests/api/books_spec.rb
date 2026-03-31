require 'rails_helper'

RSpec.describe 'Api::Books', type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }

  describe 'GET /api/books' do
    let!(:book1) { create(:book, title: 'Ruby Programming') }
    let!(:book2) { create(:book, title: 'JavaScript Guide') }

    context 'when authenticated' do
      it 'returns all books' do
        get '/api/books', headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['books'].length).to eq(2)
      end

      it 'filters books by search term' do
        get '/api/books', params: { search: 'ruby' }, headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['books'].length).to eq(1)
        expect(json['books'][0]['title']).to eq('Ruby Programming')
      end

      it 'filters books by specific field' do
        get '/api/books', params: { search: 'ruby', field: 'title' }, headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['books'].length).to eq(1)
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        get '/api/books'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/books/:id' do
    let(:book) { create(:book) }

    context 'when authenticated' do
      it 'returns the book' do
        get "/api/books/#{book.id}", headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['book']['id']).to eq(book.id)
      end

      it 'returns 404 for non-existent book' do
        get '/api/books/99999', headers: auth_headers(member)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/books' do
    let(:valid_params) do
      {
        title: 'New Book',
        author: 'New Author',
        genre: 'Fiction',
        isbn: '978-0-123-45678-9',
        total_copies: 5,
        available_copies: 5
      }
    end

    context 'as librarian' do
      it 'creates a new book' do
        expect {
          post '/api/books', params: valid_params, headers: auth_headers(librarian)
        }.to change(Book, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['book']['title']).to eq('New Book')
      end

      it 'returns errors for invalid params' do
        post '/api/books', params: valid_params.except(:title), headers: auth_headers(librarian)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Title can't be blank")
      end
    end

    context 'as member' do
      it 'returns forbidden' do
        post '/api/books', params: valid_params, headers: auth_headers(member)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH /api/books/:id' do
    let(:book) { create(:book) }

    context 'as librarian' do
      it 'updates the book' do
        patch "/api/books/#{book.id}",
              params: { title: 'Updated Title' },
              headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['book']['title']).to eq('Updated Title')
      end

      it 'returns errors for invalid params' do
        patch "/api/books/#{book.id}",
              params: { available_copies: 100 },
              headers: auth_headers(librarian)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'as member' do
      it 'returns forbidden' do
        patch "/api/books/#{book.id}",
              params: { title: 'Updated Title' },
              headers: auth_headers(member)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /api/books/:id' do
    let!(:book) { create(:book) }

    context 'as librarian' do
      it 'deletes the book' do
        expect {
          delete "/api/books/#{book.id}", headers: auth_headers(librarian)
        }.to change(Book, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Book deleted successfully')
      end
    end

    context 'as member' do
      it 'returns forbidden' do
        delete "/api/books/#{book.id}", headers: auth_headers(member)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
