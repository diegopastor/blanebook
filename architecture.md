# Library Management System - Architecture & Design Choices

## 1. Overall Architecture

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│                 │  HTTP   │                 │   SQL   │                 │
│  React Frontend │◄───────►│  Rails API      │◄───────►│  PostgreSQL     │
│  (Port 5173)    │  JSON   │  (Port 3000)    │         │                 │
└─────────────────┘         └─────────────────┘         └─────────────────┘
```

### Monorepo Structure

```
blanebook/
├── api/          # Rails API backend
├── frontend/     # React frontend
└── README.md     # Project documentation
```

**Why Monorepo?** Simpler development workflow, shared README, easy deployment coordination, while still maintaining clear separation of concerns.

---

## 2. Backend Architecture (Rails API)

### Layer Structure

```
app/
├── controllers/api/     # Request handling
│   ├── auth_controller.rb
│   ├── books_controller.rb
│   ├── borrowings_controller.rb
│   └── dashboard_controller.rb
├── models/              # Business logic & validations
│   ├── user.rb
│   ├── book.rb
│   └── borrowing.rb
├── services/            # Extracted services
│   └── jwt_service.rb
└── errors/              # Custom exceptions
    └── authentication_error.rb
```

### Database Schema

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│    users     │       │  borrowings  │       │    books     │
├──────────────┤       ├──────────────┤       ├──────────────┤
│ id           │       │ id           │       │ id           │
│ email        │◄──────│ user_id      │       │ title        │
│ password_dig │       │ book_id      │──────►│ author       │
│ name         │       │ borrowed_at  │       │ genre        │
│ role (enum)  │       │ due_date     │       │ isbn         │
│ timestamps   │       │ returned_at  │       │ total_copies │
└──────────────┘       │ timestamps   │       │ avail_copies │
                       └──────────────┘       └──────────────┘
```

**Design Decisions:**
- `role` as integer enum (0=member, 1=librarian) - efficient storage, easy querying
- `available_copies` denormalized - avoids counting borrowings on every request
- `returned_at` nullable - NULL means active borrowing, timestamp means returned

---

## 3. Authentication Strategy

### JWT (JSON Web Tokens)

```ruby
# app/services/jwt_service.rb
class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base
  EXPIRATION_TIME = 24.hours

  def self.encode(payload)
    payload[:exp] = EXPIRATION_TIME.from_now.to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode(token)
    JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
  end
end
```

### Why JWT over Sessions?

| Sessions | JWT |
|----------|-----|
| Server stores state | Stateless |
| Requires cookies | Works with any client |
| Hard to scale horizontally | Easy horizontal scaling |
| Tight Rails coupling | Framework agnostic |

### Token Flow

```
1. User logs in → Server returns JWT
2. Frontend stores JWT in localStorage
3. Every request includes: Authorization: Bearer <token>
4. Server validates token, extracts user_id
```

---

## 4. Authorization Pattern

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  private

  def authenticate_user!
    # Extract token from Authorization header
    # Decode JWT and find user
    # Set @current_user or return 401
  end

  def authorize_librarian!
    render_forbidden unless current_user&.librarian?
  end

  def authorize_member!
    render_forbidden unless current_user&.member?
  end
end
```

**Applied via before_action:**

```ruby
class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_librarian!, only: [:create, :update, :destroy]
  # Members can view, only librarians can modify
end
```

---

## 5. Business Logic in Models

```ruby
# app/models/borrowing.rb
class Borrowing < ApplicationRecord
  # Validations enforce business rules
  validate :user_cannot_borrow_same_book_twice, on: :create
  validate :book_must_be_available, on: :create

  # Callbacks handle automatic behavior
  before_validation :set_dates, on: :create

  # Scopes for common queries
  scope :active, -> { where(returned_at: nil) }
  scope :overdue, -> { active.where("due_date < ?", Time.current) }

  private

  def set_dates
    self.borrowed_at ||= Time.current
    self.due_date ||= borrowed_at + 2.weeks  # Auto 2-week due date
  end
end
```

**Why Models for Business Logic?**
- Single source of truth for validation rules
- Rules enforced regardless of entry point (API, console, tests)
- Easy to test in isolation

---

## 6. Frontend Architecture (React)

### Component Structure

```
src/
├── components/          # Reusable UI components
│   ├── Layout.tsx       # Page wrapper with navbar
│   ├── Navbar.tsx       # Navigation bar
│   └── ProtectedRoute.tsx  # Auth guard
├── pages/               # Route-level components
│   ├── LoginPage.tsx
│   ├── DashboardPage.tsx
│   ├── BooksPage.tsx
│   └── ...
├── context/             # React Context for global state
│   └── AuthContext.tsx  # User auth state
├── services/            # API communication
│   ├── api.ts           # Axios instance
│   ├── auth.ts
│   ├── books.ts
│   └── ...
└── types/               # TypeScript definitions
    └── index.ts
```

### State Management Strategy

```tsx
// AuthContext.tsx - Global auth state via Context API
const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }) {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);

  // Persist to localStorage
  const login = async (email, password) => {
    const response = await authService.login(email, password);
    localStorage.setItem('token', response.token);
    setToken(response.token);
    setUser(response.user);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, isLibrarian }}>
      {children}
    </AuthContext.Provider>
  );
}
```

**Why Context API over Redux?**
- Simpler for auth state (single concern)
- Built into React (no extra dependency)
- Sufficient for this app's complexity level

---

## 7. API Communication Layer

```typescript
// services/api.ts - Centralized Axios instance
const api = axios.create({
  baseURL: 'http://localhost:3000/api',
});

// Interceptor automatically adds auth header
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle 401 globally - redirect to login
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### Service Pattern

```typescript
// services/books.ts - Type-safe API methods
export const bookService = {
  async getAll(search?: string): Promise<{ books: Book[] }> {
    const response = await api.get(`/books?search=${search}`);
    return response.data;
  },
  async create(data: BookInput): Promise<{ book: Book }> { ... },
  async update(id: number, data: Partial<BookInput>): Promise<{ book: Book }> { ... },
};
```

---

## 8. Styling with Tailwind CSS

```tsx
// Utility-first approach
<button className="px-4 py-2 bg-indigo-600 text-white rounded-md 
                   hover:bg-indigo-700 transition-colors disabled:opacity-50">
  Borrow Book
</button>
```

### Why Tailwind?

| Traditional CSS | Tailwind |
|-----------------|----------|
| Write custom CSS files | Use utility classes |
| Naming conventions needed | No naming required |
| Larger bundle (unused CSS) | PurgeCSS removes unused |
| Context switching | Stay in component |

---

## 9. Testing Strategy

```ruby
# spec/requests/api/books_spec.rb
RSpec.describe 'Api::Books', type: :request do
  describe 'POST /api/books' do
    context 'as librarian' do
      it 'creates a new book' do
        expect {
          post '/api/books', params: valid_params, headers: auth_headers(librarian)
        }.to change(Book, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'as member' do
      it 'returns forbidden' do
        post '/api/books', params: valid_params, headers: auth_headers(member)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
```

### Test Coverage

- **Model specs** - Validations, associations, scopes, methods
- **Request specs** - Full HTTP request/response cycle
- **Factories** - FactoryBot for test data generation

---

## 10. Key Design Principles Applied

| Principle | Application |
|-----------|-------------|
| **Separation of Concerns** | API vs Frontend, Controllers vs Models vs Services |
| **Single Responsibility** | JwtService only handles JWT, AuthController only handles auth |
| **DRY** | Shared auth helpers, reusable React components |
| **Fail Fast** | Model validations catch errors before database |
| **Convention over Configuration** | Rails conventions, standard React patterns |
| **Type Safety** | TypeScript for frontend, strong params in Rails |

---

## 11. Security Considerations

- **Passwords**: bcrypt hashing with `has_secure_password`
- **JWT**: HS256 signed, 24-hour expiration
- **CORS**: Configured for specific frontend origin
- **Authorization**: Role checks on every protected endpoint
- **Input Validation**: Rails strong parameters + model validations
- **SQL Injection**: ActiveRecord parameterized queries

---

This architecture provides a solid foundation that's easy to extend (add new roles, features) while maintaining clear boundaries between components.
