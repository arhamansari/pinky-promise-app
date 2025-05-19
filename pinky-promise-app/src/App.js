// App.js
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
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

function App() {
    return (
        <Router>
            <NavigationBar />
            <Routes>
                <Route path="/" element={
                    <>
                        <Hero />
                        <ExpertSection />
                        <Testimonials />
                        <ContactCustmerSprt />
                    </>
                } />
                <Route path="/consult" element={<DoctorConsult />} />
                <Route path="/auth" element={<AuthPage />} />
            </Routes>
        </Router>
    );
}

export default App;
