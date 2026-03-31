import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export function Navbar() {
  const { user, logout, isLibrarian } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  if (!user) return null;

  return (
    <nav className="bg-indigo-600 text-white shadow-lg">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex items-center">
            <Link to="/dashboard" className="flex items-center space-x-2">
              <svg className="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
              </svg>
              <span className="font-bold text-xl">Library</span>
            </Link>
          </div>

          <div className="flex items-center space-x-4">
            <Link
              to="/books"
              className="px-3 py-2 rounded-md text-sm font-medium hover:bg-indigo-500 transition-colors"
            >
              Books
            </Link>
            {isLibrarian && (
              <Link
                to="/borrowings"
                className="px-3 py-2 rounded-md text-sm font-medium hover:bg-indigo-500 transition-colors"
              >
                Borrowings
              </Link>
            )}
            <span className="text-sm">
              {user.name} ({user.role})
            </span>
            <button
              onClick={handleLogout}
              className="px-3 py-2 rounded-md text-sm font-medium bg-indigo-700 hover:bg-indigo-800 transition-colors"
            >
              Logout
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
}
