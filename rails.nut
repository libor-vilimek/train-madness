const WAYPOINT_LENGTH = 20;
const WAYPOINT_LENGTH_DIAGONAL = 15;

class Rails {

}

class Node {
	iteration = 0;
	x = -1;
	y = -1;
	tile = null;

	constructor(x, y) {
		this.x = x;
		this.y = y;
		tile = AIMap.GetTileIndex(x, y);
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

function Rails::DirectionChange(direction) {
	if (direction == Direction.LEFT) {
		return Node(WAYPOINT_LENGTH, 0);
	}
	if (direction == Direction.LEFT_TOP) {
		return Node(WAYPOINT_LENGTH_DIAGONAL, -WAYPOINT_LENGTH_DIAGONAL);
	}
	if (direction == Direction.TOP) {
		return Node(0, -WAYPOINT_LENGTH);
	}
	if (direction == Direction.TOP_RIGHT) {
		return Node(-WAYPOINT_LENGTH_DIAGONAL, -WAYPOINT_LENGTH_DIAGONAL);
	}
	if (direction == Direction.RIGHT) {
		return Node(-WAYPOINT_LENGTH, 0);
	}
	if (direction == Direction.RIGHT_DOWN) {
		return Node(-WAYPOINT_LENGTH_DIAGONAL, WAYPOINT_LENGTH_DIAGONAL);
	}
	if (direction == Direction.DOWN) {
		return Node(0, WAYPOINT_LENGTH);
	}
	if (direction == Direction.DOWN_LEFT) {
		return Node(WAYPOINT_LENGTH_DIAGONAL, WAYPOINT_LENGTH_DIAGONAL);
	}
}

/**
 * Build a rail line between two given points.
 * @param head1 The starting points of the rail line.
 * @param head2 The ending points of the rail line.
 * @return True if the construction succeeded.
 */
function Rails::BuildRail(head1, head2) {
	local pathfinder = RailPathFinder();
	pathfinder.InitializePath([head1], [head2]);
	AILog.Info("Pathfinding...");
	local path = pathfinder.FindPath(1000);
	AILog.Info("Path Found: " + path);
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
	local tile2y = AIMap.GetTileX(position2);

	local distance = abs(tile1x - tile2x) + abs(tile1y - tile2y);
	AILog.Info(distance);

	local root = Node(tile1x, tile1y);
	local fullPath = [root];
	local actual = root;
	local next = null;
	AISign.BuildSign(root.tile, "ROOT");

	while (distance > 0) {
		next = actual;
		actual = Node(actual.x + 20, actual.y);
		local possibilities = Rails.BuildableAround(actual.x, actual.y);
		if (possibilities.Count() == 0) {
			AILog.Info("We are doomed");
		}
		local possibility = possibilities.Begin();

		fullPath.push(actual);
		AISign.BuildSign(actual.tile, "Node " + fullPath.len());

		local pathfinder = RailPathFinder();
		pathfinder.InitializePath([
			[actual.tile, actual.tile + AIMap.GetTileIndex(-1, 0)]
		], [
			[next.tile, next.tile + AIMap.GetTileIndex(-1, 0)]
		]);
		AILog.Info("Pathfinding...");
		local path = pathfinder.FindPath(1000);
		AILog.Info("Found path");
	}
}

function Rails::BuildableAround(x, y, radius = 1) {
	local tile = AIMap.GetTileIndex(x, y);
	local list = AITileList();
	list.AddRectangle(tile + AIMap.GetTileIndex(radius, radius), tile - AIMap.GetTileIndex(radius, radius));
	list.Valuate(AITile.IsBuildable);
	list.KeepValue(1);
	foreach(buildableTile, value in list) {
		AISign.BuildSign(buildableTile, "YES")
	}
	return list;
}

function Rails::NextNodePosition(from, to) {
	local coreDirection = Rails.MainDirection(from, to);
	local nextDirection = from.iteration;
	local howmuch = (from.iteration / 2).tointeger();
	if (from.iteration % 2 == 0) {
		nextDirection = coreDirection + howmuch + 1;
	} else {
		nextDirection = coreDirection - howmuch;
	}
}

function Rails::NextNodeByDirection(node, direction) {
	if (direction == Direction.LEFT) {
		return Node(node.x + 20, node.y)
	}
}

function Rails::MainDirection(from, to) {
	xDiffers = abs(from.x - to.x);
	yDiffers = abs(from.y - to.y);

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