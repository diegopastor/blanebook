require 'rails_helper'

RSpec.describe 'Api::Dashboard', type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }

  describe 'GET /api/dashboard/librarian' do
    context 'as librarian' do
      let!(:book1) { create(:book) }
      let!(:book2) { create(:book) }
      let!(:active_borrowing) { create(:borrowing) }
      let!(:overdue_borrowing) { create(:borrowing, :overdue) }

      it 'returns dashboard statistics' do
        get '/api/dashboard/librarian', headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['total_books']).to eq(4) # 2 books + 2 from borrowings
        expect(json['total_borrowed']).to eq(2)
        expect(json['members_with_overdue']).to be_an(Array)
      end

      it 'includes overdue member details' do
        get '/api/dashboard/librarian', headers: auth_headers(librarian)

        json = JSON.parse(response.body)
        overdue_entry = json['members_with_overdue'].find { |m| m['user']['id'] == overdue_borrowing.user_id }
        expect(overdue_entry['user']['name']).to be_present
        expect(overdue_entry['book']['title']).to be_present
        expect(overdue_entry['days_overdue']).to be > 0
      end

      context 'with books due today' do
        let!(:due_today_borrowing) do
          create(:borrowing, borrowed_at: 2.weeks.ago, due_date: Time.current)
        end

        it 'counts books due today' do
          get '/api/dashboard/librarian', headers: auth_headers(librarian)

          json = JSON.parse(response.body)
          expect(json['due_today']).to be >= 1
        end
      end
    end

    context 'as member' do
      it 'returns forbidden' do
        get '/api/dashboard/librarian', headers: auth_headers(member)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /api/dashboard/member' do
    context 'as member' do
      let!(:active_borrowing) { create(:borrowing, user: member) }
      let!(:overdue_borrowing) { create(:borrowing, :overdue, user: member) }
      let!(:returned_borrowing) { create(:borrowing, :returned, user: member) }

      it 'returns member dashboard data' do
        get '/api/dashboard/member', headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['borrowed_books']).to be_an(Array)
        expect(json['overdue_books']).to be_an(Array)
      end

      it 'includes active borrowed books' do
        get '/api/dashboard/member', headers: auth_headers(member)

        json = JSON.parse(response.body)
        borrowed_ids = json['borrowed_books'].map { |b| b['id'] }
        expect(borrowed_ids).to include(active_borrowing.id, overdue_borrowing.id)
        expect(borrowed_ids).not_to include(returned_borrowing.id)
      end

      it 'includes overdue books' do
        get '/api/dashboard/member', headers: auth_headers(member)

        json = JSON.parse(response.body)
        overdue_ids = json['overdue_books'].map { |b| b['id'] }
        expect(overdue_ids).to include(overdue_borrowing.id)
        expect(overdue_ids).not_to include(active_borrowing.id)
      end

      it 'includes book details' do
        get '/api/dashboard/member', headers: auth_headers(member)

        json = JSON.parse(response.body)
        expect(json['borrowed_books'][0]['book']['title']).to be_present
        expect(json['borrowed_books'][0]['due_date']).to be_present
      end
    end

    context 'as librarian' do
      it 'returns forbidden' do
        get '/api/dashboard/member', headers: auth_headers(librarian)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
