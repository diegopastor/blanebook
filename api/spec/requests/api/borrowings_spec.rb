require 'rails_helper'

RSpec.describe 'Api::Borrowings', type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let(:book) { create(:book, total_copies: 5, available_copies: 5) }

  describe 'GET /api/borrowings' do
    let!(:member_borrowing) { create(:borrowing, user: member, book: book) }
    let!(:other_member) { create(:user, :member) }
    let!(:other_borrowing) { create(:borrowing, user: other_member) }

    context 'as member' do
      it 'returns only their borrowings' do
        get '/api/borrowings', headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['borrowings'].length).to eq(1)
        expect(json['borrowings'][0]['id']).to eq(member_borrowing.id)
      end
    end

    context 'as librarian' do
      it 'returns all borrowings' do
        get '/api/borrowings', headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['borrowings'].length).to eq(2)
      end

      it 'includes user information' do
        get '/api/borrowings', headers: auth_headers(librarian)

        json = JSON.parse(response.body)
        expect(json['borrowings'][0]['user']).to be_present
      end
    end

    context 'with filters' do
      let!(:returned_borrowing) { create(:borrowing, :returned, user: member) }
      let!(:overdue_borrowing) { create(:borrowing, :overdue, user: member) }

      it 'filters by active borrowings' do
        get '/api/borrowings', params: { active: 'true' }, headers: auth_headers(member)

        json = JSON.parse(response.body)
        borrowing_ids = json['borrowings'].map { |b| b['id'] }
        expect(borrowing_ids).to include(member_borrowing.id, overdue_borrowing.id)
        expect(borrowing_ids).not_to include(returned_borrowing.id)
      end

      it 'filters by overdue borrowings' do
        get '/api/borrowings', params: { overdue: 'true' }, headers: auth_headers(member)

        json = JSON.parse(response.body)
        expect(json['borrowings'].length).to eq(1)
        expect(json['borrowings'][0]['id']).to eq(overdue_borrowing.id)
      end
    end
  end

  describe 'GET /api/borrowings/:id' do
    let(:borrowing) { create(:borrowing, user: member, book: book) }

    it 'returns the borrowing' do
      get "/api/borrowings/#{borrowing.id}", headers: auth_headers(member)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['borrowing']['id']).to eq(borrowing.id)
    end
  end

  describe 'POST /api/borrowings' do
    context 'as member' do
      it 'creates a new borrowing' do
        expect {
          post '/api/borrowings', params: { book_id: book.id }, headers: auth_headers(member)
        }.to change(Borrowing, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['borrowing']['book']['id']).to eq(book.id)
      end

      it 'decrements available copies' do
        post '/api/borrowings', params: { book_id: book.id }, headers: auth_headers(member)

        expect(book.reload.available_copies).to eq(4)
      end

      it 'returns error when borrowing same book twice' do
        create(:borrowing, user: member, book: book)

        post '/api/borrowings', params: { book_id: book.id }, headers: auth_headers(member)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('You have already borrowed this book')
      end

      it 'returns error when book is unavailable' do
        unavailable_book = create(:book, :unavailable)

        post '/api/borrowings', params: { book_id: unavailable_book.id }, headers: auth_headers(member)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('This book is not available')
      end

      it 'sets due date to 2 weeks from now' do
        travel_to Time.zone.local(2026, 3, 31, 12, 0, 0) do
          post '/api/borrowings', params: { book_id: book.id }, headers: auth_headers(member)

          json = JSON.parse(response.body)
          due_date = Time.zone.parse(json['borrowing']['due_date'])
          expect(due_date.to_date).to eq(2.weeks.from_now.to_date)
        end
      end
    end

    context 'as librarian' do
      it 'returns forbidden' do
        post '/api/borrowings', params: { book_id: book.id }, headers: auth_headers(librarian)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH /api/borrowings/:id/return' do
    let!(:borrowing) { create(:borrowing, user: member, book: book) }

    before do
      book.update!(available_copies: 4)
    end

    context 'as librarian' do
      it 'marks the book as returned' do
        patch "/api/borrowings/#{borrowing.id}/return", headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['borrowing']['returned_at']).to be_present
      end

      it 'increments available copies' do
        patch "/api/borrowings/#{borrowing.id}/return", headers: auth_headers(librarian)

        expect(book.reload.available_copies).to eq(5)
      end

      it 'returns error when already returned' do
        borrowing.update!(returned_at: Time.current)

        patch "/api/borrowings/#{borrowing.id}/return", headers: auth_headers(librarian)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Book already returned')
      end
    end

    context 'as member' do
      it 'returns forbidden' do
        patch "/api/borrowings/#{borrowing.id}/return", headers: auth_headers(member)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
