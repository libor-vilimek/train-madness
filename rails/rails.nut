const WAYPOINT_LENGTH = 20;
const WAYPOINT_LENGTH_DIAGONAL = 15;
const MAX_PATHFINDING_TIME = 1500;
const MAX_PATHFINDING_TIME_FINAL = 4500;

class Rails {

}

class Node {
	iteration = 0;
	x = -1;
	y = -1;
	tile = null;
	parentNode = null;

	constructor(x, y, parentNode = null) {
		this.x = x;
		this.y = y;
		this.tile = AIMap.GetTileIndex(x, y);
		this.parentNode = parentNode;
		this.iteration = 0;
	}
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
	local tile1x = AIMap.GetTileX(position1);
	local tile1y = AIMap.GetTileY(position1);
	local tile2x = AIMap.GetTileX(position2);
	local tile2y = AIMap.GetTileY(position2);

	local distance = abs(tile1x - tile2x) + abs(tile1y - tile2y);
	AILog.Info(distance);

	local paths = [];
	local root = Node(tile1x, tile1y);
	local target = Node(tile2x, tile2y);
	local fullPath = [root];
	local actual = root;
	local next = null;
	local lastRailTile = actual.tile + AIMap.GetTileIndex(-1, 0);
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
		if (AITile.GetDistanceManhattanToTile(actual.tile, target.tile) > 35) {
			local nextPos = Rails.NextNodePosition(actual, target).node;
			direction = Rails.NextNodePosition(actual, target).direction;
			AISign.BuildSign(nextPos.tile, "PossibleNode: " + fullPath.len());
			actual.iteration += 1;
			local possibilities = Rails.BuildableAround(nextPos.x, nextPos.y);
			if (possibilities.Count() == 0) {
				AILog.Info("No possibilities, skipping");
				continue;
			}
			possibility = possibilities.Begin();
		}

		local pathfinder = RailPathFinder();

		AISign.BuildSign(lastRailTile, "Last Rail Tile");
		AISign.BuildSign(actual.tile + AIMap.GetTileIndex(-1, 0), "Actual -1")
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
			local newNode = Node(AIMap.GetTileX(possibility) + Rails.DirectionToNode(direction).tile, AIMap.GetTileY(possibility), actual);
			AISign.BuildSign(newNode.tile, "Node: " + fullPath.len());
			fullPath.push(newNode);
			actual = newNode;
			Rails.BuildRail(path);
			if (possibility == target.tile) {
				Log.Debug("Finishing the route");
				break;
			}
		} else {
			AILog.Info("Path not found");
		}
	}
}

function Rails::NextNodePosition(from, to) {
	local coreDirection = Rails.MainDirection(from, to);
	AILog.Info("Core direction is: " + coreDirection);
	local nextDirection = null;
	local howmuch = (from.iteration / 2).tointeger();
	if (from.iteration % 2 == 0) {
		nextDirection = (coreDirection - howmuch + 8) % 8;
	} else {
		nextDirection = (coreDirection + howmuch + 1) % 8;
	}

	AILog.Info("Next direction is: " + nextDirection);
	local change = Rails.DirectionChange(nextDirection);
	return {
		node = Node(from.x + change.x, from.y + change.y),
		direction = nextDirection
	};
}

function Rails::MainDirection(from, to) {
	local xDiffers = abs(from.x - to.x);
	local yDiffers = abs(from.y - to.y);
	AILog.Info("xDiffers: " + xDiffers + " and yDiffers: " + yDiffers);

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

function Rails::BuildableAround(x, y, radius = 1) {
	local tile = AIMap.GetTileIndex(x, y);
	local list = AITileList();
	list.AddRectangle(tile + AIMap.GetTileIndex(radius, radius), tile - AIMap.GetTileIndex(radius, radius));
	list.Valuate(AITile.IsBuildable);
	list.KeepValue(1);
	foreach(buildableTile, value in list) {
		// AISign.BuildSign(buildableTile, "YES")
	}
	return list;
}