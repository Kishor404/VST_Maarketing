import React, { useState, useEffect } from "react";
import '../styles/Home.css';
import { FaUser } from "react-icons/fa";
import '../styles/fonts.css';
import Cookies from 'js-cookie';
import axios from 'axios';

const Home = () => {
  const [customerCount, setCustomerCount] = useState(0);
  const [staffCount, setStaffCount] = useState(0);
  const [userCount, setUserCount] = useState(0);
  const [headCount, setHeadCount] = useState(0);

  const refreshToken = async () => {
    try {
      const refreshToken = Cookies.get('refresh_token');

    //   console.log(refreshToken)
      
      const response = await axios.post('http://127.0.0.1:8000/log/token/refresh/', {
        "refresh": refreshToken,
      });
      
      const { access } = response.data;

      
      Cookies.set('access_token', access, { expires: 7 });
      
      return access;
    } catch (error) {
      console.error('Error refreshing token', error);
      throw new Error('Failed to refresh token');
    }
  };

  const GetCount = async () => {
    try {
      const accessToken = await refreshToken();
      
      const response = await axios.get('http://127.0.0.1:8000/utils/role-count/', {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
        },
      });
      
      const data = response.data;
      setCustomerCount(data.customer_count || 0);
      setStaffCount(data.staff_count || 0);
      setUserCount(data.user_count || 0);
      setHeadCount(data.head_count || 0);
      
    } catch (error) {
      console.error('Error fetching count data', error);
    }
  };

  useEffect(() => {
    GetCount();
  }, []);

  return (
    <div className="Home-main">
      <div className="Home-count-cards">
        <div className="Home-card">
          <div className="Home-card-L">
            <p className="Home-card-title">Customers</p>
            <p className="Home-card-value">{customerCount}</p>
          </div>
          <div className="Home-card-icon">
            <FaUser size={40} color="white" />
          </div>
        </div>
        <div className="Home-card">
          <div className="Home-card-L">
            <p className="Home-card-title">Users</p>
            <p className="Home-card-value">{userCount}</p>
          </div>
          <div className="Home-card-icon">
            <FaUser size={40} color="white" />
          </div>
        </div>
        <div className="Home-card">
          <div className="Home-card-L">
            <p className="Home-card-title">Staff</p>
            <p className="Home-card-value">{staffCount}</p>
          </div>
          <div className="Home-card-icon">
            <FaUser size={40} color="white" />
          </div>
        </div>
        <div className="Home-card">
          <div className="Home-card-L">
            <p className="Home-card-title">Head</p>
            <p className="Home-card-value">{headCount}</p>
          </div>
          <div className="Home-card-icon">
            <FaUser size={40} color="white" />
          </div>
        </div>
      </div>
    </div>
  );
};

export default Home;
