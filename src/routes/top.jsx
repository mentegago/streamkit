import '../App.css';
import { Outlet } from 'react-router-dom';
import Sidebar from '../components/sidebar';

function App() {  
  return (
    <div className="App">
      <Sidebar />
      <div className="main">
        <div className="main-content">
          <Outlet />
        </div>
      </div>
    </div>
  );
}

export default App;
