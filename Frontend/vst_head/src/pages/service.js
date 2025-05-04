import '../styles/service.css';
import { MdVerified } from "react-icons/md";
import { MdUpcoming } from "react-icons/md";
import { TiWarning } from "react-icons/ti";
import { PiStackSimpleFill } from "react-icons/pi";
import { MdAddToPhotos } from "react-icons/md";
import { RiEdit2Fill } from "react-icons/ri";
import { useState, useEffect } from 'react';
import axios from 'axios';
import Cookies from 'js-cookie';


const Service = () => {

    const [serviceList, setServiceList] = useState([]);
    const [editService, setEditService] = useState(true);

    const [fetchService, setfetchService] = useState(false);
    const [fetchServiceId, setfetchServiceId] = useState("");
    const [fetchServiceStaffId, setfetchServiceStaffId] = useState("");
    const [fetchServiceCardId, setfetchServiceCardId] = useState("");
    const [fetchServiceAvaDate, setfetchServiceAvaDate] = useState("");
    const [fetchServiceComplaint, setfetchServiceComplaint] = useState("");
    const [fetchServiceStatus, setfetchServiceStatus] = useState("");
    const [fetchServiceAvailableFrom, setfetchServiceAvailableFrom] = useState("");
    const [fetchServiceAvailableTo, setfetchServiceAvailableTo] = useState("");

    const [createServiceCustomerId, setcreateServiceCustomerId] = useState("");
    const [createServiceStaffId, setcreateServiceStaffId] = useState("");
    const [createServiceCardId, setcreateServiceCardId] = useState("");
    const [createServiceAvaDate, setcreateServiceAvaDate] = useState("");
    const [createServiceComplaint, setcreateServiceComplaint] = useState("");
    const [createServiceComplaintDescription, setcreateServiceComplaintDescription] = useState("");

    const [boxData, setBoxData] = useState({"upcoming": 0, "pending": 0, "completed": 0, "total": 0});
    const refreshToken = Cookies.get('refresh_token');

    // ========== REFRESH TOKEN ==========
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
    
    // ========== FETCH SERVICE ==========

    const fetchServicebyid = async (sid) => {
        const accessToken = await refresh_token();
        if (!accessToken) return;
        try {
            const response = await axios.get("http://157.173.220.208/utils/getservicebyidbyhead/"+sid, { headers: { Authorization: `Bearer ${accessToken}` } });
            setfetchService(true);
            setfetchServiceId(response.data.id);
            setfetchServiceStaffId(response.data.staff);
            setfetchServiceCardId(response.data.card);
            setfetchServiceAvaDate(response.data.available_date);
            setfetchServiceComplaint(response.data.complaint);
            setfetchServiceStatus(response.data.status);
            setfetchServiceAvailableFrom(response.data.available.from);
            setfetchServiceAvailableTo(response.data.available.to);

        } catch (error) {
            console.error("Error fetching customers:", error);
        }
    };

    // ========== PATCH SERVICE ==========

    const patchService = async (sid) => {
        const accessToken = await refresh_token();
        if (!accessToken) return;
        const reqBody ={
            "staff": fetchServiceStaffId,
            "card": fetchServiceCardId,
            "available_date": fetchServiceAvaDate,
            "complaint": fetchServiceComplaint,
            "status": fetchServiceStatus
        }
        try {
            const response = await axios.patch("http://157.173.220.208/utils/patchservicebyidbyhead/"+sid, reqBody, { headers: { Authorization: `Bearer ${accessToken}` } });
            console.log(response.data);
            getAllServiceList();
            alert("Service updated successfully!");
        } catch (error) {
            console.error("Error fetching customers:", error);
            alert("Error Editing Service, Please check the values and try again.");
        }
    };

    // ========== CREATE SERVICE ==========

    const createService = async () => {
        const accessToken = await refresh_token();
        if (!accessToken) return;
        const reqBody ={
            "customer": createServiceCustomerId,
            "staff": createServiceStaffId,
            "card": createServiceCardId,
            "available_date": createServiceAvaDate,
            "available":{"from": createServiceAvaDate, "to": createServiceAvaDate},
            "complaint": createServiceComplaint,
            "description": createServiceComplaintDescription,
            "status": "BD",
        }
        try {
            const response = await axios.post("http://157.173.220.208/services/", reqBody, { headers: { Authorization: `Bearer ${accessToken}` } });
            console.log(response.data);
            getAllServiceList();
            alert("Service Created successfully!");
        } catch (error) {
            console.error("Error fetching customers:", error);
            alert("Error Creating Service, Please check the values and try again.");
        }
    };

    // ========== GET SERVICE LIST ==========

    const getAllServiceList = async () => {
        const accessToken = await refresh_token();
        if (!accessToken) return;
        try {
            const response = await axios.get("http://157.173.220.208/utils/getservicebyhead/", { headers: { Authorization: `Bearer ${accessToken}` } });
            setServiceList(response.data);
            const sPen=response.data.filter((service) => service.status === "BD" && service.staff_name === "Waiting...").length;
            const sCom=response.data.filter((service) => service.status === "SD").length;
            const sUp=response.data.filter((service) => service.status === "BD" && service.staff_name != "Waiting...").length;
            const sTot=response.data.length;
            console.log(sPen, sCom, sUp, sTot);
            setBoxData({"upcoming": sUp, "pending": sPen, "completed": sCom, "total": sTot});
        } catch (error) {
            console.error("Error fetching customers:", error);
        }
    };
    const getPendingServiceList = async () => {
        const accessToken = await refresh_token();
        if (!accessToken) return;
        try {
            const response = await axios.get("http://157.173.220.208/utils/getservicebyhead/", { headers: { Authorization: `Bearer ${accessToken}` } });
            setServiceList(response.data.filter((service) => service.status === "BD" && service.staff_name === "Waiting..."));
        } catch (error) {
            console.error("Error fetching customers:", error);
        }
    };
    const getCompletedServiceList = async () => {
        const accessToken = await refresh_token();
        if (!accessToken) return;
        try {
            const response = await axios.get("http://157.173.220.208/utils/getservicebyhead/", { headers: { Authorization: `Bearer ${accessToken}` } });
            setServiceList(response.data.filter((service) => service.status === "SD"));
        } catch (error) {
            console.error("Error fetching customers:", error);
        }
    };
    const getUpcomingServiceList = async () => {
        const accessToken = await refresh_token();
        if (!accessToken) return;
        try {
            const response = await axios.get("http://157.173.220.208/utils/getservicebyhead/", { headers: { Authorization: `Bearer ${accessToken}` } });
            setServiceList(response.data.filter((service) => service.status === "BD" && service.staff_name != "Waiting..."));
        } catch (error) {
            console.error("Error fetching customers:", error);
        }
    };

    // =========== CONFRIMATION ON EDIT ===========

    const handleEditService = () => {
        if (fetchService){
            const confirmEdit = window.confirm("Are you sure you want to edit this service?");
            if (confirmEdit) {
                patchService(fetchServiceId);
            } else {
                alert("Service Edit Cancelled");
            }
        }else{
            alert("Please Fetch the Service ID First");
        }
    }

    // =========== CONFRIMATION ON CREATE ===========

    const handleCreateService = () => {
        const confirmEdit = window.confirm("Are you sure you want to create this service?");
        if (confirmEdit) {
            createService();
        } else {
            alert("Service Creation Cancelled");
        }
    }


    useEffect(() => {
        getAllServiceList();
        
    }, []);

    return(
        <>
        <div className='service-main'>
            <div className='service-top'>
                <div className='service-top-main'>
                    <button className='service-top-box' onClick={getUpcomingServiceList}>
                        <div className='service-top-box-cont'>
                            <p className='service-top-value'>{boxData.upcoming}</p>
                            <p className='service-top-title'>Upcoming Services</p>
                        </div>
                        <MdUpcoming className="service-top-box-icon" size={50} color='#e305a0'/>
                    </button>
                    <button className='service-top-box' onClick={getPendingServiceList}>
                        <div className='service-top-box-cont'>
                            <p className='service-top-value'>{boxData.pending}</p>
                            <p className='service-top-title'>Pending Services</p>
                        </div>
                        <TiWarning className="service-top-box-icon" size={50} color='red'/>
                    </button>
                    <button className='service-top-box' onClick={getCompletedServiceList}>
                        <div className='service-top-box-cont'>
                            <p className='service-top-value'>{boxData.completed}</p>
                            <p className='service-top-title'>Completed Services</p>
                        </div>
                        <MdVerified className="service-top-box-icon" size={50} color='green'/>
                    </button>
                    <button className='service-top-box' onClick={getAllServiceList}>
                        <div className='service-top-box-cont'>
                            <p className='service-top-value'>{boxData.total}</p>
                            <p className='service-top-title'>Total Services</p>
                        </div>
                        <PiStackSimpleFill className="service-top-box-icon" size={50} color='#ff7300'/>
                    </button>
                </div>
            </div>
            <div className='service-bottom'>
                <div className='service-bottom-main'>
                    <div className='service-bottom-left'>
                        <div className='service-bottom-table-cont'>
                            <table className="service-list">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Customer</th>
                                        <th>Staff</th>
                                        <th>Complaint</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {serviceList.map((service) => (
                                        <tr key={service.id}>
                                            <td>{service.id}</td>
                                            <td>{service.customer_data.name}</td>
                                            <td>{service.staff_name}</td>
                                            <td>{service.complaint}</td>
                                            <td>{service.status}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div className='service-bottom-right'>
                        <div className='service-bottom-right-cont'>
                            <div className='service-bottom-right-top'>
                                <div className='service-bottom-right-top-cont'>
                                    <p className='service-bottom-right-top-left'>{editService ? ("Edit Service"):("Create Service")}</p>
                                    <div className='service-bottom-right-top-right'>
                                        <button title='Create Service' onClick={()=>setEditService(false)} className={editService?'service-bottom-right-top-right-no-active':'service-bottom-right-top-right-active'}><MdAddToPhotos/></button>
                                        <button title='Edit Service' onClick={()=>setEditService(true)} className={editService?'service-bottom-right-top-right-active':'service-bottom-right-top-right-no-active'}><RiEdit2Fill/></button>
                                    </div>
                                </div>
                            </div>

                            <div className='service-bottom-right-bottom'>
                                {editService ? 
                                (
                                    <div className='service-bottom-right-bottom-edit-cont'>
                                        <div className='service-bottom-right-bottom-edit-fetch-box'>
                                            <form className='service-bottom-right-bottom-edit-fetch' onSubmit={(e)=>{e.preventDefault();fetchServicebyid(fetchServiceId);}}>
                                                <input type="text" placeholder='Enter Service ID' className='service-bottom-right-bottom-edit-input' value={fetchServiceId} onChange={(e)=>{setfetchServiceId(e.target.value)}} required/>
                                                <button className='service-bottom-right-bottom-edit-button' type='submit'>Fetch</button>
                                            </form>
                                        </div>
                                        <hr/>
                                        {fetchService ?
                                        (
                                        <div className='service-bottom-right-bottom-edit-info-box'>
                                            <div className='service-bottom-right-bottom-edit-info-cont'>
                                                <p className='service-bottom-right-bottom-edit-info-title'>Customer Available From</p>
                                                <p className='service-bottom-right-bottom-edit-info-input'>{fetchServiceAvailableFrom}</p>
                                            </div>
                                            <div className='service-bottom-right-bottom-edit-info-cont'>
                                                <p className='service-bottom-right-bottom-edit-info-title'>Customer Available To</p>
                                                <p className='service-bottom-right-bottom-edit-info-input'>{fetchServiceAvailableTo}</p>
                                            </div>
                                            <div className='service-bottom-right-bottom-edit-info-cont'>
                                                <p className='service-bottom-right-bottom-edit-info-title'>Staff ID</p>
                                                <input type="text" placeholder='Enter Staff ID' className='service-bottom-right-bottom-edit-info-input' value={fetchServiceStaffId} onChange={(e)=>{setfetchServiceStaffId(e.target.value)}}/>
                                            </div>
                                            <div className='service-bottom-right-bottom-edit-info-cont'>
                                                <p className='service-bottom-right-bottom-edit-info-title'>Card ID</p>
                                                <input type="text" placeholder='Enter Card ID' className='service-bottom-right-bottom-edit-info-input' value={fetchServiceCardId} onChange={(e)=>{setfetchServiceCardId(e.target.value)}}/>
                                            </div>
                                            
                                            <div className='service-bottom-right-bottom-edit-info-cont'>
                                                <p className='service-bottom-right-bottom-edit-info-title'>Available Date</p>
                                                <input type="date" placeholder='Enter Available' className='service-bottom-right-bottom-edit-info-input' value={fetchServiceAvaDate} onChange={(e)=>{setfetchServiceAvaDate(e.target.value)}}/>
                                            </div>
                                            <div className='service-bottom-right-bottom-edit-info-cont'>
                                                <p className='service-bottom-right-bottom-edit-info-title'>Complaint</p>
                                                <input type="text" placeholder='Enter Complaint' className='service-bottom-right-bottom-edit-info-input' value={fetchServiceComplaint} onChange={(e)=>{setfetchServiceComplaint(e.target.value)}}/>
                                            </div>
                                            <div className='service-bottom-right-bottom-edit-info-cont'>
                                                <p className='service-bottom-right-bottom-edit-info-title'>Status</p>
                                                <input type="text" placeholder='Enter Status' className='service-bottom-right-bottom-edit-info-input' value={fetchServiceStatus} onChange={(e)=>{setfetchServiceStatus(e.target.value)}}/>
                                            </div>
                                        </div>
                                        ):
                                        (
                                            <div className='service-bottom-right-bottom-edit-no-info-cont'>
                                                <p>Enter ID and Fetch the data</p>
                                            </div>
                                        )}
                                        <hr/>
                                        <div className='service-bottom-right-bottom-edit-button-cont'>
                                            <button className='service-bottom-right-bottom-edit-submit' onClick={()=>handleEditService()}>Edit Service</button>
                                        </div>
                                    </div>
                                ):
                                (
                                    <form className='service-bottom-right-bottom-create-cont' onSubmit={(e)=>{e.preventDefault();handleCreateService();}}>
                                        <div className='service-bottom-right-bottom-create-info-box'>
                                            <div className='service-bottom-right-bottom-create-info-cont'>
                                                <p className='service-bottom-right-bottom-create-info-title'>Customer ID</p>
                                                <input type="text" placeholder='Enter Customer ID' className='service-bottom-right-bottom-create-info-input' required value={createServiceCustomerId} onChange={(e)=>{setcreateServiceCustomerId(e.target.value)}}/>
                                            </div>
                                            <div className='service-bottom-right-bottom-create-info-cont'>
                                                <p className='service-bottom-right-bottom-create-info-title'>Staff ID</p>
                                                <input type="text" placeholder='Enter Staff ID' className='service-bottom-right-bottom-create-info-input' required value={createServiceStaffId} onChange={(e)=>{setcreateServiceStaffId(e.target.value)}}/>
                                            </div>
                                            <div className='service-bottom-right-bottom-create-info-cont'>
                                                <p className='service-bottom-right-bottom-create-info-title'>Card ID</p>
                                                <input type="text" placeholder='Enter Card ID' className='service-bottom-right-bottom-create-info-input' required value={createServiceCardId} onChange={(e)=>{setcreateServiceCardId(e.target.value)}}/>
                                            </div>
                                            <div className='service-bottom-right-bottom-create-info-cont'>
                                                <p className='service-bottom-right-bottom-create-info-title'>Appointed Date</p>
                                                <input type="date" className='service-bottom-right-bottom-create-info-input' required value={createServiceAvaDate} onChange={(e)=>{setcreateServiceAvaDate(e.target.value)}}/>
                                            </div>
                                            <div className='service-bottom-right-bottom-create-info-cont'>
                                                <p className='service-bottom-right-bottom-create-info-title'>Complaint</p>
                                                <input type="text" placeholder='Enter Complaint' className='service-bottom-right-bottom-create-info-input' required value={createServiceComplaint} onChange={(e)=>{setcreateServiceComplaint(e.target.value)}}/>
                                            </div>
                                            <div className='service-bottom-right-bottom-create-info-cont'>
                                                <p className='service-bottom-right-bottom-create-info-title'>Complaint Description</p>
                                                <input type="text" placeholder='Enter Complaint Description' className='service-bottom-right-bottom-create-info-input' value={createServiceComplaintDescription} onChange={(e)=>{setcreateServiceComplaintDescription(e.target.value)}}/>
                                            </div>
                                        </div>
                                        <hr/>
                                        <div className='service-bottom-right-bottom-edit-button-cont'>
                                            <button className='service-bottom-right-bottom-edit-submit' type='submit'>Create Service</button>
                                        </div>
                                    </form>
                                )}
                            </div>


                        </div>

                    </div>
                    

                </div>
            </div>
        </div>
        </>
    )
}
export default Service;