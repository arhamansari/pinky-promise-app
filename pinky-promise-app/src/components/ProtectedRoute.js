// Step 2: Create ProtectedRoute component (src/components/ProtectedRoute.js)
import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';

const ProtectedRoute = () => {
  const isAuthenticated = localStorage.getItem('token');
  return isAuthenticated ? <Outlet /> : <Navigate to="/unauthorized" replace />;
};

export default ProtectedRoute;
