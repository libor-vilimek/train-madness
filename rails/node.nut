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
}
