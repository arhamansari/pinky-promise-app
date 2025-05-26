// src/components/AuthPage.js
import React, { useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import ReCAPTCHA from 'react-google-recaptcha';
import axiosInstance from '../api/axiosConfig';
import './AuthPage.css';

const AuthPage = () => {
  const [isLogin, setIsLogin] = useState(true);
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [captchaToken, setCaptchaToken] = useState('');
  const navigate = useNavigate();
  const recaptchaRef = useRef();

  const handleCaptchaChange = (token) => {
    setCaptchaToken(token);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    // Validate captcha for both login AND registration
    if (!captchaToken) {
      setError('Please complete the captcha verification');
      setLoading(false);
      return;
    }

    try {
      if (isLogin) {
        console.log('Attempting login...');
        const response = await axiosInstance.post('/api/token/', {
          username,
          password,
          captcha_token: captchaToken
        });
        
        console.log('Login response:', response.data);
        
        if (response.data.access) {
          localStorage.setItem('accessToken', response.data.access);
          localStorage.setItem('refreshToken', response.data.refresh);
          navigate('/chat');
        }
      } else {
        console.log('Attempting registration...');
        // Registration with captcha
        const response = await axiosInstance.post('/api/auth/register/', {
          username,
          email,
          password,
          captcha_token: captchaToken
        });
        
        console.log('Registration successful:', response.data);
        setIsLogin(true);
        setError('Registration successful! Please check your email and then login.');
        
        // Reset form
        setUsername('');
        setEmail('');
        setPassword('');
      }
    } catch (err) {
      console.error('Auth error:', err);
      
      if (err.message === 'Request timeout. Please try again.') {
        setError('Server is taking too long to respond. Please try again.');
      } else if (err.response?.data?.detail) {
        setError(err.response.data.detail);
      } else if (err.response?.data?.error) {
        setError(err.response.data.error);
      } else if (err.code === 'ERR_NETWORK') {
        setError('Cannot connect to server. Please check if the backend is running.');
      } else {
        setError(isLogin ? 'Login failed. Please try again.' : 'Registration failed. Please try again.');
      }
      
      // Reset captcha on error
      if (recaptchaRef.current) {
        recaptchaRef.current.reset();
        setCaptchaToken('');
      }
    } finally {
      setLoading(false);
    }
  };

  const toggleAuthMode = () => {
    setIsLogin(!isLogin);
    setError('');
    setUsername('');
    setEmail('');
    setPassword('');
    setCaptchaToken('');
    
    // Reset captcha when switching modes
    if (recaptchaRef.current) {
      recaptchaRef.current.reset();
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-form-container">
        <h2>{isLogin ? 'Login' : 'Create Account'}</h2>
        
        {error && <div className="auth-error">{error}</div>}
        
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Username:</label>
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
              disabled={loading}
              minLength={3}
              maxLength={20}
            />
          </div>
          
          {!isLogin && (
            <div className="form-group">
              <label>Email:</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                disabled={loading}
              />
            </div>
          )}
          
          <div className="form-group">
            <label>Password:</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              disabled={loading}
              minLength={8}
            />
          </div>
          
          {/* Show captcha for BOTH login and registration */}
          <div className="form-group captcha-group">
            <ReCAPTCHA
              ref={recaptchaRef}
              sitekey="6LdMSUgrAAAAAFKCwbzfd18UmzlY7aez137XtsJh" // Test key
              onChange={handleCaptchaChange}
              onExpired={() => setCaptchaToken('')}
            />
          </div>
          
          <button type="submit" className="auth-button" disabled={loading || !captchaToken}>
            {loading ? 'Please wait...' : (isLogin ? 'Login' : 'Create Account')}
          </button>
        </form>
        
        <div className="auth-switch">
          {isLogin ? "Don't have an account?" : "Already have an account?"}
          <button
            type="button"
            className="switch-button"
            onClick={toggleAuthMode}
            disabled={loading}
          >
            {isLogin ? 'Sign Up' : 'Login'}
          </button>
        </div>
      </div>
    </div>
  );
};

export default AuthPage;
