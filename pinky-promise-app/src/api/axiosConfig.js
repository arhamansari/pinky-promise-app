// src/api/axiosConfig.js
import axios from 'axios';

const axiosInstance = axios.create({
  // Don't set baseURL when using proxy in development
  // baseURL: 'http://localhost:8000',
  timeout: 8000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

// Add response interceptor for better debugging
axiosInstance.interceptors.response.use(
  response => response,
  error => {
    console.error("Axios error:", error.response ? error.response.data : error.message);
    return Promise.reject(error);
  }
);

export default axiosInstance;
