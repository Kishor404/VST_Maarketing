import React, { useState, useEffect } from 'react';
import '../styles/staff.css';
import { FaUsers } from "react-icons/fa";
import axios from 'axios';
import Cookies from 'js-cookie';

const Staff = () => {
    const [cid, setCid] = useState("");
    const [fetchData, setFetchData] = useState(null);
    const [staffList, setstaffList] = useState([]);
    const refreshToken = Cookies.get('refresh_token');
    const headRegion = Cookies.get('region');

    // Refresh Token Function
    const refresh_token = async () => {
        try {
            const res = await axios.post("http://157.173.220.208/log/token/refresh/", { 'refresh': refreshToken }, { headers: { "Content-Type": "application/json" } });
            Cookies.set('refresh_token', res.data.refresh, { expires: 7 });
            return res.data.access;
        } catch (error) {
            console.error("Error refreshing token:", error);
            return null;
        }
    };

    // Fetch Single staff by ID
    const fetch_user = async (cid, accessToken) => {
        try {
            const response = await axios.get(`http://157.173.220.208/utils/getstaffbyid/${cid}`, {
                headers: { Authorization: `Bearer ${accessToken}` }
            });
            if (response.data.region === headRegion) {
                setFetchData(response.data);
            }
        } catch (error) {
            console.error("Error fetching staff:", error);
            setFetchData(null);
        }
    };

    const edit = async () => {
        if (cid.trim() === "") {
            alert("Enter staff ID");
            return;
        }
        const accessToken = await refresh_token();
        if (accessToken) await fetch_user(cid, accessToken);
    };

    // Fetch All staffs
    useEffect(() => {
        const getAllstaffs = async () => {
            const accessToken = await refresh_token();
            if (!accessToken) return;
            try {
                const response = await axios.post("http://157.173.220.208/utils/getalluser/", { role: 'worker', region: headRegion }, { headers: { Authorization: `Bearer ${accessToken}` } });
                setstaffList(response.data);
            } catch (error) {
                console.error("Error fetching staffs:", error);
            }
        };
        getAllstaffs();
    }, []);

    const updatestaff = async () => {
        const AT = await refresh_token();
        
        const updatedData = {
            id: fetchData.id,
            name: fetchData.name,
            phone: fetchData.phone,
            email: fetchData.email,
            address: fetchData.address,
            city: fetchData.city,
            district: fetchData.district,
            postal_code: fetchData.postal_code,
            region: fetchData.region
        };
    
        axios
            .post("http://157.173.220.208/utils/edituserxxx/", updatedData, {
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${AT}`,
                },
            })
            .then((response) => {
                alert("staff updated successfully!");
                console.log(response.data);
            })
            .catch((error) => {
                console.error("Error updating staff:", error);
                alert("Failed to update staff");
            });
    };
    

    return (
        <div className="staff-cont">
            {/* staff LEFT */}
            <div className='staff-left'>
                {/* staff TOP */}
                <div className='staff-top'>
                    {/* staff COUNT */}
                    <div className='staff-count-cont'>
                        <div className='staff-count-box'>
                            <p className="staff-count-value">{staffList.length}</p>
                            <p className="staff-count-title">staffs</p>
                        </div>
                        <FaUsers className="staff-count-icon" size={50} color='green'/>
                    </div>

                    {/* EDIT staff */}
                    <div className='staff-edit-cont'>
                        <div className='staff-edit-box'>
                            <input
                                placeholder='Enter staff ID'
                                value={cid}
                                onChange={(e) => setCid(e.target.value)}
                                className='staff-edit-input'
                            />
                            <button className='staff-edit-button' onClick={edit}>Fetch</button>
                        </div>
                    </div>
                </div>

                {/* staff LIST */}
                <div className="staff-list-cont">
                    <table className="staff-list">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Phone</th>
                            </tr>
                        </thead>
                        <tbody>
                            {staffList.map((staff) => (
                                <tr key={staff.id}>
                                    <td>{staff.id}</td>
                                    <td>{staff.name}</td>
                                    <td>{staff.phone}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* staff RIGHT */}
            <div className='staff-right'>
                {/* staff DETAILS */}
                <div className='staff-details-cont'>
                    <p className="staff-details-title">staff Details</p>
                    <div className="staff-details-box-cont">
                    {fetchData ? (
                        <>
                            <DetailBox label="Name" value={fetchData.name} field="name" setFetchData={setFetchData} />
                            <DetailBox label="Phone" value={fetchData.phone} field="phone" setFetchData={setFetchData} />
                            <DetailBox label="Email" value={fetchData.email} field="email" setFetchData={setFetchData} />
                            <DetailBox label="Region" value={fetchData.region} field="region" setFetchData={setFetchData} />
                            <DetailBox label="Address" value={fetchData.address} field="address" setFetchData={setFetchData} />
                            <DetailBox label="City" value={fetchData.city} field="city" setFetchData={setFetchData} />
                            <DetailBox label="District" value={fetchData.district} field="district" setFetchData={setFetchData} />
                            <DetailBox label="Postal Code" value={fetchData.postal_code} field="postal_code" setFetchData={setFetchData} />
                        </>
                    ) : <p>No staff Selected</p>}

                    </div>
                    <button className='staff-details-but' onClick={updatestaff}>Update</button>
                </div>
            </div>
        </div>
    );
};

// Component for displaying staff details
const DetailBox = ({ label, value, field, setFetchData }) => (
    <div className="staff-details-box">
        <p className="staff-details-key">{label}</p>
        <input
            className="staff-details-value"
            value={value || ""}
            onChange={(e) => setFetchData(prev => ({ ...prev, [field]: e.target.value }))}
        />
    </div>
);


export default Staff;
