class Rails {

}

/**
 * Build a rail line between two given points.
 * @param head1 The starting points of the rail line.
 * @param head2 The ending points of the rail line.
 * @return True if the construction succeeded.
 */
function Rails::BuildRail(head1, head2)
{
	local pathfinder = RailPathFinder();
	// Set some pathfinder penalties
	// pathfinder._cost_level_crossing = 900;
	pathfinder._cost_slope = 200;
	pathfinder._cost_coast = 100;
	pathfinder._cost_bridge_per_tile = 75;
	pathfinder._cost_tunnel_per_tile = 50;
	pathfinder._max_bridge_length = 20;
	pathfinder._max_tunnel_length = 20;
	pathfinder.InitializePath([head1], [head2]);
	AILog.Info("Pathfinding...");
	local counter = 0;
	local path = false;
	// Try to find a path
	while (path == false && counter < 150) {
		path = pathfinder.FindPath(150);
		counter++;
		AIController.Sleep(1);
	}
	if (path != null && path != false) {
		AILog.Info("Path found. (" + counter + ")");
	} else {
		AILog.Warning("Pathfinding failed.");
		return false;
	}
	local prev = null;
	local prevprev = null;
	local pp1, pp2, pp3 = null;
	while (path != null) {
		if (prevprev != null) {
			if (AIMap.DistanceManhattan(prev, path.GetTile()) > 1) {
				// If we are building a tunnel or a bridge
				if (AITunnel.GetOtherTunnelEnd(prev) == path.GetTile()) {
					// If we are building a tunnel
					if (!AITunnel.BuildTunnel(AIVehicle.VT_RAIL, prev)) {
						AILog.Info("An error occured while I was building the rail: " + AIError.GetLastErrorString());
						if (AIError.GetLastError() == AIError.ERR_NOT_ENOUGH_CASH) {
							AILog.Warning("That tunnel would be too expensive. Construction aborted.");
							return false;
						}
						// Try again if we have the money
						if (!cBuilder.RetryRail(prevprev, pp1, pp2, pp3, head1)) return false;
						else return true;
					}
				} else {
					// If we are building a bridge
					local bridgelist = AIBridgeList_Length(AIMap.DistanceManhattan(path.GetTile(), prev) + 1);
					bridgelist.Valuate(AIBridge.GetMaxSpeed);
					if (!AIBridge.BuildBridge(AIVehicle.VT_RAIL, bridgelist.Begin(), prev, path.GetTile())) {
						AILog.Info("An error occured while I was building the rail: " + AIError.GetLastErrorString());
						if (AIError.GetLastError() == AIError.ERR_NOT_ENOUGH_CASH) {
							AILog.Warning("That bridge would be too expensive. Construction aborted.");
							return false;
						}
						// Try again if we have the money
						if (!cBuilder.RetryRail(prevprev, pp1, pp2, pp3, head1)) return false;
						else return true;
					} else {
						// Register the new bridge
						root.railbridges.AddTile(path.GetTile());
					}
				}
				// Step these variables after a tunnel or bridge was built
				pp3 = pp2;
				pp2 = pp1;
				pp1 = prevprev;
				prevprev = prev;
				prev = path.GetTile();
				path = path.GetParent();
			} else {
				// If we are building a piece of rail track
				if (!AIRail.BuildRail(prevprev, prev, path.GetTile())) {
					AILog.Info("An error occured while I was building the rail: " + AIError.GetLastErrorString());
					if (!cBuilder.RetryRail(prevprev, pp1, pp2, pp3, head1)) return false;
					else return true;
				}
			}
		}
		// Step these variables at the start of the construction
		if (path != null) {
			pp3 = pp2;
			pp2 = pp1;
			pp1 = prevprev;
			prevprev = prev;
			prev = path.GetTile();
			path = path.GetParent();
		}
		// Check if we still have the money
		/*
		if (AICompany.GetBankBalance(AICompany.COMPANY_SELF) < (AICompany.GetLoanInterval() + Banker.GetMinimumCashNeeded())) {
			if (!Banker.GetMoney(AICompany.GetLoanInterval())) {
				AILog.Warning("I don't have enough money to complete the route.");
				return false;
			}
		}*/
	}
	return true;
}