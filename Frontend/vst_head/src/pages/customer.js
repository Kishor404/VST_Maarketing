import React, { useState, useEffect } from 'react';
import '../styles/customer.css';
import { FaUsers } from "react-icons/fa";
import axios from 'axios';
import Cookies from 'js-cookie';

const Customer = () => {
    const [cid, setCid] = useState("");
    const [fetchData, setFetchData] = useState(null);
    const [customerList, setCustomerList] = useState([]);
    const [isCreating, setIsCreating] = useState(false);
    const [newCustomer, setNewCustomer] = useState({
        name: "",
        phone: "",
        email: "",
        address: "",
        city: "",
        district: "",
        postal_code: "",
        region: Cookies.get('region') || "",
        role: "customer",
        password: "",
        confirm_password: "",
    });

    const refreshToken = Cookies.get('refresh_token');
    const headRegion = Cookies.get('region');

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

    const fetch_user = async (cid, accessToken) => {
        try {
            const response = await axios.get(`http://157.173.220.208/utils/getuserbyid/${cid}`, {
                headers: { Authorization: `Bearer ${accessToken}` }
            });
            if (response.data.region === headRegion) {
                setFetchData(response.data);
                setIsCreating(false);
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

    useEffect(() => {
        const getAllCustomers = async () => {
            const accessToken = await refresh_token();
            if (!accessToken) return;
            try {
                const response = await axios.post("http://157.173.220.208/utils/getalluser/", { role: 'customer', region: headRegion }, { headers: { Authorization: `Bearer ${accessToken}` } });
                setCustomerList(response.data);
            } catch (error) {
                console.error("Error fetching customers:", error);
            }
        };
        getAllCustomers();
    }, []);

    const updateCustomer = async () => {
        const AT = await refresh_token();
        const updatedData = { ...fetchData };

        axios.post("http://157.173.220.208/utils/edituserxxx/", updatedData, {
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${AT}`,
            },
        }).then((response) => {
            alert("Customer updated successfully!");
        }).catch((error) => {
            console.error("Error updating customer:", error);
            alert("Failed to update customer");
        });
    };

    const createCustomer = async () => {
        // Check if any field is empty
        const isAnyFieldEmpty = Object.entries(newCustomer).some(([key, value]) => {
            return typeof value === 'string' && value.trim() === '';
        });
    
        if (isAnyFieldEmpty) {
            alert("Please fill in all fields before creating the customer.");
            return;
        }
    
        if (newCustomer.password !== newCustomer.confirm_password) {
            alert("Password and Confirm Password do not match.");
            return;
        }
    
        axios.post("http://157.173.220.208/log/signup/", newCustomer, {
            headers: {
                "Content-Type": "application/json",
            },
        }).then((response) => {
            alert("Customer created successfully!");
            setNewCustomer({
                name: "",
                phone: "",
                email: "",
                address: "",
                city: "",
                district: "",
                postal_code: "",
                region: headRegion,
                role: "customer",
                password: "",
                confirm_password: "",
            });
            setIsCreating(false);
        }).catch((error) => {
            console.error("Error creating customer:", error);
            alert("Failed to create customer");
        });
    };
    

    return (
        <div className="customer-cont">
            {/* CUSTOMER LEFT */}
            <div className='customer-left'>
                <div className='customer-top'>
                    <div className='customer-count-cont'>
                        <div className='customer-count-box'>
                            <p className="customer-count-value">{customerList.length}</p>
                            <p className="customer-count-title">Customers</p>
                        </div>
                        <FaUsers className="customer-count-icon" size={50} color='green' />
                    </div>

                    {/* FETCH + CREATE BUTTONS */}
                    <div className='customer-edit-cont'>
                        <div className='customer-edit-box'>
                            <input
                                placeholder='Enter Customer ID'
                                value={cid}
                                onChange={(e) => setCid(e.target.value)}
                                className='customer-edit-input'
                            />
                            <button className='customer-edit-button' onClick={edit}>Fetch</button>
                            <button className='customer-edit-button' onClick={() => {
                                setIsCreating(true);
                                setFetchData(null);
                            }}>Add</button>
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
                <div className='customer-details-cont'>
                    <p className="customer-details-title">
                        {isCreating ? "Add New Customer" : "Customer Details"}
                    </p>
                    <div className="customer-details-box-cont">
                        {isCreating ? (
                            <>
                                {Object.entries(newCustomer).map(([key, value]) => (
                                    <DetailBox
                                        key={key}
                                        label={key.replace("_", " ").charAt(0).toUpperCase() + key.replace("_", " ").slice(1)}
                                        value={value}
                                        field={key}
                                        setFetchData={(updater) => setNewCustomer(prev => ({ ...prev, [key]: updater(prev[key]) }))}
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
                            <p>No Customer Selected</p>
                        )}
                    </div>
                    {isCreating ? (
                        <button className='customer-details-but' onClick={createCustomer}>Add Customer</button>
                    ) : (
                        fetchData && <button className='customer-details-but' onClick={updateCustomer}>Update</button>
                    )}
                </div>
            </div>
        </div>
    );
};

// DetailBox Component (Handles both edit and create mode)
const DetailBox = ({ label, value, field, setFetchData }) => (
    <div className="customer-details-box">
        <p className="customer-details-key">{label}</p>
        <input
            className="customer-details-value"
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

export default Customer;
