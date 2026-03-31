import api from './api';
import type { LibrarianDashboard, MemberDashboard } from '../types';

export const dashboardService = {
  async getLibrarianDashboard(): Promise<LibrarianDashboard> {
    const response = await api.get<LibrarianDashboard>('/dashboard/librarian');
    return response.data;
  },

  async getMemberDashboard(): Promise<MemberDashboard> {
    const response = await api.get<MemberDashboard>('/dashboard/member');
    return response.data;
  },
};
