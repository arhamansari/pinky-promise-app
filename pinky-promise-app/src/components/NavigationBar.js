// NavigationBar.js
import React from 'react';
import { Navbar, Nav, Container } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import logo1 from '../assets/care-her_v5.png';

function NavigationBar() {
    return (
        <Navbar bg="white" expand="lg" className="py-3">
            <Container>
                <Navbar.Brand as={Link} to="/">
                    <img src={logo1} alt="CareHer Logo" height="40" />
                </Navbar.Brand>
                <Navbar.Toggle aria-controls="basic-navbar-nav" />
                <Navbar.Collapse id="basic-navbar-nav">
                    <Nav className="ms-auto">
                        <Nav.Link as={Link} to="/">Home</Nav.Link>
                        <Nav.Link as={Link} to="/customer-stories">Customer Stories</Nav.Link>
                        <Nav.Link as={Link} to="/team">Team</Nav.Link>
                        <Nav.Link as={Link} to="/health-resources">Health Resources</Nav.Link>
                        <Nav.Link as={Link} to="/blog">Blog</Nav.Link>
                        <Nav.Link as={Link} to="/auth" className="btn btn-outline-primary">Login/Signup</Nav.Link>
                    </Nav>
                </Navbar.Collapse>
            </Container>
        </Navbar>
    );
}

export default NavigationBar;
