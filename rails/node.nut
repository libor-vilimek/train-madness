class Node {
	x = -1;
	y = -1;
	tile = null;

	constructor(x, y) {
		this.x = x;
		this.y = y;
		this.tile = AIMap.GetTileIndex(x, y);
	}

	function IsSame(node){
		return Node.AreSameNodes(this, node);
	}

	function ToString() {
		return "Node(" + this.x + ":" + this.y + ")";
	}

	function MovePositionTile(tile){
		return this.MovePositionNode(Node.CreateFromTile(tile));
	}

	function MovePositionNode(node){
		return Node(this.x + node.x, this.y + node.y);
	}

	function MovePositionByDirection(direction) {
		return this.MovePositionNode(Rails.DirectionToNode(direction));
	}

	function MovePositionByXY(x,y) {
		return Node(this.x + x, this.y + y);
	}

    static function CreateFromTile(tile) {
        local tileX = AIMap.GetTileX(tile);
        local tileY = AIMap.GetTileY(tile);

        return Node(tileX,tileY);
    }

	static function GetManhattanDistance(node1, node2) {
		return AITile.GetDistanceManhattanToTile(node1.tile, node2.tile);
	}

	static function AreSameNodes(node1, node2) {
		return (node1.x == node2.x && node1.y == node2.y);
	}
}
