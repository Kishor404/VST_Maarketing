import React, { useState, useEffect } from 'react';
import '../styles/customer.css';
import { FaUsers } from "react-icons/fa";
import axios from 'axios';
import Cookies from 'js-cookie';

const Customer = () => {
    const [cid, setCid] = useState("");
    const [fetchData, setFetchData] = useState(null);
    const [customerList, setCustomerList] = useState([]);
    const refreshToken = Cookies.get('refresh_token');
    const headRegion = Cookies.get('region');

    // Refresh Token Function
    const refresh_token = async () => {
        try {
            const res = await axios.post("http://127.0.0.1:8000/log/token/refresh/", { 'refresh': refreshToken }, { headers: { "Content-Type": "application/json" } });
            Cookies.set('refresh_token', res.data.refresh, { expires: 7 });
            return res.data.access;
        } catch (error) {
            console.error("Error refreshing token:", error);
            return null;
        }
    };

    // Fetch Single Customer by ID
    const fetch_user = async (cid, accessToken) => {
        try {
            const response = await axios.get(`http://127.0.0.1:8000/utils/getuserbyid/${cid}`, {
                headers: { Authorization: `Bearer ${accessToken}` }
            });
            if (response.data.region === headRegion) {
                setFetchData(response.data);
            }
        } catch (error) {
            console.error("Error fetching customer:", error);
            setFetchData(null);
        }
    };

    const edit = async () => {
        if (cid.trim() === "") {
            alert("Enter Customer ID");
            return;
        }
        const accessToken = await refresh_token();
        if (accessToken) await fetch_user(cid, accessToken);
    };

    // Fetch All Customers
    useEffect(() => {
        const getAllCustomers = async () => {
            const accessToken = await refresh_token();
            if (!accessToken) return;
            try {
                const response = await axios.post("http://127.0.0.1:8000/utils/getalluser/", { role: 'customer', region: headRegion }, { headers: { Authorization: `Bearer ${accessToken}` } });
                setCustomerList(response.data);
            } catch (error) {
                console.error("Error fetching customers:", error);
            }
        };
        getAllCustomers();
    }, []);

    const updateCustomer = async () => {
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
            .post("http://127.0.0.1:8000/utils/edituserxxx/", updatedData, {
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${AT}`,
                },
            })
            .then((response) => {
                alert("Customer updated successfully!");
                console.log(response.data);
            })
            .catch((error) => {
                console.error("Error updating customer:", error);
                alert("Failed to update customer");
            });
    };
    

    return (
        <div className="customer-cont">
            {/* CUSTOMER LEFT */}
            <div className='customer-left'>
                {/* CUSTOMER TOP */}
                <div className='customer-top'>
                    {/* CUSTOMER COUNT */}
                    <div className='customer-count-cont'>
                        <div className='customer-count-box'>
                            <p className="customer-count-value">{customerList.length}</p>
                            <p className="customer-count-title">Customers</p>
                        </div>
                        <FaUsers className="customer-count-icon" size={50} />
                    </div>

                    {/* EDIT CUSTOMER */}
                    <div className='customer-edit-cont'>
                        <div className='customer-edit-box'>
                            <input
                                placeholder='Enter Customer ID'
                                value={cid}
                                onChange={(e) => setCid(e.target.value)}
                                className='customer-edit-input'
                            />
                            <button className='customer-edit-button' onClick={edit}>Fetch</button>
                        </div>
                    </div>
                </div>

                {/* CUSTOMER LIST */}
                <div className="customer-list-cont">
                    <table className="customer-list">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Phone</th>
                            </tr>
                        </thead>
                        <tbody>
                            {customerList.map((customer) => (
                                <tr key={customer.id}>
                                    <td>{customer.id}</td>
                                    <td>{customer.name}</td>
                                    <td>{customer.phone}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* CUSTOMER RIGHT */}
            <div className='customer-right'>
                {/* CUSTOMER DETAILS */}
                <div className='customer-details-cont'>
                    <p className="customer-details-title">Customer Details</p>
                    <div className="customer-details-box-cont">
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
                    ) : <p>No Customer Selected</p>}

                    </div>
                    <button className='customer-details-but' onClick={updateCustomer}>Update</button>
                </div>
            </div>
        </div>
    );
};

// Component for displaying customer details
const DetailBox = ({ label, value, field, setFetchData }) => (
    <div className="customer-details-box">
        <p className="customer-details-key">{label}</p>
        <input
            className="customer-details-value"
            value={value || ""}
            onChange={(e) => setFetchData(prev => ({ ...prev, [field]: e.target.value }))}
        />
    </div>
);


export default Customer;
