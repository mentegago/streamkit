import { NavLink } from "react-router-dom";

export default function MenuItem(props) {
    return (
        <li className="menu-item">
            <NavLink to={props.to} className={({ isActive }) => isActive ? "active" : ""}>
                <span className="icon">{props.icon}</span>
                <span className="label">{props.children}</span>
            </NavLink>
        </li>
    )
}