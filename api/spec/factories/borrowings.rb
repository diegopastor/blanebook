FactoryBot.define do
  factory :borrowing do
    association :user, factory: [ :user, :member ]
    association :book
    borrowed_at { Time.current }
    due_date { 2.weeks.from_now }
    returned_at { nil }

    trait :returned do
      returned_at { 1.week.from_now }
    end

    trait :overdue do
      borrowed_at { 3.weeks.ago }
      due_date { 1.week.ago }
      returned_at { nil }
    end

    trait :due_today do
      borrowed_at { 2.weeks.ago }
      due_date { Time.current }
      returned_at { nil }
    end
  end
end
