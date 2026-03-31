import api from './api';
import type { AuthResponse, User } from '../types';

export const authService = {
  async register(data: {
    email: string;
    password: string;
    password_confirmation: string;
    name: string;
    role: 'member' | 'librarian';
  }): Promise<AuthResponse> {
    const response = await api.post<AuthResponse>('/auth/register', data);
    return response.data;
  },

  async login(email: string, password: string): Promise<AuthResponse> {
    const response = await api.post<AuthResponse>('/auth/login', { email, password });
    return response.data;
  },

  async logout(): Promise<void> {
    await api.delete('/auth/logout');
  },

  async getMe(): Promise<{ user: User }> {
    const response = await api.get<{ user: User }>('/auth/me');
    return response.data;
  },
};
