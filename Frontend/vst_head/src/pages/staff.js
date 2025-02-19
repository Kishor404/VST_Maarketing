import React from 'react';
import '../styles/staff.css';
import { FaUsers } from "react-icons/fa";

const staff = () => {

    let staff_count=1000;
    let staff_list=[
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
        <div className="staff-cont">

            {/* staff TOP */}

            <div className='staff-top'>

                {/* staff COUNT */}
                <div className='staff-count-cont'>
                    <div className='staff-count-box'>
                        <p className="staff-count-value">{staff_count}</p>
                        <p className="staff-count-title">staffs</p>
                    </div>
                    <FaUsers className="staff-count-icon" size={50}/>
                </div>

                {/* EDIT staff */}
                <div className='staff-edit-cont'>
                    <div className='staff-edit-box'>
                        <input placeholder='Enter staff ID' className='staff-edit-input'/>
                        <button className='staff-edit-button'>Fetch</button>
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
                            <th>City</th>
                            <th>Address</th>
                            
                        </tr>
                    </thead>
                    <tbody>
                        {staff_list.map((staff)=>{
                            return(
                                <tr>
                                    <td>{staff.id}</td>
                                    <td>{staff.name}</td>
                                    <td>{staff.phone}</td>
                                    <td>{staff.city}</td>
                                    <td>{staff.address}</td>
                                </tr>
                            );
                        })}
                    </tbody>
                </table>
            </div>
        </div>
    );
}

export default staff;