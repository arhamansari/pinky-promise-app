// src/components/AuthPage.js
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import axiosInstance from '../api/axiosConfig'; // Use axiosInstance instead of axios
import './AuthPage.css'; // Make sure this file exists or create it

const AuthPage = () => {
  const [isLogin, setIsLogin] = useState(true);
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    try {
      if (isLogin) {
        // Login with JWT
        const response = await axios.post('/api/token/', {
          username,
          password
        });
        
        console.log('Login response:', response.data);
        
        if (response.data.access) {
          localStorage.setItem('accessToken', response.data.access);
          localStorage.setItem('refreshToken', response.data.refresh);
          
          // Redirect after successful login
          navigate('/');
        }
      } else {
        // Registration
        // Updated registration call
        const response = await axiosInstance.post('/api/auth/register/', {
          username,
          email,
          password
        });
        
        console.log('Registration successful:', response.data);
        setIsLogin(true);
        setError('Registration successful! Please login.');
      }
    } catch (err) {
      console.error('Auth error:', err);
      setError(err.response?.data?.detail || 'Authentication failed');
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-form-container">
        <h2>{isLogin ? 'Login' : 'Sign Up'}</h2>
        
        {error && <div className="auth-error">{error}</div>}
        
        <form onSubmit={handleSubmit}>
          {!isLogin && (
            <div className="form-group">
              <label>Email</label>
              <input 
                type="email" 
                value={email} 
                onChange={(e) => setEmail(e.target.value)} 
                required
              />
            </div>
          )}
          
          <div className="form-group">
            <label>Username</label>
            <input 
              type="text" 
              value={username} 
              onChange={(e) => setUsername(e.target.value)} 
              required
            />
          </div>
          
          <div className="form-group">
            <label>Password</label>
            <input 
              type="password" 
              value={password} 
              onChange={(e) => setPassword(e.target.value)} 
              required
            />
          </div>
          
          <button type="submit" className="auth-button">
            {isLogin ? 'Login' : 'Sign Up'}
          </button>
        </form>
        
        <div className="auth-switch">
          <p>
            {isLogin 
              ? "Don't have an account?" 
              : "Already have an account?"}
            <button 
              className="switch-button" 
              onClick={() => setIsLogin(!isLogin)}
            >
              {isLogin ? 'Sign Up' : 'Login'}
            </button>
          </p>
        </div>
      </div>
    </div>
  );
};

export default AuthPage;
