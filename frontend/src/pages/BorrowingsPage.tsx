import { useEffect, useState } from 'react';
import { Layout } from '../components/Layout';
import { borrowingService } from '../services/borrowings';
import type { Borrowing, ApiError } from '../types';
import axios from 'axios';

export function BorrowingsPage() {
  const [borrowings, setBorrowings] = useState<Borrowing[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [filter, setFilter] = useState<'all' | 'active' | 'overdue'>('all');
  const [returningId, setReturningId] = useState<number | null>(null);
  const [actionError, setActionError] = useState('');

  const fetchBorrowings = async () => {
    try {
      const filters =
        filter === 'active'
          ? { active: true }
          : filter === 'overdue'
          ? { overdue: true }
          : undefined;
      const result = await borrowingService.getAll(filters);
      setBorrowings(result.borrowings);
    } catch {
      setError('Failed to load borrowings');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    setIsLoading(true);
    fetchBorrowings();
  }, [filter]);

  const handleReturn = async (id: number) => {
    setReturningId(id);
    setActionError('');

    try {
      await borrowingService.returnBook(id);
      fetchBorrowings();
    } catch (err) {
      if (axios.isAxiosError(err)) {
        const apiError = err.response?.data as ApiError;
        setActionError(apiError?.error || apiError?.errors?.join(', ') || 'Failed to return book');
      } else {
        setActionError('Failed to return book');
      }
    } finally {
      setReturningId(null);
    }
  };

  return (
    <Layout>
      <h1 className="text-2xl font-bold text-gray-900 mb-6">Borrowings</h1>

      <div className="mb-6 flex gap-4">
        <button
          onClick={() => setFilter('all')}
          className={`px-4 py-2 rounded-md ${
            filter === 'all'
              ? 'bg-indigo-600 text-white'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          All
        </button>
        <button
          onClick={() => setFilter('active')}
          className={`px-4 py-2 rounded-md ${
            filter === 'active'
              ? 'bg-indigo-600 text-white'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          Active
        </button>
        <button
          onClick={() => setFilter('overdue')}
          className={`px-4 py-2 rounded-md ${
            filter === 'overdue'
              ? 'bg-indigo-600 text-white'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          Overdue
        </button>
      </div>

      {actionError && (
        <div className="mb-4 p-4 bg-red-50 text-red-700 rounded-md">{actionError}</div>
      )}

      {isLoading ? (
        <div className="text-center py-8">Loading...</div>
      ) : error ? (
        <div className="text-center py-8 text-red-600">{error}</div>
      ) : borrowings.length === 0 ? (
        <div className="text-center py-8 text-gray-500">No borrowings found</div>
      ) : (
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Book
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Member
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Borrowed
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Due Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {borrowings.map((borrowing) => (
                <tr key={borrowing.id}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{borrowing.book.title}</div>
                    <div className="text-sm text-gray-500">{borrowing.book.author}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {borrowing.user ? (
                      <>
                        <div className="text-sm font-medium text-gray-900">{borrowing.user.name}</div>
                        <div className="text-sm text-gray-500">{borrowing.user.email}</div>
                      </>
                    ) : (
                      <span className="text-sm text-gray-500">-</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(borrowing.borrowed_at).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(borrowing.due_date).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {borrowing.returned_at ? (
                      <span className="px-2 py-1 text-xs font-medium bg-gray-100 text-gray-800 rounded-full">
                        Returned
                      </span>
                    ) : borrowing.overdue ? (
                      <span className="px-2 py-1 text-xs font-medium bg-red-100 text-red-800 rounded-full">
                        Overdue
                      </span>
                    ) : (
                      <span className="px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-full">
                        Active
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {!borrowing.returned_at && (
                      <button
                        onClick={() => handleReturn(borrowing.id)}
                        disabled={returningId === borrowing.id}
                        className="px-3 py-1 bg-blue-600 text-white text-sm rounded-md hover:bg-blue-700 transition-colors disabled:opacity-50"
                      >
                        {returningId === borrowing.id ? 'Returning...' : 'Return'}
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </Layout>
  );
}
