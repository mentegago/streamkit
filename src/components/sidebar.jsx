import { Link } from "react-router-dom";
import MenuItem from "./menuitem";

export default function Sidebar() {
    return (
        <div className="sidebar">
            <div className="sidebar-header">
                🧈
            </div>
            <ul>
                <MenuItem to="/" icon="🏡">Home</MenuItem>
                <MenuItem to="/chat" icon="🦜">Chat to Speech</MenuItem>
                {/* <MenuItem to="/obs" icon="🎬">Beat Saber to OBS</MenuItem> */}
                {/* <MenuItem to="/rick" icon="😏">Rick</MenuItem> */}
            </ul>
            <div className="sidebar-footer">
                <Link to="/rick" style={{
                    textDecoration: "none",
                    color: "white"
                }}>
                    Early Preview (0.0.1)<br />
                    👞😏👞🎙
                </Link>
            </div>
        </div>
    )
}