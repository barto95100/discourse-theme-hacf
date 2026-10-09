import { apiInitializer } from "discourse/lib/api";
import HacfOnlineHeader from "../components/hacf-online-header";

export default apiInitializer((api) => {
  api.headerButtons.add("hacf-online", HacfOnlineHeader, { before: "auth" });
});
