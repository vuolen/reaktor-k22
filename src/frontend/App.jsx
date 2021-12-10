import React from "react";
import { LiveView } from "./LiveView";

export const App = ({liveGames}) => {
    return <div>
        <LiveView liveGames={liveGames} />
    </div>
}
