// src/api/auth.js
import axiosInstance from './axiosConfig';

// Login function
export const loginUser = async (username, password) => {
  try {
    const response = await axiosInstance.post('/api/auth/login/', {
      username,
      password
    });

    // Store tokens in localStorage
    if (response.data.access && response.data.refresh) {
      localStorage.setItem('accessToken', response.data.access);
      localStorage.setItem('refreshToken', response.data.refresh);
      axiosInstance.defaults.headers.common['Authorization'] = `Bearer ${response.data.access}`;
      
      // Store user data if available
      if (response.data.user) {
        localStorage.setItem('user', JSON.stringify(response.data.user));
      }
    }
    
    return response.data;
  } catch (error) {
    throw error.response ? error.response.data : new Error('Network Error');
  }
};

// Register function
export const registerUser = async (userData) => {
  try {
    const response = await axiosInstance.post('/api/auth/register/', userData);
    return response.data;
  } catch (error) {
    console.error("Registration error:", error.response ? error.response.data : error.message);
    throw error;
  }
};

// Logout function
export const logoutUser = () => {
  localStorage.removeItem('accessToken');
  localStorage.removeItem('refreshToken');
  localStorage.removeItem('user');
  delete axiosInstance.defaults.headers.common['Authorization'];
};

// Token refresh function
export const refreshToken = async () => {
  try {
    const refreshToken = localStorage.getItem('refreshToken');
    if (!refreshToken) {
      throw new Error('No refresh token available');
    }
    
    const response = await axiosInstance.post('/api/token/refresh/', {
      refresh: refreshToken
    });
    
    if (response.data.access) {
      localStorage.setItem('accessToken', response.data.access);
      axiosInstance.defaults.headers.common['Authorization'] = `Bearer ${response.data.access}`;
    }
    
    return response.data;
  } catch (error) {
    // If refresh fails, logout user
    logoutUser();
    throw error;
  }
};
