import React from "react";
import { BrowserRouter as Router, Routes, Route, useLocation } from "react-router-dom";
import Login from "./pages/Login";
import Home from "./pages/Home";
import Sidebar from "./components/Sidebar";

const Layout = ({ children }) => {
  const location = useLocation();
  const showSidebar = location.pathname !== "/"; // Hide sidebar on Login page

  return (
    <div className="app-container">
      {showSidebar && <Sidebar />}
      <div className="content">{children}</div>
    </div>
  );
};

const App = () => {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<Login />} />
          <Route path="/dashboard" element={<Home />} />
        </Routes>
      </Layout>
    </Router>
  );
};

export default App;
