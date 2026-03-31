# Library Management System

A full-stack library management application built with Ruby on Rails (API) and React (Frontend). The system supports two user roles: **Librarian** and **Member**, with comprehensive book management, borrowing, and dashboard features.

## 🚀 Tech Stack

### Backend
- **Ruby on Rails 7** (API mode)
- **PostgreSQL** database
- **JWT** authentication
- **RSpec** for testing

### Frontend
- **React 18** with TypeScript
- **Vite** build tool
- **Tailwind CSS** for styling
- **React Router** for navigation
- **Axios** for API calls

## 📋 Features

### Authentication & Authorization
- User registration and login with JWT tokens
- Role-based access control (Librarian/Member)

### Book Management (Librarian Only)
- Add, edit, and delete books
- Track total and available copies
- Book details: title, author, genre, ISBN

### Search
- Search books by title, author, or genre
- Filter by specific fields or search across all

### Borrowing System
- Members can borrow available books
- Automatic 2-week due date calculation
- Prevents duplicate borrowing of the same book
- Librarians can mark books as returned

### Dashboards
- **Librarian Dashboard**: Total books, borrowed count, due today, overdue members list
- **Member Dashboard**: Borrowed books with due dates, overdue warnings

## 🛠️ Setup Instructions

### Prerequisites
- Ruby 3.1.x
- Node.js 18+
- PostgreSQL
- Bundler

### Backend Setup

```bash
# Navigate to API directory
cd api

# Install dependencies
bundle install

# Create and setup database
rails db:create
rails db:migrate
rails db:seed

# Start the Rails server
rails server
```

The API will be available at `http://localhost:3000`

### Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

The frontend will be available at `http://localhost:5173`

## 🔑 Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Librarian | librarian@library.com | password123 |
| Member | member@library.com | password123 |

## 📡 API Endpoints

### Authentication
| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| POST | /api/auth/register | Register new user | Public |
| POST | /api/auth/login | Login | Public |
| DELETE | /api/auth/logout | Logout | Authenticated |
| GET | /api/auth/me | Get current user | Authenticated |

### Books
| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| GET | /api/books | List books (with search) | Authenticated |
| GET | /api/books/:id | Get book details | Authenticated |
| POST | /api/books | Create book | Librarian |
| PATCH | /api/books/:id | Update book | Librarian |
| DELETE | /api/books/:id | Delete book | Librarian |

### Borrowings
| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| GET | /api/borrowings | List borrowings | Authenticated |
| POST | /api/borrowings | Borrow a book | Member |
| PATCH | /api/borrowings/:id/return | Return a book | Librarian |

### Dashboard
| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| GET | /api/dashboard/librarian | Librarian stats | Librarian |
| GET | /api/dashboard/member | Member stats | Member |

### Search Parameters

Books can be searched using query parameters:
- `?search=term` - Search across all fields
- `?search=term&field=title` - Search by specific field (title, author, or genre)

## 🧪 Running Tests

```bash
cd api
bundle exec rspec
```

Current test coverage includes:
- Model validations and associations
- Request specs for all API endpoints
- Authentication and authorization tests
- Business logic tests (borrowing rules, availability, etc.)

## 📁 Project Structure

```
blanebook/
├── api/                          # Rails API
│   ├── app/
│   │   ├── controllers/api/      # API controllers
│   │   ├── models/               # ActiveRecord models
│   │   ├── services/             # JWT service
│   │   └── errors/               # Custom errors
│   ├── spec/                     # RSpec tests
│   │   ├── models/
│   │   ├── requests/
│   │   └── factories/
│   └── db/
│       ├── migrate/
│       └── seeds.rb
├── frontend/                     # React App
│   ├── src/
│   │   ├── components/           # Reusable components
│   │   ├── pages/                # Page components
│   │   ├── context/              # React context (Auth)
│   │   ├── services/             # API services
│   │   └── types/                # TypeScript types
│   └── package.json
└── README.md
```

## 🎯 Key Implementation Details

### JWT Authentication
- Tokens expire after 24 hours
- Token passed via Authorization header: `Bearer <token>`
- Automatic token refresh on 401 responses

### Borrowing Rules
- Members cannot borrow the same book twice (until returned)
- Books cannot be borrowed if no copies are available
- Due date is automatically set to 2 weeks from borrowing date

### Role-Based Access
- Librarians: Full CRUD on books, can return borrowed books, access librarian dashboard
- Members: Can view books, borrow available books, access member dashboard

## 🌐 CORS Configuration

The API is configured to accept requests from `http://localhost:5173` (Vite development server).

## 📝 License

MIT
