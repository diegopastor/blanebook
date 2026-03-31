FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    author { Faker::Book.author }
    genre { Faker::Book.genre }
    sequence(:isbn) { |n| "978-0-#{rand(100..999)}-#{rand(10000..99999)}-#{n}" }
    total_copies { 5 }
    available_copies { 5 }

    trait :unavailable do
      available_copies { 0 }
    end

    trait :single_copy do
      total_copies { 1 }
      available_copies { 1 }
    end
  end
end
