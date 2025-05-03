import '../styles/essentials.css';
import { FaUsersGear } from "react-icons/fa6";
import { TiWarning } from "react-icons/ti";
import { FaUserCheck } from "react-icons/fa";
import { FaUserTag } from "react-icons/fa";
import { useState, useEffect } from 'react';
import axios from 'axios';
import Cookies from 'js-cookie';
import { Link } from 'react-router-dom';

const Essentials = () => {

    const refreshToken = Cookies.get('refresh_token');
    const [pendingCount, setPendingCount] = useState(0);
    const [dataList, setDataList] = useState([]);
    const [warrentyList, setWarrentyList] = useState([]);
    const [ACMList, setACMList] = useState([]);
    const [ContractList, setContractList] = useState([]);
    const [cards, setCards] = useState([]);

    // =========== REFRESH TOKEN ===========
    
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
        

    // =========== GET PENDING COUNT ===========

    const getPendingCount = async () => {
        const accessToken = await refresh_token();
        if (!accessToken) return;
        try {
            const response = await axios.get("http://157.173.220.208/utils/getservicebyhead/", { headers: { Authorization: `Bearer ${accessToken}` } });
            setPendingCount(response.data.filter((service) => service.status === "BD" && service.staff_name === "Waiting...").length);
        } catch (error) {
            console.error("Error fetching customers:", error);
        }
    };

    // =========== GET CARD DATA ===========

    const getAllCards = async () => {
        const accessToken = await refresh_token();
        if (!accessToken) return;
        try {
            const response = await axios.get("http://157.173.220.208/api/headcardlist/", { headers: { Authorization: `Bearer ${accessToken}` } });
            setCards(response.data);
            return response.data;
        } catch (error) {
            console.error("Error fetching customers:", error);
        }
    };

    // =========== GET & SET WARRENTY DATA ===========

    const getWarranty = async () => {
        const data = [];
        const today = new Date();
        const card=await getAllCards();
        for (let i = 0; i < card.length; i++) {
            const startDate = new Date(card[i].warranty_start_date);
            const endDate = new Date(card[i].warranty_end_date);
            if(startDate != null && endDate != null){
                if (startDate <= today && endDate >= today) {
                    card[i].end = card[i].warranty_end_date;
                    card[i].start = card[i].warranty_start_date;
                    data.push(card[i]);
                }
            }
        }
        setWarrentyList(data);
        return data
    };

    const setWarranty = async () => {
        const data=await getWarranty();
        setDataList(data)
    }

    // =========== GET & SET ACM DATA ===========

    const getACM = async () => {
        const data = [];
        const today = new Date();
        const card=await getAllCards();
        for (let i = 0; i < card.length; i++) {
            const startDate = new Date(card[i].acm_start_date);
            const endDate = new Date(card[i].acm_end_date);
            if(startDate != null && endDate != null){
                if (startDate <= today && endDate >= today) {
                    card[i].end = card[i].acm_end_date;
                    card[i].start = card[i].acm_start_date;
                    data.push(card[i]);
                }
            }
        }
        setACMList(data);
        return data
    };

    const setACM = async () => {
        const data=await getACM();
        setDataList(data)
    }

    // =========== GET & SET CONTRACT DATA ===========

    const getContract = async () => {
        const data = [];
        const today = new Date();
        const card=await getAllCards();
        for (let i = 0; i < card.length; i++) {
            const startDate = new Date(card[i].contract_start_date);
            const endDate = new Date(card[i].contract_end_date);
            if(startDate != null && endDate != null){
                if (startDate <= today && endDate >= today) {
                    card[i].end = card[i].contract_end_date;
                    card[i].start = card[i].contract_start_date;
                    data.push(card[i]);
                }
            }
        }
        setContractList(data);
        return data
    };

    const setContract = async () => {
        const data=await getContract();
        setDataList(data)
    }

    useEffect(() => {
        getPendingCount();
        getAllCards();
        getWarranty();
        getACM();
        getContract();
    }, []);

    return(<>
        <section className="es-body">
            <div className="es-top-cont">
                <div className="es-top-card-cont">
                    <Link className="es-top-card" to='/service'>
                        <div className="es-top-card-left">
                            <p className="es-top-card-value">{pendingCount}</p>
                            <p className="es-top-card-title">Action Required</p>
                        </div>
                        <TiWarning className="es-top-card-icon" size={50} color='red'/>
                    </Link>
                    <div className="es-top-card" onClick={setWarranty}>
                        <div className="es-top-card-left">
                            <p className="es-top-card-value">{warrentyList.length}</p>
                            <p className="es-top-card-title">Warrenty Customer</p>
                        </div>
                        <FaUserCheck className="es-top-card-icon" size={40} color='green'/>
                    </div>
                    <div className="es-top-card" onClick={setACM}>
                        <div className="es-top-card-left">
                            <p className="es-top-card-value">{ACMList.length}</p>
                            <p className="es-top-card-title">ACM Customer</p>
                        </div>
                        <FaUserTag className="es-top-card-icon" size={40} color='navy'/>
                    </div>
                    <div className="es-top-card" onClick={setContract}>
                        <div className="es-top-card-left">
                            <p className="es-top-card-value">{ContractList.length}</p>
                            <p className="es-top-card-title">On Contract</p>
                        </div>
                        <FaUsersGear className="es-top-card-icon" size={50} color='purple'/>
                    </div>
                </div>
            </div>
            <div className="es-main-cont">
                <div className="es-main-table-cont">
                    <table className="es-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Customer</th>
                                <th>Model</th>
                                <th>Start</th>
                                <th>End</th>
                            </tr>
                        </thead>
                        <tbody>
                            {dataList.map((data) => (
                                <tr key={data.id}>
                                    <td>{data.id}</td>
                                    <td>{data.customer_name + " ( " + data.customer_code +" )"}</td>
                                    <td>{data.model}</td>
                                    <td>{data.start}</td>
                                    <td>{data.end}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </>)

}
export default Essentials;