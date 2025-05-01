import React, { useState, useEffect } from 'react';
import '../styles/staff.css';
import { FaUsers } from "react-icons/fa";
import axios from 'axios';
import Cookies from 'js-cookie';

const Staff = () => {
    const [cid, setCid] = useState("");
    const [fetchData, setFetchData] = useState(null);
    const [staffList, setstaffList] = useState([]);
    const [isCreating, setIsCreating] = useState(false);  // To toggle between view and create mode
    const [newStaff, setNewStaff] = useState({
        name: "",
        phone: "",
        email: "",
        address: "",
        city: "",
        district: "",
        postal_code: "",
        region: Cookies.get('region') || "",
        password: "",
        confirm_password: "",
        role: "worker",
    });

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

    // Fetch Single Staff by ID
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
        setIsCreating(false);
        const accessToken = await refresh_token();
        if (accessToken) await fetch_user(cid, accessToken);
    };

    // Fetch All Staffs
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
                alert("Staff updated successfully!");
                console.log(response.data);
            })
            .catch((error) => {
                console.error("Error updating staff:", error);
                alert("Failed to update staff");
            });
    };

    // Function to Create a New Staff
    const createStaff = async () => {
        // Validate that no fields are empty
        const isAnyFieldEmpty = Object.entries(newStaff).some(([key, value]) => value.trim() === '');
        if (isAnyFieldEmpty) {
            alert("Please fill in all fields before creating the staff.");
            return;
        }
    
        const AT = await refresh_token();
    
        axios.post("http://157.173.220.208/log/signup/", newStaff, {
            headers: {
                "Content-Type": "application/json",
            },
        })
        .then((response) => {
            alert("Staff created successfully!");
            setNewStaff({
                name: "",
                phone: "",
                email: "",
                address: "",
                city: "",
                district: "",
                postal_code: "",
                region: headRegion,
                role: "worker",
                password: "",
                confirm_password: "",
            });
            setIsCreating(false);  // Go back to "view" mode
            setCid("");  // Optionally clear the staff ID field
            // Optionally fetch updated staff list here
        })
        .catch((error) => {
            console.error("Error creating staff:", error);
            alert("Failed to create staff");
        });
    };
    

    return (
        <div className="staff-cont">
                    {/* staff LEFT */}
                    <div className='staff-left'>
                        <div className='staff-top'>
                            <div className='staff-count-cont'>
                                <div className='staff-count-box'>
                                    <p className="staff-count-value">{staffList.length}</p>
                                    <p className="staff-count-title">staffs</p>
                                </div>
                                <FaUsers className="staff-count-icon" size={50} color='green' />
                            </div>
        
                            {/* FETCH + CREATE BUTTONS */}
                            <div className='staff-edit-cont'>
                                <div className='staff-edit-box'>
                                    <input
                                        placeholder='Enter staff ID'
                                        value={cid}
                                        onChange={(e) => setCid(e.target.value)}
                                        className='staff-edit-input'
                                    />
                                    <button className='staff-edit-button' onClick={edit}>Fetch</button>
                                    <button className='staff-edit-button' onClick={() => {
                                        setIsCreating(true);  // Toggle to "create" mode
                                        setFetchData(null);  // Clear previous staff data
                                        setCid("");  // Optionally clear the staff ID field
                                    }}>
                                        Add
                                    </button>
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
                        <div className='staff-details-cont'>
                            <p className="staff-details-title">
                                {isCreating ? "Add New staff" : "staff Details"}
                            </p>
                            <div className="staff-details-box-cont">
                                {isCreating ? (
                                    <>
                                        {Object.entries(newStaff).map(([key, value]) => (
                                            <DetailBox
                                                key={key}
                                                label={key.replace("_", " ").charAt(0).toUpperCase() + key.replace("_", " ").slice(1)}
                                                value={value}
                                                field={key}
                                                setFetchData={(updater) => setNewStaff(prev => ({ ...prev, [key]: updater(prev[key]) }))}
                                            />
                                        ))}
                                    </>
                                ) : fetchData ? (
                                    <>
                                        <DetailBox label="Name" value={fetchData.name} field="name" setFetchData={setFetchData} />
                                        <DetailBox label="Phone" value={fetchData.phone} field="phone" setFetchData={setFetchData} />
                                        <DetailBox label="Email" value={fetchData.email} field="email" setFetchData={setFetchData} />
                                        <DetailBox label="Region" value={fetchData.region} field="region" setFetchData={setFetchData} />
                                        <DetailBox label="Address" value={fetchData.address} field="address" setFetchData={setFetchData} />
                                        <DetailBox label="City" value={fetchData.city} field="city" setFetchData={setFetchData} />
                                        <DetailBox label="District" value={fetchData.district} field="district" setFetchData={setFetchData} />
                                        <DetailBox label="Postal Code" value={fetchData.postal_code} field="postal_code" setFetchData={setFetchData} />
                                        <DetailBox label="Role" value={fetchData.role} field="role" setFetchData={setFetchData} />
                                    </>
                                ) : (
                                    <p>No staff Selected</p>
                                )}
                            </div>
                            {isCreating ? (
                                <button className='staff-details-but' onClick={createStaff}>Add staff</button>
                            ) : (
                                fetchData && <button className='staff-details-but' onClick={updatestaff}>Update</button>
                            )}
                        </div>
                    </div>
                </div>
            );
        };
        
        // DetailBox Component (Handles both edit and create mode)
        const DetailBox = ({ label, value, field, setFetchData }) => (
            <div className="staff-details-box">
                <p className="staff-details-key">{label}</p>
                <input
                    className="staff-details-value"
                    value={value || ""}
                    onChange={(e) =>
                        setFetchData(prevVal =>
                            typeof prevVal === 'object'
                                ? ({ ...prevVal, [field]: e.target.value })
                                : e.target.value
                        )
                    }
                />
            </div>
        );

export default Staff;
