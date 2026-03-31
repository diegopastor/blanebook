import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { Layout } from '../components/Layout';
import { useAuth } from '../context/AuthContext';
import { bookService } from '../services/books';
import { borrowingService } from '../services/borrowings';
import type { Book, ApiError } from '../types';
import axios from 'axios';

export function BooksPage() {
  const { isLibrarian, isMember } = useAuth();
  const [books, setBooks] = useState<Book[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [search, setSearch] = useState('');
  const [searchField, setSearchField] = useState('');
  const [borrowingBookId, setBorrowingBookId] = useState<number | null>(null);
  const [borrowError, setBorrowError] = useState('');
  const [borrowSuccess, setBorrowSuccess] = useState('');

  const fetchBooks = async () => {
    try {
      const result = await bookService.getAll(search, searchField);
      setBooks(result.books);
    } catch {
      setError('Failed to load books');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchBooks();
  }, []);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    fetchBooks();
  };

  const handleBorrow = async (bookId: number) => {
    setBorrowingBookId(bookId);
    setBorrowError('');
    setBorrowSuccess('');

    try {
      await borrowingService.create(bookId);
      setBorrowSuccess('Book borrowed successfully!');
      fetchBooks();
    } catch (err) {
      if (axios.isAxiosError(err)) {
        const apiError = err.response?.data as ApiError;
        setBorrowError(apiError?.error || apiError?.errors?.join(', ') || 'Failed to borrow book');
      } else {
        setBorrowError('Failed to borrow book');
      }
    } finally {
      setBorrowingBookId(null);
    }
  };

  const handleDelete = async (bookId: number) => {
    if (!confirm('Are you sure you want to delete this book?')) return;

    try {
      await bookService.delete(bookId);
      fetchBooks();
    } catch {
      setError('Failed to delete book');
    }
  };

  return (
    <Layout>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Books</h1>
        {isLibrarian && (
          <Link
            to="/books/new"
            className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors"
          >
            Add Book
          </Link>
        )}
      </div>

      {(borrowError || borrowSuccess) && (
        <div
          className={`mb-4 p-4 rounded-md ${
            borrowError ? 'bg-red-50 text-red-700' : 'bg-green-50 text-green-700'
          }`}
        >
          {borrowError || borrowSuccess}
        </div>
      )}

      <form onSubmit={handleSearch} className="mb-6 flex gap-4">
        <input
          type="text"
          placeholder="Search books..."
          className="flex-1 px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <select
          className="px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
          value={searchField}
          onChange={(e) => setSearchField(e.target.value)}
        >
          <option value="">All fields</option>
          <option value="title">Title</option>
          <option value="author">Author</option>
          <option value="genre">Genre</option>
        </select>
        <button
          type="submit"
          className="px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors"
        >
          Search
        </button>
      </form>

      {isLoading ? (
        <div className="text-center py-8">Loading...</div>
      ) : error ? (
        <div className="text-center py-8 text-red-600">{error}</div>
      ) : books.length === 0 ? (
        <div className="text-center py-8 text-gray-500">No books found</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {books.map((book) => (
            <div key={book.id} className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-1">{book.title}</h3>
              <p className="text-sm text-gray-600 mb-2">{book.author}</p>
              <div className="flex flex-wrap gap-2 mb-3">
                <span className="px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded">
                  {book.genre}
                </span>
                <span className="px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded">
                  ISBN: {book.isbn}
                </span>
              </div>
              <div className="flex items-center justify-between mb-4">
                <span
                  className={`text-sm ${
                    book.available ? 'text-green-600' : 'text-red-600'
                  }`}
                >
                  {book.available_copies} / {book.total_copies} available
                </span>
              </div>
              <div className="flex gap-2">
                {isMember && book.available && (
                  <button
                    onClick={() => handleBorrow(book.id)}
                    disabled={borrowingBookId === book.id}
                    className="flex-1 px-3 py-2 bg-green-600 text-white text-sm rounded-md hover:bg-green-700 transition-colors disabled:opacity-50"
                  >
                    {borrowingBookId === book.id ? 'Borrowing...' : 'Borrow'}
                  </button>
                )}
                {isLibrarian && (
                  <>
                    <Link
                      to={`/books/${book.id}/edit`}
                      className="flex-1 px-3 py-2 bg-blue-600 text-white text-sm rounded-md hover:bg-blue-700 transition-colors text-center"
                    >
                      Edit
                    </Link>
                    <button
                      onClick={() => handleDelete(book.id)}
                      className="px-3 py-2 bg-red-600 text-white text-sm rounded-md hover:bg-red-700 transition-colors"
                    >
                      Delete
                    </button>
                  </>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </Layout>
  );
}
