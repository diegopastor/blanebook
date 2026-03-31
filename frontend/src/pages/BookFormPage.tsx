import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Layout } from '../components/Layout';
import { bookService } from '../services/books';
import type { ApiError } from '../types';
import axios from 'axios';

interface BookFormData {
  title: string;
  author: string;
  genre: string;
  isbn: string;
  total_copies: number;
  available_copies: number;
}

export function BookFormPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEdit = Boolean(id);

  const [formData, setFormData] = useState<BookFormData>({
    title: '',
    author: '',
    genre: '',
    isbn: '',
    total_copies: 1,
    available_copies: 1,
  });
  const [isLoading, setIsLoading] = useState(false);
  const [isFetching, setIsFetching] = useState(isEdit);
  const [error, setError] = useState('');

  useEffect(() => {
    if (isEdit && id) {
      const fetchBook = async () => {
        try {
          const { book } = await bookService.getById(parseInt(id));
          setFormData({
            title: book.title,
            author: book.author,
            genre: book.genre,
            isbn: book.isbn,
            total_copies: book.total_copies,
            available_copies: book.available_copies,
          });
        } catch {
          setError('Failed to load book');
        } finally {
          setIsFetching(false);
        }
      };
      fetchBook();
    }
  }, [id, isEdit]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'number' ? parseInt(value) || 0 : value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      if (isEdit && id) {
        await bookService.update(parseInt(id), formData);
      } else {
        await bookService.create(formData);
      }
      navigate('/books');
    } catch (err) {
      if (axios.isAxiosError(err)) {
        const apiError = err.response?.data as ApiError;
        setError(apiError?.error || apiError?.errors?.join(', ') || 'Failed to save book');
      } else {
        setError('An unexpected error occurred');
      }
    } finally {
      setIsLoading(false);
    }
  };

  if (isFetching) {
    return (
      <Layout>
        <div className="text-center py-8">Loading...</div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="max-w-2xl mx-auto">
        <h1 className="text-2xl font-bold text-gray-900 mb-6">
          {isEdit ? 'Edit Book' : 'Add New Book'}
        </h1>

        <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow p-6 space-y-4">
          {error && (
            <div className="p-4 bg-red-50 text-red-700 rounded-md">{error}</div>
          )}

          <div>
            <label htmlFor="title" className="block text-sm font-medium text-gray-700">
              Title
            </label>
            <input
              id="title"
              name="title"
              type="text"
              required
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
              value={formData.title}
              onChange={handleChange}
            />
          </div>

          <div>
            <label htmlFor="author" className="block text-sm font-medium text-gray-700">
              Author
            </label>
            <input
              id="author"
              name="author"
              type="text"
              required
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
              value={formData.author}
              onChange={handleChange}
            />
          </div>

          <div>
            <label htmlFor="genre" className="block text-sm font-medium text-gray-700">
              Genre
            </label>
            <input
              id="genre"
              name="genre"
              type="text"
              required
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
              value={formData.genre}
              onChange={handleChange}
            />
          </div>

          <div>
            <label htmlFor="isbn" className="block text-sm font-medium text-gray-700">
              ISBN
            </label>
            <input
              id="isbn"
              name="isbn"
              type="text"
              required
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
              value={formData.isbn}
              onChange={handleChange}
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="total_copies" className="block text-sm font-medium text-gray-700">
                Total Copies
              </label>
              <input
                id="total_copies"
                name="total_copies"
                type="number"
                min="0"
                required
                className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                value={formData.total_copies}
                onChange={handleChange}
              />
            </div>

            <div>
              <label htmlFor="available_copies" className="block text-sm font-medium text-gray-700">
                Available Copies
              </label>
              <input
                id="available_copies"
                name="available_copies"
                type="number"
                min="0"
                required
                className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                value={formData.available_copies}
                onChange={handleChange}
              />
            </div>
          </div>

          <div className="flex gap-4 pt-4">
            <button
              type="submit"
              disabled={isLoading}
              className="flex-1 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
            >
              {isLoading ? 'Saving...' : isEdit ? 'Update Book' : 'Add Book'}
            </button>
            <button
              type="button"
              onClick={() => navigate('/books')}
              className="flex-1 py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </Layout>
  );
}
