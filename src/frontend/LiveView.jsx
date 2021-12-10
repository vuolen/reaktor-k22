import React from "react";
import { LiveGame } from "./LiveGame";

export const LiveView = ({liveGames}) => {
    return <div>
        {liveGames.map(game => (
            <LiveGame {...game} />
        ))}
    </div>
}
