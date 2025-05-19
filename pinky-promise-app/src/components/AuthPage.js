// src/components/AuthPage.js
import React, { useState } from 'react';
import axios from 'axios';
import { Container, Row, Col, Form, Button } from 'react-bootstrap';

const AuthPage = () => {
    // State to toggle between login and signup
    const [isLogin, setIsLogin] = useState(true);
    
    // Form data states
    const [username, setUsername] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [error, setError] = useState('');

    // Handle form submission
    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        
        try {
            if (isLogin) {
                // Handle login
                const response = await axios.post('/api/auth/login/', {
                    username,
                    password
                });
                
                // Store token in localStorage
                localStorage.setItem('token', response.data.token);
                localStorage.setItem('user', JSON.stringify(response.data.user));
                
                // Redirect or update state
                window.location.href = '/';
            } else {
                // Handle signup
                if (password !== confirmPassword) {
                    setError('Passwords do not match');
                    return;
                }
                
                await axios.post('/api/auth/register/', {
                    username,
                    email,
                    password,
                    password2: confirmPassword
                });
                
                // Switch to login after successful registration
                setIsLogin(true);
                setError('Registration successful! Please login.');
            }
        } catch (err) {
            setError(err.response?.data?.error || 'Something went wrong');
        }
    };

    return (
        <Container className="mt-5">
            <Row className="justify-content-center">
                <Col md={6} className="auth-form-container">
                    <h2 className="text-center mb-4">{isLogin ? 'Login' : 'Sign Up'}</h2>
                    
                    {error && <div className="alert alert-danger">{error}</div>}
                    
                    <Form onSubmit={handleSubmit}>
                        {/* Username field */}
                        <Form.Group className="mb-3">
                            <Form.Label>Username</Form.Label>
                            <Form.Control 
                                type="text" 
                                placeholder="Enter username" 
                                value={username}
                                onChange={(e) => setUsername(e.target.value)}
                                required
                            />
                        </Form.Group>
                        
                        {/* Email field - only shown for signup */}
                        {!isLogin && (
                            <Form.Group className="mb-3">
                                <Form.Label>Email</Form.Label>
                                <Form.Control 
                                    type="email" 
                                    placeholder="Enter email" 
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    required
                                />
                            </Form.Group>
                        )}
                        
                        {/* Password field */}
                        <Form.Group className="mb-3">
                            <Form.Label>Password</Form.Label>
                            <Form.Control 
                                type="password" 
                                placeholder="Password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                required
                            />
                        </Form.Group>
                        
                        {/* Confirm Password - only shown for signup */}
                        {!isLogin && (
                            <Form.Group className="mb-3">
                                <Form.Label>Confirm Password</Form.Label>
                                <Form.Control 
                                    type="password" 
                                    placeholder="Confirm password"
                                    value={confirmPassword}
                                    onChange={(e) => setConfirmPassword(e.target.value)}
                                    required
                                />
                            </Form.Group>
                        )}
                        
                        {/* Submit Button */}
                        <Button variant="primary" type="submit" className="w-100">
                            {isLogin ? 'Login' : 'Sign Up'}
                        </Button>
                    </Form>
                    
                    {/* Toggle between login and signup */}
                    <div className="text-center mt-3">
                        {isLogin ? (
                            <p>Don't have an account? <span 
                                className="text-primary" 
                                style={{ cursor: 'pointer' }}
                                onClick={() => setIsLogin(false)}
                            >
                                Sign Up
                            </span></p>
                        ) : (
                            <p>Already have an account? <span 
                                className="text-primary" 
                                style={{ cursor: 'pointer' }}
                                onClick={() => setIsLogin(true)}
                            >
                                Login
                            </span></p>
                        )}
                    </div>
                </Col>
            </Row>
        </Container>
    );
};

export default AuthPage;
