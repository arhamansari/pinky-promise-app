import axiosInstance from './axiosConfig';
// src/api/auth.js
import axios from './axiosConfig';

// Login function
export const loginUser = async (username, password) => {
  try {
    const response = await axiosInstance.post('/api/auth/login/', {
      username,
      password
    });
    // Store token in localStorage
    if (response.data.token) {
      localStorage.setItem('token', response.data.token);
      axiosInstance.defaults.headers.common['Authorization'] = `Token ${response.data.token}`;
    }
    return response.data;
  } catch (error) {
    throw error.response ? error.response.data : new Error('Network Error');
  }
};



export const registerUser = async (userData) => {
  try {
    // Make sure to include any necessary headers
    const response = await axios.post('/api/auth/register/', userData);
    return response.data;
  } catch (error) {
    // Better error handling that logs the specific error
    console.error("Registration error:", error.response ? error.response.data : error.message);
    throw error;
  }
};


// Logout function
export const logoutUser = () => {
  localStorage.removeItem('token');
  delete axiosInstance.defaults.headers.common['Authorization'];
};
