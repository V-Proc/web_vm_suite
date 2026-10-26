import { createRoot } from "react-dom/client";
import "./styles/base.scss";
import { DashboardPage } from "../pages";

export const mount = (el: HTMLElement) => {
  createRoot(el).render(<DashboardPage />);
};
