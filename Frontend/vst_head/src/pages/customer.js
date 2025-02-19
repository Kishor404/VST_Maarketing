import React from 'react';
import '../styles/customer.css';
import { FaUsers } from "react-icons/fa";

const Customer = () => {

    let customer_count=1000;
    let customer_list=[
        {
            "id":1001,
            "name":"Arun Kumar",
            "phone":"1234567890",
            "city":"Rajapalayam",
            "address":"Address"
        },
        {
            "id":1002,
            "name":"Arun Kumar",
            "phone":"1234567890",
            "city":"Rajapalayam",
            "address":"Address"
        },
        {
            "id":1003,
            "name":"Arun Kumar",
            "phone":"1234567890",
            "city":"Rajapalayam",
            "address":"Address"
        },
        {
            "id":1004,
            "name":"Arun Kumar",
            "phone":"1234567890",
            "city":"Rajapalayam",
            "address":"Address"
        },
        {
            "id":1005,
            "name":"Arun Kumar",
            "phone":"1234567890",
            "city":"Rajapalayam",
            "address":"Address"
        }
    ]

    const edit= (cid)=> {
        console.log("Edit", cid)
    }

    return (
        <div className="customer-cont">

            {/* CUSTOMER TOP */}

            <div className='customer-top'>

                {/* CUSTOMER COUNT */}
                <div className='customer-count-cont'>
                    <div className='customer-count-box'>
                        <p className="customer-count-value">{customer_count}</p>
                        <p className="customer-count-title">Customers</p>
                    </div>
                    <FaUsers className="customer-count-icon" size={50}/>
                </div>

                {/* EDIT CUSTOMER */}
                <div className='customer-edit-cont'>
                    <div className='customer-edit-box'>
                        <input placeholder='Enter Customer ID' className='customer-edit-input'/>
                        <button className='customer-edit-button'>Fetch</button>
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
                            <th>City</th>
                            <th>Address</th>
                            
                        </tr>
                    </thead>
                    <tbody>
                        {customer_list.map((customer)=>{
                            return(
                                <tr>
                                    <td>{customer.id}</td>
                                    <td>{customer.name}</td>
                                    <td>{customer.phone}</td>
                                    <td>{customer.city}</td>
                                    <td>{customer.address}</td>
                                </tr>
                            );
                        })}
                    </tbody>
                </table>
            </div>
        </div>
    );
}

export default Customer;