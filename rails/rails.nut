const WAYPOINT_LENGTH = 16;
const WAYPOINT_LENGTH_DIAGONAL = 12;
const MAX_PATHFINDING_TIME = 1500;
const MAX_PATHFINDING_TIME_FINAL = 4500;
const DIFF_TO_FINISH_ROUTE = 35;

enum RailBuildPhase {
	normal
}

class DirectionNode {
	fromNode = null;
	toNode = null;

	constructor(fromNode, toNode) {
		this.fromNode = fromNode;
		this.toNode = toNode;
	}

	function ToString() {
		return "DirectionNode: " + this.fromNode.ToString() + " " + this.toNode.ToString();
	}
}

class BacktrackingNode {
	direction = null;
	iteration = 0;
	directionNode = null;
	parentNode = null;
	path = null;
	depth = 0;

	constructor(directionNode, direction = null) {
		this.directionNode = directionNode;
		this.direction = direction;
		this.iteration = 0;
	}

	function CreateChild(directionNode, path, direction) {
		local child = BacktrackingNode(directionNode, direction);
		child.parentNode = this;
		child.depth = this.depth + 1;
		child.path = path;

		return child;
	}
}

class Rails {
	fromDirectionNode = null;
	toDirectionNode = null;
	buildPhase = RailBuildPhase.normal;
	actualBacktrackingNode = null;

	constructor(fromDirectionNode, toDirectionNode) {
		this.fromDirectionNode = fromDirectionNode;
		this.toDirectionNode = toDirectionNode;
		this.buildPhase = RailBuildPhase.normal;
		local direction = Rails.MainDirection(fromDirectionNode.toNode, toDirectionNode.fromNode);
		this.actualBacktrackingNode = BacktrackingNode(fromDirectionNode, direction);
	}

	function BuildNext() {
		Log.Debug(" ", DEBUG_TYPE.BUILDING_RAIL);
		Log.Debug("Rails::BuildNext *** Starting next part", DEBUG_TYPE.BUILDING_RAIL);
		if (this.actualBacktrackingNode.iteration >= 8) {
			Log.Debug("Rails::BuildNext *** Removing from the path", DEBUG_TYPE.BUILDING_RAIL);
			if (this.actualBacktrackingNode.parentNode == null) {
				Log.Debug("Rails::BuildNext *** Cancelling - path was not found", DEBUG_TYPE.BUILDING_RAIL)
				return false;
			}

			Rails.RemoveRail(this.actualBacktrackingNode.path);
			this.actualBacktrackingNode = this.actualBacktrackingNode.parentNode;
			this.actualBacktrackingNode.iteration++;
			return true;
		}

		local result = Rails.PlanAndBuildPartOfRail(this.actualBacktrackingNode, this.toDirectionNode);
		if (result == null) {
			this.actualBacktrackingNode.iteration++;
			Log.Debug("Rails::BuildNext *** Rail path not found. Increasing iteration: " + this.actualBacktrackingNode.iteration, DEBUG_TYPE.BUILDING_RAIL)
			return true;
		}

		Log.Debug("Rails::BuildNext *** New Path was found and built", DEBUG_TYPE.BUILDING_RAIL)
		this.actualBacktrackingNode = this.actualBacktrackingNode.CreateChild(result.directionNode, result.path, result.direction);

		if (result.completed) {
			Log.Debug("Rails::BuildNext *** RAIL FINISHED!!! Exiting", DEBUG_TYPE.BUILDING_RAIL);
			return false;
		}

		return true;
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

function Rails::IsOppositeDirection(direction1, direction2) {
	return direction1 == Rails.OppositeDirection(direction2);
}

function Rails::OppositeDirection(direction) {
	return (direction + 4) % 8;
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

function Rails::PlanAndBuildPartOfRail(actualBacktrackingNode, toDirectionNode) {
	local fromNode = actualBacktrackingNode.directionNode.toNode;
	local toNode = toDirectionNode.fromNode;
	local possibility = toNode;
	local direction = actualBacktrackingNode.direction;
	local nextNodeInDirection = toDirectionNode.toNode;

	if (Node.GetManhattanDistance(fromNode, toNode) > DIFF_TO_FINISH_ROUTE) {
		Log.Debug("Rails::PlanAndBuildPartOfRail *** Looking for next waypoint From " + fromNode.ToString() + " to" + toNode.ToString(), DEBUG_TYPE.BUILDING_RAIL);
		local newNodeAndDirection = Rails.NextNodePosition(fromNode, toNode, actualBacktrackingNode.direction, actualBacktrackingNode.iteration)
		local nextPos = newNodeAndDirection.node;
		direction = newNodeAndDirection.direction;
		// Na = Node Around, it will look around this node for suitable locations
		Log.CreateSign(nextPos.tile, "Na" + actualBacktrackingNode.depth + ":" + nextPos.ToString(), DEBUG_TYPE.BUILDING_RAIL);
		Log.Debug("Rails::PlanAndBuildPartOfRail *** Na" + actualBacktrackingNode.depth + ":" + nextPos.ToString(), DEBUG_TYPE.BUILDING_RAIL);

		if (Rails.IsOppositeDirection(actualBacktrackingNode.direction, direction)) {
			Log.Debug("Rails::PlanAndBuildPartOfRail *** Skipping reverse direction", DEBUG_TYPE.BUILDING_RAIL);
			return null;
		}

		possibility = Rails.BestNodeToContinuePath(fromNode, nextPos, direction);
		if (possibility == null) {
			Log.Debug("Rails::PlanAndBuildPartOfRail *** Not even one usable tile was found", DEBUG_TYPE.BUILDING_RAIL);
			return null;
		}
		nextNodeInDirection = possibility.MovePositionByDirection(direction);
		// Ns = Node specific, it will create rail to this exact location
		Log.CreateSign(possibility.tile, "Ns" + actualBacktrackingNode.depth + ":" + possibility.ToString(), DEBUG_TYPE.BUILDING_RAIL);
		Log.Debug("Rails::PlanAndBuildPartOfRail *** Ns" + actualBacktrackingNode.depth + ":" + possibility.ToString()), DEBUG_TYPE.BUILDING_RAIL
	} else {
		Log.Debug("Rails::PlanAndBuildPartOfRail *** From " + fromNode.ToString() + " to " + toNode.ToString() + " is close enough, finishing route");
	}

	local pathfinder = RailPathFinder();
	Log.Debug("Rails::PlanAndBuildPartOfRail *** Pathfinding from " + actualBacktrackingNode.directionNode.ToString() + " to " +
		nextNodeInDirection.ToString() + "-" + possibility.ToString(), DEBUG_TYPE.BUILDING_RAIL);
	pathfinder.InitializePath([
		[possibility.tile, nextNodeInDirection.tile]
	], [
		[fromNode.tile, actualBacktrackingNode.directionNode.fromNode.tile]
	]);

	local findingTime = MAX_PATHFINDING_TIME;
	if (possibility.tile == toNode.tile) {
		findingTime = MAX_PATHFINDING_TIME_FINAL;
	}

	local path = pathfinder.FindPath(findingTime);

	if (path == false || path == null) {
		Log.Debug("Rails::PlanAndBuildPartOfRail *** Path not found", DEBUG_TYPE.BUILDING_RAIL);
		return null;
	}
	local newNode = possibility.MovePositionNode(Rails.DirectionToNode(direction));

	Log.Debug("Rails::PlanAndBuildPartOfRail *** Found Path: Next node no. " + actualBacktrackingNode.depth + ":" + newNode.ToString(), DEBUG_TYPE.BUILDING_RAIL);
	Log.Debug("Rails::PlanAndBuildPartOfRail *** Building from " + fromNode.ToString() + " to " + newNode.ToString(), DEBUG_TYPE.BUILDING_RAIL);
	// Nn = Node next, where new part of the rail will start
	Log.CreateSign(newNode.tile, "Nn" + actualBacktrackingNode.depth + ":" + newNode.ToString(), DEBUG_TYPE.BUILDING_RAIL);
	Log.Debug("Rails::PlanAndBuildPartOfRail *** Nn" + actualBacktrackingNode.depth + ":" + newNode.ToString(), DEBUG_TYPE.BUILDING_RAIL);

	Rails.BuildRail(path);
	return {
		directionNode = DirectionNode(possibility, nextNodeInDirection),
		path = path,
		direction = direction,
		completed = possibility.tile == toNode.tile
	};
}

function Rails::NextNodePosition(from, to, currentDirection, iteration) {
	Log.Debug("Rails::NextNodePosition *** Going from " + from.x + ":" + from.y + " to " + to.x + ":" + to.y, DEBUG_TYPE.BUILDING_RAIL);
	local nextDirection = null;

	if (Rails.IsBeneficalToKeepDirection(from, to, currentDirection) && iteration == 0) {
		nextDirection = currentDirection;
	} else {
		local coreDirection = Rails.MainDirection(from, to);
		Log.Debug("Rails::NextNodePosition *** Core direction is: " + coreDirection, DEBUG_TYPE.BUILDING_RAIL);
		local howmuch = (iteration / 2).tointeger();
		if (iteration % 2 == 0) {
			nextDirection = (coreDirection - howmuch + 8) % 8;
		} else {
			nextDirection = (coreDirection + howmuch + 1) % 8;
		}
	}

	Log.Debug("Rails::NextNodePosition *** Next direction is: " + nextDirection, DEBUG_TYPE.BUILDING_RAIL);
	local change = Rails.DirectionChange(nextDirection);
	return {
		node = Node(from.x + change.x, from.y + change.y),
		direction = nextDirection
	};
}

function Rails::IsBeneficalToKeepDirection(from, to, direction) {
	local xDiffers = abs(from.x - to.x);
	local yDiffers = abs(from.y - to.y);

	if (Rails.IsDirectionHorizontal(direction) && xDiffers < WAYPOINT_LENGTH * 3 / 2) {
		Log.Debug("IsBeneficalToKeepDirection: The connection is horizontal, but xDiffers is not big enough: " + xDiffers);
		return false;
	}

	if (Rails.IsDirectionVertical(direction) && yDiffers < WAYPOINT_LENGTH * 3 / 2) {
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

function Rails::BestNodeToContinuePath(actualNode, targetNode, direction, radius = 2) {
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
			return Node.CreateFromTile(tile);
		}
	}

	return null;
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