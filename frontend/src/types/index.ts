export interface User {
  id: number;
  email: string;
  name: string;
  role: 'member' | 'librarian';
}

export interface Book {
  id: number;
  title: string;
  author: string;
  genre: string;
  isbn: string;
  total_copies: number;
  available_copies: number;
  available: boolean;
}

export interface Borrowing {
  id: number;
  borrowed_at: string;
  due_date: string;
  returned_at: string | null;
  overdue: boolean;
  book: {
    id: number;
    title: string;
    author: string;
  };
  user?: {
    id: number;
    name: string;
    email: string;
  };
}

export interface LibrarianDashboard {
  total_books: number;
  total_borrowed: number;
  due_today: number;
  members_with_overdue: {
    user: {
      id: number;
      name: string;
      email: string;
    };
    book: {
      id: number;
      title: string;
    };
    due_date: string;
    days_overdue: number;
  }[];
}

export interface MemberDashboard {
  borrowed_books: {
    id: number;
    book: {
      id: number;
      title: string;
      author: string;
    };
    borrowed_at: string;
    due_date: string;
    overdue: boolean;
    days_until_due: number | null;
  }[];
  overdue_books: {
    id: number;
    book: {
      id: number;
      title: string;
      author: string;
    };
    borrowed_at: string;
    due_date: string;
    overdue: boolean;
  }[];
}

export interface AuthResponse {
  user: User;
  token: string;
}

export interface ApiError {
  error?: string;
  errors?: string[];
}
