const WAYPOINT_LENGTH = 16;
const WAYPOINT_LENGTH_DIAGONAL = 12;
const MAX_PATHFINDING_TIME = 1500;
const MAX_PATHFINDING_TIME_FINAL = 4500;
const DIFF_TO_FINISH_ROUTE = 35;

class Rails {
	fromTile = null;
	toTile = null;
	buildPhase = RailBuildPhase.normal;

	constructor(fromTile, toTile) {
		this.fromTile = fromTile;
		this.toTile = toTile;
		buildPhase = RailBuildPhase.normal;
	}

	function BuildNext() {

	}
}

enum RailBuildPhase {
    normal
}

enum Direction {
	LEFT = 0,
		LEFT_TOP = 1,
		TOP = 2,
		TOP_RIGHT = 3,
		RIGHT = 4,
		RIGHT_DOWN = 5,
		DOWN = 6,
		DOWN_LEFT = 7
}


function Rails::DirectionToNode(direction) {
	if (direction == Direction.LEFT) {
		return Node(1, 0);
	}
	if (direction == Direction.LEFT_TOP) {
		return Node(1, -1);
	}
	if (direction == Direction.TOP) {
		return Node(0, -1);
	}
	if (direction == Direction.TOP_RIGHT) {
		return Node(-1, -1);
	}
	if (direction == Direction.RIGHT) {
		return Node(-1, 0);
	}
	if (direction == Direction.RIGHT_DOWN) {
		return Node(-1, 1);
	}
	if (direction == Direction.DOWN) {
		return Node(0, 1);
	}
	if (direction == Direction.DOWN_LEFT) {
		return Node(1, 1);
	}
}

function Rails::IsDirectionDiagonal(direction) {
	return direction % 2 == 1;
}

function Rails::IsDirectionHorizontal(direction) {
	return (direction == Direction.LEFT || direction == Direction.RIGHT);
}

function Rails::IsDirectionVertical(direction) {
	return (direction == Direction.TOP || direction == Direction.DOWN);
}

function Rails::DirectionChange(direction) {
	local node = Rails.DirectionToNode(direction);
	local multiply = WAYPOINT_LENGTH;
	if (Rails.IsDirectionDiagonal(direction)) {
		multiply = WAYPOINT_LENGTH_DIAGONAL;
	}
	return Node(node.x * multiply, node.y * multiply);
}

function Rails::RemoveRail(path) {
	local prev = null;
	local prevprev = null;
	while (path != null && path != false) {
		if (prevprev != null) {
			if (AIMap.DistanceManhattan(prev, path.GetTile()) > 1) {

			} else {
				AIRail.RemoveRail(prevprev, prev, path.GetTile());
			}
		}
		if (path != null) {
			prevprev = prev;
			prev = path.GetTile();
			path = path.GetParent();
		}
	}
}

function Rails::BuildRail(path) {
	local prev = null;
	local prevprev = null;

	while (path != null && path != false) {
		if (prevprev != null) {
			if (AIMap.DistanceManhattan(prev, path.GetTile()) > 1) {
				if (AITunnel.GetOtherTunnelEnd(prev) == path.GetTile()) {
					AITunnel.BuildTunnel(AIVehicle.VT_RAIL, prev);
				} else {
					local bridge_list = AIBridgeList_Length(AIMap.DistanceManhattan(path.GetTile(), prev) + 1);
					bridge_list.Valuate(AIBridge.GetMaxSpeed);
					bridge_list.Sort(AIList.SORT_BY_VALUE, false);
					AIBridge.BuildBridge(AIVehicle.VT_RAIL, bridge_list.Begin(), prev, path.GetTile());
				}
				prevprev = prev;
				prev = path.GetTile();
				path = path.GetParent();
			} else {
				AIRail.BuildRail(prevprev, prev, path.GetTile());
			}
		}
		if (path != null) {
			prevprev = prev;
			prev = path.GetTile();
			path = path.GetParent();
		}
	}
}

function Rails::PlanRail(position1, position2) {
	local paths = [];
	local root = Node.CreateFromTile(position1);
	local target = Node.CreateFromTile(position2);
	local fullPath = [root];
	local actual = root;
	local next = null;
	local lastRailTile = actual.tile + AIMap.GetTileIndex(-1, 0);
	local lastDirection = 0;
	AISign.BuildSign(root.tile, "ROOT");

	while (paths.len() < 100) {
		if (actual.iteration >= 8) {
			AILog.Info("Removing from the path");
			fullPath.pop();
			if (fullPath.len() == 0) {
				AILog.Info("Cancelling - path was not found")
				break;
			}
			local removePath = paths.pop();
			Rails.RemoveRail(removePath);

			actual = actual.parentNode;
			continue;
		}

		local possibility = target.tile;
		local direction = 0;
		if (AITile.GetDistanceManhattanToTile(actual.tile, target.tile) > DIFF_TO_FINISH_ROUTE) {
			Log.Debug("Rails::PlanRail From " + actual.ToString() + " to " + target.ToString() + " is close enough, finishing route");
			local newNodeAndDirection = Rails.NextNodePosition(actual, target, lastDirection)
			local nextPos = newNodeAndDirection.node;
			direction = newNodeAndDirection.direction;
			Log.CreateSign(nextPos.tile, "Node around: " + fullPath.len(), DEBUG_TYPE.BUILDING_STATION);

			possibility = Rails.BestTileToContinuePath(actual, nextPos, direction);
			Log.CreateSign(nextPos.tile, "Node specific: " + fullPath.len(), DEBUG_TYPE.BUILDING_STATION);
		}

		actual.iteration += 1;
		local pathfinder = RailPathFinder();
		pathfinder.InitializePath([
			[possibility, possibility + Rails.DirectionToNode(direction).tile]
		], [
			[actual.tile, lastRailTile]
		]);

		lastRailTile = possibility;

		AILog.Info("Pathfinding...");
		local findingTime = MAX_PATHFINDING_TIME;
		if (possibility == target.tile) {
			findingTime = MAX_PATHFINDING_TIME_FINAL;
		}

		local path = pathfinder.FindPath(findingTime);

		if (path != false && path != null) {
			AILog.Info("Found path");
			paths.push(path);
			AILog.Info("possibility: " + AIMap.GetTileX(possibility) + ":" + AIMap.GetTileY(possibility))
			local newNode = Node(AIMap.GetTileX(possibility) + Rails.DirectionToNode(direction).tile, AIMap.GetTileY(possibility), actual);
			Log.Debug("Node no. " + fullPath.len(), DEBUG_TYPE.BUILDING_RAIL);
			Log.Debug("Rails::PlanRail:Building from " + actual.ToString() + " to " + newNode.ToString(), DEBUG_TYPE.BUILDING_RAIL);
			Log.CreateSign(newNode.tile, "Node: " + fullPath.len(), DEBUG_TYPE.BUILDING_RAIL);
			Log.Debug(" ", DEBUG_TYPE.BUILDING_RAIL);
			fullPath.push(newNode);
			actual = newNode;
			Rails.BuildRail(path);
			lastDirection = direction;
			if (possibility == target.tile) {
				Log.Debug("Finishing the route");
				break;
			}
		} else {
			AILog.Info("Path not found");
		}
	}
}

function Rails::NextNodePosition(from, to, currentDirection) {
	Log.Debug("Rails::NextNodePosition: Going from " + from.x + ":" + from.y + " to " + to.x + ":" + to.y, DEBUG_TYPE.BUILDING_RAIL);
	local nextDirection = null;

	if (Rails.IsBeneficalToKeepDirection(from, to, currentDirection)) {
		nextDirection = currentDirection;
	} else {
		local coreDirection = Rails.MainDirection(from, to);
		Log.Info("Core direction is: " + coreDirection);
		local howmuch = (from.iteration / 2).tointeger();
		if (from.iteration % 2 == 0) {
			nextDirection = (coreDirection - howmuch + 8) % 8;
		} else {
			nextDirection = (coreDirection + howmuch + 1) % 8;
		}
	}

	Log.Info("Next direction is: " + nextDirection);
	local change = Rails.DirectionChange(nextDirection);
	return {
		node = Node(from.x + change.x, from.y + change.y),
		direction = nextDirection
	};
}

function Rails::IsBeneficalToKeepDirection(from, to, direction) {
	local xDiffers = abs(from.x - to.x);
	local yDiffers = abs(from.y - to.y);

	if (Rails.IsDirectionHorizontal(direction) && xDiffers < WAYPOINT_LENGTH) {
		Log.Debug("IsBeneficalToKeepDirection: The connection is horizontal, but xDiffers is not big enough: " + xDiffers);
		return false;
	}

	if (Rails.IsDirectionVertical(direction) && yDiffers < WAYPOINT_LENGTH) {
		Log.Debug("IsBeneficalToKeepDirection: The connection is vertical, but yDiffers is not big enough: " + yDiffers);
		return false;
	}

	local change = Rails.DirectionChange(direction);
	local xDiffers2 = abs(from.x - to.x + change.x);
	local yDiffers2 = abs(from.y - to.y + change.y);

	if ((xDiffers + yDiffers) - (xDiffers2 + yDiffers2) > WAYPOINT_LENGTH / 2) {
		Log.Debug("IsBeneficalToKeepDirection: true");
		return true;
	}

	Log.Debug("IsBeneficalToKeepDirection: " + ((xDiffers + yDiffers) - (xDiffers2 + yDiffers2)) + " < " + WAYPOINT_LENGTH / 2);
	return false;
}

function Rails::MainDirection(from, to) {
	local xDiffers = abs(from.x - to.x);
	local yDiffers = abs(from.y - to.y);
	Log.Debug("xDiffers: " + xDiffers + " and yDiffers: " + yDiffers);

	if (xDiffers > yDiffers) {
		if (from.x < to.x) {
			return Direction.LEFT;
		} else {
			return Direction.RIGHT;
		}
	} else {
		if (from.y < to.y) {
			return Direction.DOWN;
		} else {
			return Direction.TOP;
		}
	}
}

function Rails::GetBuildableTilesAroundNode(node, radius = 2) {
	local list = AITileList();
	list.AddRectangle(node.tile + AIMap.GetTileIndex(radius, radius), node.tile - AIMap.GetTileIndex(radius, radius));
	list.Valuate(AITile.IsBuildable);
	list.KeepValue(1);
	return list;
}

function Rails::BestTileToContinuePath(actualNode, targetNode, direction, radius = 2) {
	local tiles = Rails.GetBuildableTilesAroundNode(targetNode, radius);
	// If horizontal or vertical, try to keep X or Y the same
	// There is chance no obstacle is there and therefore straight line is built
	if (Rails.IsDirectionDiagonal(direction) == false) {
		Log.Debug("BestTileToContinuePath: Direction is not diagonal")
		if (Rails.IsDirectionHorizontal(direction)) {
			Log.Debug("BestTileToContinuePath: Direction is horizontal")
			tiles.Valuate(AIMap.GetTileY);
			Rails.ValuateEqualValueAsTrue(tiles, actualNode.y);
		} else {
			Log.Debug("BestTileToContinuePath: Direction is vertical")
			tiles.Valuate(AIMap.GetTileX);
			Rails.ValuateEqualValueAsTrue(tiles, actualNode.x);
		}

		// The nodes with same X or Y (based on direction) are valued 1, others are 0
		// By sorting them descending we first get those with same X or Y
		tiles.Sort(AIList.SORT_BY_VALUE, false);
	}

	foreach(tile, value in tiles) {
		local node = Node.CreateFromTile(tile);
		Log.CreateSign(tile, "" + tiles.GetValue(tile), DEBUG_TYPE.BUILDING_STATION);

		local directionNode = Rails.DirectionToNode(direction);
		local nextNodeInPath = Node(node.x + directionNode.x, node.y + directionNode.y);
		if (AITile.IsBuildable(nextNodeInPath.tile)) {
			return tile;
		}
	}
}

function Rails::ValuateEqualValueAsTrue(list, val) {
	Log.Debug("ValuateEqualValueAsTrue: Preffered value: " + val);
	local preferredValues = [];
	local otherValues = [];
	foreach(item, value in list) {
		if (list.GetValue(item) == val) {
			preferredValues.push(item);
		} else {
			otherValues.push(item);
		}
	}

	// AIList does not work when setting values while iterating it
	foreach(item in preferredValues) {
		list.SetValue(item, 1);
	}
	foreach(item in otherValues) {
		list.SetValue(item, 0);
	}
	Log.Debug("ValuateEqualValueAsTrue: Found " + preferredValues.len() + " preffered and " + otherValues.len() + " others ");
}