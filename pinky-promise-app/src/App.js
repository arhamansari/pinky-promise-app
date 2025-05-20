// Step 4: Update App.js routing
import React from 'react';
import './App.css';
import 'bootstrap/dist/css/bootstrap.min.css';
import NavigationBar from './components/NavigationBar';
import Hero from './components/Hero';
import Testimonials from './components/Testimonials';
import ExpertSection from './components/ExpertSection';
import ContactCustmerSprt from './components/ContactCustmerSprt';
import DoctorConsult from './components/DoctorConsult';
import AuthPage from './components/AuthPage';
import ChatPage from './components/ChatPage';
import UnauthorizedPage from './components/UnauthorizedPage';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import ProtectedRoute from './components/ProtectedRoute';

function App() {
  return (
    <Router>
      <NavigationBar />
      <Routes>
        <Route path="/" element={<Hero />} />
        <Route path="/auth" element={<AuthPage />} />
        <Route path="/consult" element={<DoctorConsult />} />
        
        {/* Protected Routes */}
        <Route element={<ProtectedRoute />}>
          <Route path="/chat" element={<ChatPage />} />
        </Route>

        <Route path="/unauthorized" element={<UnauthorizedPage />} />
        
        {/* Existing routes */}
        <Route path="/testimonials" element={<Testimonials />} />
        <Route path="/experts" element={<ExpertSection />} />
        <Route path="/contact" element={<ContactCustmerSprt />} />
      </Routes>
    </Router>
  );
}

export default App;
