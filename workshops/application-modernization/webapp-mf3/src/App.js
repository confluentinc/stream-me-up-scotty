import './App.css';
import axios from  'axios';
import React from 'react';
import { AppBar, Toolbar, Typography, Paper, TextField, Button,
         TableContainer, Table, TableHead, TableBody, TableRow, TableCell, TablePagination } from '@mui/material';

const transactionHeaders = [
    { id: 'transaction_id', label: 'Transaction\u00a0ID' },
    { id: 'card_number', label: 'Card\u00a0Number' },
    { id: 'transaction_amount', label: 'Transaction\u00a0Amount' }
];
const balanceHeaders = [
  { id: 'card_number', label: 'Card\u00a0Number' },
  { id: 'balance', label: 'Total\u00a0Balance' }
];


function App() {
    const [transactionCard, setTransactionCard] = React.useState('0000-1111-2222-3333');
    const [transactionAmount, setTransactionAmount] = React.useState(0);
    const [transactions, setTransactions] = React.useState([]);
    const [page, setPage] = React.useState(0);
    const [rowsPerPage, setRowsPerPage] = React.useState(5);
    const [balanceCard, setBalanceCard] = React.useState('0000-1111-2222-3333');
    const [balance, setBalance] = React.useState(0); 

    const handleChangeTransactionCard = (event) => {
        setTransactionCard(event.target.value);
    };
    const handleChangeTransactionAmount = (event) => {
        setTransactionAmount(event.target.value);
    };
    const handleTransactionSubmit = () => {
        axios.post('http://localhost:8001/transactions', {
            value: {
                card: transactionCard,
                amount: transactionAmount
            }
        }, { 
          "Content-Type": "application/json" 
        }).then((res) => {
            var temp = [...transactions];
            temp.push({
                transaction_id: res.data.values.id,
                card_number: res.data.values.card,
                transaction_amount: res.data.values.amount  
            });
            setTransactions(temp);
        }).catch((err) => { 
            console.error("Error", err);
        });
    };
    const handleChangePage = (newPage) => {
        setPage(newPage);
    };
    const handleChangeRowsPerPage = (event) => {
        setRowsPerPage(event.target.value);
        setPage(0);
    };
    const handleChangeBalanceCard = (event) => {
        setBalanceCard(event.target.value);
    }
    const handleBalanceRequest = () => {
        axios.post('http://localhost:8001/balance', {
            value: {
              card: balanceCard,
          }
        }, { 
          "Content-Type": "application/json" 
        }).then((res) => {
            setBalance(res.data.results[1].row.columns[1]);    
        }).catch((err) => { 
            console.error("Error", err);
        });
    };
    return (
        <div className="App">
            <div className="View">
                <div className="Navbar">
                    <AppBar position="static">
                        <Toolbar>
                            <Typography variant="h6" className="Navbar-Typography">Online Banking App</Typography>
                        </Toolbar>
                    </AppBar>
                </div>
                <div className="InteractiveView">
                    <Paper className="Transactions" elevation={3}>
                        <Typography variant="h5" gutterBottom component="div">Transactions</Typography>
                        <form className="Transactions-Form">
                            <TextField className="Transactions-Form-Card" required id="Transactions-Card" label="Card" placeholder="Please enter your card number." variant="outlined"
                                value={transactionCard}
                                onChange={handleChangeTransactionCard}
                            />
                            <TextField className="Transactions-Form-Amount" required id="Transactions-Amount" label="Amount" placeholder="Please enter an amount." variant="outlined"
                                value={transactionAmount}
                                onChange={handleChangeTransactionAmount}
                            />
                            <Button variant="contained" size="large" onClick={handleTransactionSubmit}>$$$</Button>
                        </form>
                        <TableContainer className="Transactions-Table">
                            <Table stickyHeader aria-label="sticky table">
                                <TableHead>
                                    <TableRow>
                                        {
                                            transactionHeaders.map((header) => (
                                                <TableCell key={header.id} align="left">
                                                    { header.label }
                                                </TableCell>
                                            ))
                                        }
                                    </TableRow>
                                </TableHead>
                                <TableBody>
                                    {
                                        transactions.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((row) => {
                                            return (
                                                <TableRow hover role="checkbox" tabIndex={-1} key={row.transaction_id}>
                                                    {
                                                        transactionHeaders.map((header) => {
                                                            const value = row[header.id];
                                                            return (
                                                                <TableCell key={header.id} align="left">
                                                                    { value }
                                                                </TableCell>
                                                            );
                                                        })
                                                    }
                                                </TableRow>
                                            );
                                        }) 
                                    }
                                </TableBody>
                            </Table>
                        </TableContainer>
                        <TablePagination
                            className="Transactions-Table-Pagination"
                            rowsPerPageOptions={[5, 15, 25]}
                            component="div"
                            count={transactions.length}
                            rowsPerPage={rowsPerPage}
                            page={page}
                            onPageChange={handleChangePage}
                            onRowsPerPageChange={handleChangeRowsPerPage}
                        />
                    </Paper>
                    <Paper className="Balances">
                        <Typography variant="h5" gutterBottom component="div">Balances</Typography>
                        <form className="Balances-Form">
                            <TextField className="Balances-Form-Card" required id="Balances-Card" label="Card" placeholder="Please enter your card number." variant="outlined"
                                value={balanceCard}
                                onChange={handleChangeBalanceCard}
                            />
                            <Button variant="contained" size="large" onClick={handleBalanceRequest}>???</Button>
                        </form>
                        <TableContainer className="Transactions-Table">
                            <Table stickyHeader aria-label="sticky table">
                                <TableHead>
                                    <TableRow>
                                        {
                                            balanceHeaders.map((header) => (
                                                <TableCell key={header.id} align="left">
                                                    { header.label }
                                                </TableCell>
                                            ))
                                        }
                                    </TableRow>
                                </TableHead>
                                <TableBody>
                                        <TableRow>
                                            <TableCell key="card" align="left">
                                                { balanceCard }
                                            </TableCell>
                                            <TableCell key="balance" align="left">
                                                { balance }
                                            </TableCell>
                                        </TableRow>
                                </TableBody>
                            </Table>
                        </TableContainer>
                    </Paper>
                </div> 
            </div>
        </div>
    );
}
export default App;
