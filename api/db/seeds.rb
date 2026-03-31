# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create demo users
puts "Creating users..."

librarian = User.find_or_create_by!(email: "librarian@library.com") do |user|
  user.name = "Sarah Johnson"
  user.password = "password123"
  user.role = :librarian
end
puts "  Created librarian: #{librarian.email}"

member1 = User.find_or_create_by!(email: "member@library.com") do |user|
  user.name = "John Smith"
  user.password = "password123"
  user.role = :member
end
puts "  Created member: #{member1.email}"

member2 = User.find_or_create_by!(email: "jane.doe@example.com") do |user|
  user.name = "Jane Doe"
  user.password = "password123"
  user.role = :member
end
puts "  Created member: #{member2.email}"

member3 = User.find_or_create_by!(email: "bob.wilson@example.com") do |user|
  user.name = "Bob Wilson"
  user.password = "password123"
  user.role = :member
end
puts "  Created member: #{member3.email}"

# Create books
puts "Creating books..."

books_data = [
  { title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Fiction", isbn: "978-0-7432-7356-5", total_copies: 5, available_copies: 5 },
  { title: "To Kill a Mockingbird", author: "Harper Lee", genre: "Fiction", isbn: "978-0-06-112008-4", total_copies: 3, available_copies: 3 },
  { title: "1984", author: "George Orwell", genre: "Dystopian", isbn: "978-0-452-28423-4", total_copies: 4, available_copies: 4 },
  { title: "Pride and Prejudice", author: "Jane Austen", genre: "Romance", isbn: "978-0-14-143951-8", total_copies: 3, available_copies: 3 },
  { title: "The Catcher in the Rye", author: "J.D. Salinger", genre: "Fiction", isbn: "978-0-316-76948-0", total_copies: 2, available_copies: 2 },
  { title: "Clean Code", author: "Robert C. Martin", genre: "Technology", isbn: "978-0-13-235088-4", total_copies: 4, available_copies: 4 },
  { title: "The Pragmatic Programmer", author: "David Thomas", genre: "Technology", isbn: "978-0-13-595705-9", total_copies: 3, available_copies: 3 },
  { title: "Design Patterns", author: "Gang of Four", genre: "Technology", isbn: "978-0-201-63361-0", total_copies: 2, available_copies: 2 },
  { title: "The Hobbit", author: "J.R.R. Tolkien", genre: "Fantasy", isbn: "978-0-547-92822-7", total_copies: 5, available_copies: 5 },
  { title: "Harry Potter and the Sorcerer's Stone", author: "J.K. Rowling", genre: "Fantasy", isbn: "978-0-590-35340-3", total_copies: 6, available_copies: 6 },
  { title: "The Lord of the Rings", author: "J.R.R. Tolkien", genre: "Fantasy", isbn: "978-0-618-64015-7", total_copies: 4, available_copies: 4 },
  { title: "A Brief History of Time", author: "Stephen Hawking", genre: "Science", isbn: "978-0-553-38016-3", total_copies: 2, available_copies: 2 },
  { title: "Sapiens: A Brief History of Humankind", author: "Yuval Noah Harari", genre: "History", isbn: "978-0-06-231609-7", total_copies: 3, available_copies: 3 },
  { title: "The Art of War", author: "Sun Tzu", genre: "Philosophy", isbn: "978-1-59030-225-9", total_copies: 2, available_copies: 2 },
  { title: "Thinking, Fast and Slow", author: "Daniel Kahneman", genre: "Psychology", isbn: "978-0-374-53355-7", total_copies: 3, available_copies: 3 },
  { title: "The Lean Startup", author: "Eric Ries", genre: "Business", isbn: "978-0-307-88789-4", total_copies: 4, available_copies: 4 },
  { title: "Zero to One", author: "Peter Thiel", genre: "Business", isbn: "978-0-8041-3929-8", total_copies: 3, available_copies: 3 },
  { title: "Atomic Habits", author: "James Clear", genre: "Self-Help", isbn: "978-0-7352-1131-3", total_copies: 5, available_copies: 5 },
  { title: "The Alchemist", author: "Paulo Coelho", genre: "Fiction", isbn: "978-0-06-231500-7", total_copies: 4, available_copies: 4 },
  { title: "Crime and Punishment", author: "Fyodor Dostoevsky", genre: "Fiction", isbn: "978-0-14-044913-6", total_copies: 2, available_copies: 2 },
  { title: "The Brothers Karamazov", author: "Fyodor Dostoevsky", genre: "Fiction", isbn: "978-0-374-52837-9", total_copies: 2, available_copies: 2 },
  { title: "War and Peace", author: "Leo Tolstoy", genre: "Fiction", isbn: "978-0-14-303999-0", total_copies: 3, available_copies: 3 },
  { title: "Brave New World", author: "Aldous Huxley", genre: "Dystopian", isbn: "978-0-06-085052-4", total_copies: 3, available_copies: 3 },
  { title: "Dune", author: "Frank Herbert", genre: "Science Fiction", isbn: "978-0-441-17271-9", total_copies: 4, available_copies: 4 },
  { title: "Foundation", author: "Isaac Asimov", genre: "Science Fiction", isbn: "978-0-553-29335-7", total_copies: 3, available_copies: 3 },
]

books = books_data.map do |book_data|
  book = Book.find_or_create_by!(isbn: book_data[:isbn]) do |b|
    b.title = book_data[:title]
    b.author = book_data[:author]
    b.genre = book_data[:genre]
    b.total_copies = book_data[:total_copies]
    b.available_copies = book_data[:available_copies]
  end
  puts "  Created book: #{book.title}"
  book
end

# Create some borrowings
puts "Creating borrowings..."

# Member 1 has 2 active borrowings
book1 = books.find { |b| b.title == "Clean Code" }
book2 = books.find { |b| b.title == "The Pragmatic Programmer" }

borrowing1 = Borrowing.find_or_create_by!(user: member1, book: book1, returned_at: nil) do |b|
  b.borrowed_at = 1.week.ago
  b.due_date = 1.week.from_now
end
book1.update!(available_copies: book1.available_copies - 1) if borrowing1.persisted? && book1.available_copies > 0
puts "  Created borrowing: #{member1.name} borrowed '#{book1.title}'"

borrowing2 = Borrowing.find_or_create_by!(user: member1, book: book2, returned_at: nil) do |b|
  b.borrowed_at = 3.days.ago
  b.due_date = 11.days.from_now
end
book2.update!(available_copies: book2.available_copies - 1) if borrowing2.persisted? && book2.available_copies > 0
puts "  Created borrowing: #{member1.name} borrowed '#{book2.title}'"

# Member 2 has 1 overdue borrowing
book3 = books.find { |b| b.title == "The Great Gatsby" }
borrowing3 = Borrowing.find_or_create_by!(user: member2, book: book3, returned_at: nil) do |b|
  b.borrowed_at = 3.weeks.ago
  b.due_date = 1.week.ago
end
book3.update!(available_copies: book3.available_copies - 1) if borrowing3.persisted? && book3.available_copies > 0
puts "  Created overdue borrowing: #{member2.name} borrowed '#{book3.title}' (OVERDUE)"

# Member 3 has 1 returned borrowing and 1 active
book4 = books.find { |b| b.title == "1984" }
book5 = books.find { |b| b.title == "The Hobbit" }

Borrowing.find_or_create_by!(user: member3, book: book4) do |b|
  b.borrowed_at = 1.month.ago
  b.due_date = 2.weeks.ago
  b.returned_at = 3.weeks.ago
end
puts "  Created returned borrowing: #{member3.name} returned '#{book4.title}'"

borrowing5 = Borrowing.find_or_create_by!(user: member3, book: book5, returned_at: nil) do |b|
  b.borrowed_at = 5.days.ago
  b.due_date = 9.days.from_now
end
book5.update!(available_copies: book5.available_copies - 1) if borrowing5.persisted? && book5.available_copies > 0
puts "  Created borrowing: #{member3.name} borrowed '#{book5.title}'"

puts ""
puts "Seeding complete!"
puts ""
puts "Demo Credentials:"
puts "  Librarian: librarian@library.com / password123"
puts "  Member: member@library.com / password123"
puts ""
puts "Stats:"
puts "  Users: #{User.count}"
puts "  Books: #{Book.count}"
puts "  Active Borrowings: #{Borrowing.active.count}"
puts "  Overdue Borrowings: #{Borrowing.overdue.count}"
