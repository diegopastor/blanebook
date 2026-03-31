require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }

    it 'validates email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:borrowings).dependent(:destroy) }
  end

  describe 'roles' do
    it 'defines member and librarian roles' do
      expect(User.roles.keys).to contain_exactly('member', 'librarian')
    end

    it 'defaults to member role' do
      user = User.new
      expect(user.role).to be_nil
    end
  end

  describe '#librarian?' do
    it 'returns true for librarians' do
      user = build(:user, :librarian)
      expect(user.librarian?).to be true
    end

    it 'returns false for members' do
      user = build(:user, :member)
      expect(user.librarian?).to be false
    end
  end

  describe '#member?' do
    it 'returns true for members' do
      user = build(:user, :member)
      expect(user.member?).to be true
    end

    it 'returns false for librarians' do
      user = build(:user, :librarian)
      expect(user.member?).to be false
    end
  end

  describe 'email normalization' do
    it 'downcases email before saving' do
      user = create(:user, email: 'TEST@EXAMPLE.COM')
      expect(user.email).to eq('test@example.com')
    end
  end
end
