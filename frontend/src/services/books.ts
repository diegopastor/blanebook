import api from './api';
import type { Book } from '../types';

export const bookService = {
  async getAll(search?: string, field?: string): Promise<{ books: Book[] }> {
    const params = new URLSearchParams();
    if (search) params.append('search', search);
    if (field) params.append('field', field);
    const response = await api.get<{ books: Book[] }>(`/books?${params}`);
    return response.data;
  },

  async getById(id: number): Promise<{ book: Book }> {
    const response = await api.get<{ book: Book }>(`/books/${id}`);
    return response.data;
  },

  async create(data: Omit<Book, 'id' | 'available'>): Promise<{ book: Book }> {
    const response = await api.post<{ book: Book }>('/books', data);
    return response.data;
  },

  async update(id: number, data: Partial<Omit<Book, 'id' | 'available'>>): Promise<{ book: Book }> {
    const response = await api.patch<{ book: Book }>(`/books/${id}`, data);
    return response.data;
  },

  async delete(id: number): Promise<{ message: string }> {
    const response = await api.delete<{ message: string }>(`/books/${id}`);
    return response.data;
  },
};
