import { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { Layout } from '../components/Layout';
import { dashboardService } from '../services/dashboard';
import type { LibrarianDashboard, MemberDashboard } from '../types';

export function DashboardPage() {
  const { isLibrarian, isMember } = useAuth();

  return (
    <Layout>
      {isLibrarian && <LibrarianDashboardView />}
      {isMember && <MemberDashboardView />}
    </Layout>
  );
}

function LibrarianDashboardView() {
  const [data, setData] = useState<LibrarianDashboard | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchData = async () => {
      try {
        const result = await dashboardService.getLibrarianDashboard();
        setData(result);
      } catch {
        setError('Failed to load dashboard');
      } finally {
        setIsLoading(false);
      }
    };
    fetchData();
  }, []);

  if (isLoading) {
    return <div className="text-center py-8">Loading...</div>;
  }

  if (error) {
    return <div className="text-center py-8 text-red-600">{error}</div>;
  }

  if (!data) {
    return null;
  }

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-8">Librarian Dashboard</h1>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <StatCard title="Total Books" value={data.total_books} color="bg-blue-500" />
        <StatCard title="Currently Borrowed" value={data.total_borrowed} color="bg-yellow-500" />
        <StatCard title="Due Today" value={data.due_today} color="bg-orange-500" />
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Members with Overdue Books</h2>
        {data.members_with_overdue.length === 0 ? (
          <p className="text-gray-500">No overdue books</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Member
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Book
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Due Date
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Days Overdue
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {data.members_with_overdue.map((item, index) => (
                  <tr key={index}>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">{item.user.name}</div>
                      <div className="text-sm text-gray-500">{item.user.email}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {item.book.title}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {new Date(item.due_date).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2 py-1 text-xs font-medium bg-red-100 text-red-800 rounded-full">
                        {item.days_overdue} days
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}

function MemberDashboardView() {
  const [data, setData] = useState<MemberDashboard | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchData = async () => {
      try {
        const result = await dashboardService.getMemberDashboard();
        setData(result);
      } catch {
        setError('Failed to load dashboard');
      } finally {
        setIsLoading(false);
      }
    };
    fetchData();
  }, []);

  if (isLoading) {
    return <div className="text-center py-8">Loading...</div>;
  }

  if (error) {
    return <div className="text-center py-8 text-red-600">{error}</div>;
  }

  if (!data) {
    return null;
  }

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-8">My Dashboard</h1>

      {data.overdue_books.length > 0 && (
        <div className="mb-8 p-4 bg-red-50 border border-red-200 rounded-lg">
          <h2 className="text-lg font-semibold text-red-800 mb-2">⚠️ Overdue Books</h2>
          <ul className="space-y-2">
            {data.overdue_books.map((item) => (
              <li key={item.id} className="text-sm text-red-700">
                <strong>{item.book.title}</strong> by {item.book.author} - Due:{' '}
                {new Date(item.due_date).toLocaleDateString()}
              </li>
            ))}
          </ul>
        </div>
      )}

      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Currently Borrowed Books</h2>
        {data.borrowed_books.length === 0 ? (
          <p className="text-gray-500">You haven't borrowed any books</p>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {data.borrowed_books.map((item) => (
              <div
                key={item.id}
                className={`p-4 rounded-lg border ${
                  item.overdue ? 'border-red-300 bg-red-50' : 'border-gray-200 bg-gray-50'
                }`}
              >
                <h3 className="font-medium text-gray-900">{item.book.title}</h3>
                <p className="text-sm text-gray-500">{item.book.author}</p>
                <div className="mt-2 text-sm">
                  <p>
                    <span className="text-gray-500">Borrowed:</span>{' '}
                    {new Date(item.borrowed_at).toLocaleDateString()}
                  </p>
                  <p>
                    <span className="text-gray-500">Due:</span>{' '}
                    {new Date(item.due_date).toLocaleDateString()}
                  </p>
                  {item.overdue ? (
                    <span className="inline-block mt-1 px-2 py-1 text-xs font-medium bg-red-100 text-red-800 rounded-full">
                      Overdue
                    </span>
                  ) : (
                    <span className="inline-block mt-1 px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-full">
                      {item.days_until_due} days left
                    </span>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function StatCard({ title, value, color }: { title: string; value: number; color: string }) {
  return (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex items-center">
        <div className={`flex-shrink-0 ${color} rounded-md p-3`}>
          <svg className="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
          </svg>
        </div>
        <div className="ml-5">
          <p className="text-sm font-medium text-gray-500">{title}</p>
          <p className="text-2xl font-semibold text-gray-900">{value}</p>
        </div>
      </div>
    </div>
  );
}
