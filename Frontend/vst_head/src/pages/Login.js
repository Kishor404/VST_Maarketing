import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import '../styles/Login.css'
import Logo from '../assets/logo.jpg'
import '../styles/fonts.css'
import Cookies from 'js-cookie';

const Login = () => {
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const navigate = useNavigate();



  const handleSubmit = async (e) => {
    e.preventDefault();

    const response = await fetch("http://127.0.0.1:8000/log/login/", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ phone, password }),
    });

    const data = await response.json();
    console.log("Response:", data);
    if(data.login===1){
        if(data.data.role==='head'){
            Cookies.set('refresh_token', data.refresh_token, { expires: 7 });
            Cookies.set('region', data.data.region, { expires: 7 });
            alert("Login Sucessfull")
            navigate("/dashboard")
        }else{
            alert("Invaild Role !")
        }
    }else{
        alert(data.message)
    }
  };

  return (
    <div className="Login-main">
        <div className="Login-box">
            <img src={Logo} alt="Logo" width='70%'/>
            <p className="Login-heading">Head Login</p>
            <form onSubmit={handleSubmit} className="Login-form">
                <input
                    className="Login-input"
                    type="tel"
                    placeholder="phone"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    required
                />
                <input
                    className="Login-input"
                    type="password"
                    placeholder="Password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                />
                
                <button type="submit" className="Login-button">Login</button>
            </form>
        </div>
    </div>
  );
};

export default Login;
