require 'rails_helper'

RSpec.describe Borrowing, type: :model do
  describe 'validations' do
    it 'validates presence of borrowed_at' do
      borrowing = Borrowing.new(user: create(:user, :member), book: create(:book), borrowed_at: nil, due_date: nil)
      # The callback sets borrowed_at, so we need to check after validation
      borrowing.valid?
      expect(borrowing.borrowed_at).to be_present
    end

    it 'validates presence of due_date' do
      borrowing = Borrowing.new(user: create(:user, :member), book: create(:book), borrowed_at: nil, due_date: nil)
      # The callback sets due_date, so we need to check after validation
      borrowing.valid?
      expect(borrowing.due_date).to be_present
    end

    it 'prevents borrowing the same book twice' do
      user = create(:user, :member)
      book = create(:book)
      create(:borrowing, user: user, book: book)

      duplicate = build(:borrowing, user: user, book: book)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:base]).to include('You have already borrowed this book')
    end

    it 'allows borrowing after returning the book' do
      user = create(:user, :member)
      book = create(:book)
      create(:borrowing, :returned, user: user, book: book)

      new_borrowing = build(:borrowing, user: user, book: book)
      expect(new_borrowing).to be_valid
    end

    it 'prevents borrowing when book is unavailable' do
      user = create(:user, :member)
      book = create(:book, :unavailable)

      borrowing = build(:borrowing, user: user, book: book)
      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:base]).to include('This book is not available')
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:book) }
  end

  describe 'callbacks' do
    it 'sets borrowed_at to current time if not provided' do
      borrowing = create(:borrowing, borrowed_at: nil)
      expect(borrowing.borrowed_at).to be_present
    end

    it 'sets due_date to 2 weeks from borrowed_at' do
      travel_to Time.zone.local(2026, 3, 31, 12, 0, 0) do
        borrowing = create(:borrowing, borrowed_at: Time.current, due_date: nil)
        expect(borrowing.due_date).to eq(2.weeks.from_now)
      end
    end
  end

  describe 'scopes' do
    let!(:active_borrowing) { create(:borrowing) }
    let!(:returned_borrowing) { create(:borrowing, :returned) }
    let!(:overdue_borrowing) { create(:borrowing, :overdue) }

    describe '.active' do
      it 'returns only unreturned borrowings' do
        expect(Borrowing.active).to include(active_borrowing, overdue_borrowing)
        expect(Borrowing.active).not_to include(returned_borrowing)
      end
    end

    describe '.returned' do
      it 'returns only returned borrowings' do
        expect(Borrowing.returned).to contain_exactly(returned_borrowing)
      end
    end

    describe '.overdue' do
      it 'returns only overdue borrowings' do
        expect(Borrowing.overdue).to contain_exactly(overdue_borrowing)
      end
    end
  end

  describe '#overdue?' do
    it 'returns true when due_date has passed and not returned' do
      borrowing = build(:borrowing, :overdue)
      expect(borrowing.overdue?).to be true
    end

    it 'returns false when due_date has not passed' do
      borrowing = build(:borrowing)
      expect(borrowing.overdue?).to be false
    end

    it 'returns false when book is returned' do
      borrowing = build(:borrowing, due_date: 1.week.ago, returned_at: Time.current)
      expect(borrowing.overdue?).to be false
    end
  end

  describe '#returned?' do
    it 'returns true when returned_at is present' do
      borrowing = build(:borrowing, :returned)
      expect(borrowing.returned?).to be true
    end

    it 'returns false when returned_at is nil' do
      borrowing = build(:borrowing)
      expect(borrowing.returned?).to be false
    end
  end

  describe '#mark_as_returned!' do
    it 'sets returned_at and increments available_copies' do
      book = create(:book, total_copies: 5, available_copies: 4)
      borrowing = create(:borrowing, book: book)

      expect { borrowing.mark_as_returned! }.to change { book.reload.available_copies }.by(1)
      expect(borrowing.returned_at).to be_present
    end

    it 'returns false if already returned' do
      borrowing = create(:borrowing, :returned)
      expect(borrowing.mark_as_returned!).to be false
    end
  end
end
