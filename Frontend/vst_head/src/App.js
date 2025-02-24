import React from "react";
import { BrowserRouter as Router, Routes, Route, useLocation } from "react-router-dom";
import Login from "./pages/Login";
import Customer from "./pages/customer";
import Staff from "./pages/staff";
import EditReq from "./pages/editReq";
import UnavaReq from "./pages/unavaReq";
import CreateCard from "./pages/createcard";
import Sidebar from "./components/Sidebar";
import "./App.css";

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
          <Route path="/customer" element={<Customer />} />
          <Route path="/staff" element={<Staff />} />
          <Route path="/editreq" element={<EditReq />} />
          <Route path="/unavareq" element={<UnavaReq />} />
          <Route path="/createcard" element={<CreateCard />} />
        </Routes>
      </Layout>
    </Router>
  );
};

export default App;
