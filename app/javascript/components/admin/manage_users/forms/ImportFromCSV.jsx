import React, { useState } from 'react';
import { Button, Table, Form } from 'react-bootstrap';
import Papa from 'papaparse';
import CsvSignUpForm from './CsvSignUpForm';

const CsvUploadAndDisplay = () => {
    const [csvData, setCsvData] = useState([]);
    const [error, setError] = useState(null);
    const handleFileUpload = (event) => {
        const file = event.target.files[0];
        if (file) {
            Papa.parse(file, {
                header: true,
                complete: (results) => {
                    if (results.errors.length) {
                        setError(results.errors[0].message);
                    } else {
                        setCsvData(results.data);
                        setError(null);
                    }
                },
                error: (error) => {
                    setError(error.message);
                },
            });
        }
    };

    return (
        <div className='d-flex flex-column  gap-4'>
            <Form.Group controlId="formFile" className="mb-3">
                <Form.Label>Upload CSV File</Form.Label>
                <Form.Control type="file" accept=".csv" onChange={handleFileUpload} />
            </Form.Group>
            {error && <div className="alert alert-danger">{error}</div>}
            {csvData.length > 0 && (
                <CsvSignUpForm
                    users={csvData.map((data) => ({
                        name: data.name,
                        email: data.email,
                        role: data.role,
                        password: "Fe99b949!" + generateRandomFiveDigitNumber(),
                        verified: data.verified.toLowerCase() === 'true',
                    }))}
                />
            )}
            {csvData.length > 0 && (
                <div className='w-full h-96 overflow-scroll'>
                    <Table striped bordered hover >
                        <thead>
                            <tr>
                                {Object.keys(csvData[0]).map((key) => (
                                    <th key={key}>{key}</th>
                                ))}
                            </tr>
                        </thead>
                        <tbody>
                            {csvData.map((row, index) => (
                                <tr key={index}>
                                    {Object.values(row).map((value, idx) => (
                                        <td key={idx}>{value}</td>
                                    ))}
                                </tr>
                            ))}
                        </tbody>
                    </Table>
                </div>
            )}

        </div>
    );
};

export default CsvUploadAndDisplay;

function generateRandomFiveDigitNumber() {
    const min = 10000;
    const max = 99999;
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

