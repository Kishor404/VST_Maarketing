import React, { useState, useEffect } from 'react';
import '../styles/showcard.css';
import { FaAddressCard } from "react-icons/fa";
import axios from 'axios';
import Cookies from 'js-cookie';

const ShowCard = () => {
    const [cid, setCid] = useState("");
    const [fetchData, setFetchData] = useState(null);
    const [showcardList, setshowcardList] = useState([]);
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
            const response = await axios.get(`http://127.0.0.1:8000/api/headcardgetid/${cid}/`, {
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
                const response = await axios.get("http://127.0.0.1:8000/api/headcardlist/", { headers: { Authorization: `Bearer ${accessToken}` } });
                setshowcardList(response.data);
            } catch (error) {
                console.error("Error fetching customers:", error);
            }
        };
        getAllCustomers();
    }, []);

    const updateshowcard = async () => {
        const AT = await refresh_token();
        
        const updatedData = {
            model: fetchData.model,
            customer_code: fetchData.customer_code,
            customer_name: fetchData.customer_name,
            region: fetchData.region,
            date_of_installation: fetchData.date_of_installation,
            warranty_start_date: fetchData.warranty_start_date,
            warranty_end_date: fetchData.warranty_end_date,
            acm_start_date: fetchData.acm_start_date,
            acm_end_date: fetchData.acm_end_date,
            contract_start_date: fetchData.contract_start_date,
            contract_end_date: fetchData.contract_end_date
        };

        if (fetchData.address.trim() !== "") updatedData.address = fetchData.address;
    
        axios
            .patch('http://127.0.0.1:8000/api/headeditcard/'+fetchData.id+'/', updatedData, {
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${AT}`,
                },
            })
            .then((response) => {
                alert("Customer updated successfully!");
                console.log(response.data);
                window.location.reload();
            })
            .catch((error) => {
                console.error("Error updating customer:", error);
                alert("Failed to update customer");
            });
    };
    

    return (
        <div className="showcard-cont">
            {/* showcard LEFT */}
            <div className='showcard-left'>
                {/* showcard TOP */}
                <div className='showcard-top'>
                    {/* showcard COUNT */}
                    <div className='showcard-count-cont'>
                        <div className='showcard-count-box'>
                            <p className="showcard-count-value">{showcardList.length}</p>
                            <p className="showcard-count-title">Total Cards</p>
                        </div>
                        <FaAddressCard className="showcard-count-icon" size={40} />
                    </div>

                    {/* EDIT showcard */}
                    <div className='showcard-edit-cont'>
                        <div className='showcard-edit-box'>
                            <input
                                placeholder='Enter showcard ID'
                                value={cid}
                                onChange={(e) => setCid(e.target.value)}
                                className='showcard-edit-input'
                            />
                            <button className='showcard-edit-button' onClick={edit}>Fetch</button>
                        </div>
                    </div>
                </div>

                {/* showcard LIST */}
                <div className="showcard-list-cont">
                    <table className="showcard-list">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Model</th>
                                <th>Customer Code</th>
                                <th>Customer Name</th>
                                <th>Date Of Installation</th>
                            </tr>
                        </thead>
                        <tbody>
                            {showcardList.map((showcard) => (
                                <tr key={showcard.id}>
                                    <td>{showcard.id}</td>
                                    <td>{showcard.model}</td>
                                    <td>{showcard.customer_code}</td>
                                    <td>{showcard.customer_name}</td>
                                    <td>{showcard.date_of_installation}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* showcard RIGHT */}
            <div className='showcard-right'>
                {/* showcard DETAILS */}
                <div className='showcard-details-cont'>
                    <p className="showcard-details-title">Card Details</p>
                    <div className="showcard-details-box-cont">
                    {fetchData ? (
                        <>
                            <DetailBox label="Model" value={fetchData.model} field="model" setFetchData={setFetchData} />
                            <DetailBox label="Customer Code" value={fetchData.customer_code} field="customer_code" setFetchData={setFetchData} />
                            <DetailBox label="Customer Name" value={fetchData.customer_name} field="customer_name" setFetchData={setFetchData} />
                            <DetailBox label="Region" value={fetchData.region} field="region" setFetchData={setFetchData} />
                            <DetailBox label="Date Of Installation" value={fetchData.date_of_installation} field="date_of_installation" setFetchData={setFetchData} />
                            <DetailBox label="Address" value={fetchData.address} field="address" setFetchData={setFetchData} />
                            <DetailBox label="Warranty Start Date" value={fetchData.warranty_start_date} field="warranty_start_date" setFetchData={setFetchData} />
                            <DetailBox label="Warranty End Date" value={fetchData.warranty_end_date} field="warranty_end_date" setFetchData={setFetchData} />
                            <DetailBox label="ACM Start Date" value={fetchData.acm_start_date} field="acm_start_date" setFetchData={setFetchData} />
                            <DetailBox label="ACM End Date" value={fetchData.acm_end_date} field="acm_end_date" setFetchData={setFetchData} />
                            <DetailBox label="Contract Start Date" value={fetchData.contract_start_date} field="contract_start_date" setFetchData={setFetchData} />
                            <DetailBox label="Contract End Date" value={fetchData.contract_end_date} field="contract_end_date" setFetchData={setFetchData} />
                        </>
                    ) : <p>No showcard Selected</p>}

                    </div>
                    <button className='showcard-details-but' onClick={updateshowcard}>Update</button>
                </div>
            </div>
        </div>
    );
};

// Component for displaying showcard details
const DetailBox = ({ label, value, field, setFetchData }) => (
    <div className="showcard-details-box">
        <p className="showcard-details-key">{label}</p>
        <input
            className="showcard-details-value"
            value={value || ""}
            onChange={(e) => setFetchData(prev => ({ ...prev, [field]: e.target.value }))}
        />
    </div>
);


export default ShowCard;
