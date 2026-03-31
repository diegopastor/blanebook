require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'validations' do
    subject { build(:book, isbn: 'ISBN-ABC-123') }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:genre) }
    it { is_expected.to validate_presence_of(:isbn) }
    it { is_expected.to validate_uniqueness_of(:isbn) }
    it { is_expected.to validate_presence_of(:total_copies) }
    it { is_expected.to validate_presence_of(:available_copies) }
    it { is_expected.to validate_numericality_of(:total_copies).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:available_copies).is_greater_than_or_equal_to(0) }

    it 'validates available_copies is not greater than total_copies' do
      book = build(:book, total_copies: 5, available_copies: 10)
      expect(book).not_to be_valid
      expect(book.errors[:available_copies]).to include('cannot be greater than total copies')
    end

    it 'is valid with valid attributes' do
      book = build(:book)
      expect(book).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:borrowings).dependent(:destroy) }
  end

  describe '#available?' do
    it 'returns true when available_copies is positive' do
      book = build(:book, available_copies: 1)
      expect(book.available?).to be true
    end

    it 'returns false when available_copies is zero' do
      book = build(:book, :unavailable)
      expect(book.available?).to be false
    end
  end

  describe '.search' do
    let!(:book1) { create(:book, title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Fiction') }
    let!(:book2) { create(:book, title: 'Clean Code', author: 'Robert Martin', genre: 'Technology') }
    let!(:book3) { create(:book, title: 'The Pragmatic Programmer', author: 'David Thomas', genre: 'Technology') }

    context 'without field specified' do
      it 'searches across title, author, and genre' do
        expect(Book.search('gatsby')).to contain_exactly(book1)
        expect(Book.search('technology')).to contain_exactly(book2, book3)
        expect(Book.search('martin')).to contain_exactly(book2)
      end
    end

    context 'with field specified' do
      it 'searches by title' do
        expect(Book.search('great', 'title')).to contain_exactly(book1)
      end

      it 'searches by author' do
        expect(Book.search('robert', 'author')).to contain_exactly(book2)
      end

      it 'searches by genre' do
        expect(Book.search('fiction', 'genre')).to contain_exactly(book1)
      end
    end

    it 'returns all books when query is blank' do
      expect(Book.search('')).to contain_exactly(book1, book2, book3)
      expect(Book.search(nil)).to contain_exactly(book1, book2, book3)
    end
  end
end
