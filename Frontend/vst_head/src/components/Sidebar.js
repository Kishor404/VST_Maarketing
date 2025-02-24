import React from "react";
import { Link } from "react-router-dom";
import { FaUsers, FaIdBadge, FaEdit, FaInfo, FaAddressCard, FaPlus } from "react-icons/fa";
import '../styles/sidebar.css';
import Logo from '../assets/logo.jpg';

const Sidebar = () => {
return (
    <div className="sidebar">
        <div className="sidebar-main">
            <div className="sidebar-img-cont">
                <img src={Logo} alt="VST Maarketing" className="sidebar-img"/>
            </div>
            <div className="sidebar-button-cont">
                <Link to="/createcard" className="sidebar-button">
                    Create Card
                    <FaPlus className="sidebar-button-icon" size={12}/>
                </Link>
            </div>
            <div className="sidebar-list">
                <div className="sidebar-item">
                    <Link to="/customer" className="sidebar-link">
                        <FaUsers className="sidebar-item-icon" size={20}/>
                        Customers
                    </Link>
                </div>
                <div className="sidebar-item">
                    <Link to="/staff" className="sidebar-link">
                        <FaIdBadge className="sidebar-item-icon" size={20}/>
                        Staffs
                    </Link>
                </div>
                <div className="sidebar-item">
                    <Link to="/editreq" className="sidebar-link">
                        <FaEdit className="sidebar-item-icon" size={20}/>
                        Edit Requests
                    </Link>
                </div>
                <div className="sidebar-item">
                    <Link to="/unavareq" className="sidebar-link">
                        <FaInfo className="sidebar-item-icon" size={20}/>
                        Unavailable Requests
                    </Link>
                </div>
                <div className="sidebar-item">
                    <Link to="/customer" className="sidebar-link">
                        <FaAddressCard className="sidebar-item-icon" size={20}/>
                        Customer Card
                    </Link>
                </div>
            </div>
            <div className="sidebar-profile-cont">
                <div className="sidebar-profile">
                    <p className="sidebar-profile-name">Arun Kumar</p>
                    <p className="sidebar-profile-city">Rajapalayam</p>
                </div>
            </div>
        </div>
    </div>
);
};

export default Sidebar;
