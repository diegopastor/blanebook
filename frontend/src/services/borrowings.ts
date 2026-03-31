import api from './api';
import type { Borrowing } from '../types';

export const borrowingService = {
  async getAll(filters?: { active?: boolean; overdue?: boolean }): Promise<{ borrowings: Borrowing[] }> {
    const params = new URLSearchParams();
    if (filters?.active) params.append('active', 'true');
    if (filters?.overdue) params.append('overdue', 'true');
    const response = await api.get<{ borrowings: Borrowing[] }>(`/borrowings?${params}`);
    return response.data;
  },

  async create(bookId: number): Promise<{ borrowing: Borrowing }> {
    const response = await api.post<{ borrowing: Borrowing }>('/borrowings', { book_id: bookId });
    return response.data;
  },

  async returnBook(id: number): Promise<{ borrowing: Borrowing }> {
    const response = await api.patch<{ borrowing: Borrowing }>(`/borrowings/${id}/return`);
    return response.data;
  },
};
