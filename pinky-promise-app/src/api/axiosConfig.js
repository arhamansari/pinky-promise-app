// src/api/axiosConfig.js
import axios from 'axios';

// Create an instance with your backend URL
const axiosInstance = axios.create({
  baseURL: 'http://localhost:8000', // Update with your backend URL
  timeout: 5000,
  headers: {
    'Content-Type': 'application/json',
  }
});

// Add a request interceptor to include the JWT token
axiosInstance.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken');
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add a response interceptor to handle token refresh
axiosInstance.interceptors.response.use(
  (response) => {
    return response;
  },
  async (error) => {
    const originalRequest = error.config;
    
    // If error is 401 and we haven't already tried refreshing
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        const refreshToken = localStorage.getItem('refreshToken');
        if (!refreshToken) {
          throw new Error('No refresh token available');
        }
        
        const response = await axios.post('/api/token/refresh/', {
          refresh: refreshToken
        });
        
        if (response.data.access) {
          localStorage.setItem('accessToken', response.data.access);
          axios.defaults.headers.common['Authorization'] = `Bearer ${response.data.access}`;
          
          // Update the original request authorization header
          originalRequest.headers['Authorization'] = `Bearer ${response.data.access}`;
          
          // Retry the original request
          return axios(originalRequest);
        }
      } catch (refreshError) {
        // If refresh fails, redirect to login
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
        localStorage.removeItem('user');
        window.location.href = '/auth';
        return Promise.reject(refreshError);
      }
    }
    
    return Promise.reject(error);
  }
);

export default axiosInstance;
