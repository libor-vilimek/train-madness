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

    static function CreateFromTile(tile) {
        local tileX = AIMap.GetTileX(tile);
        local tileY = AIMap.GetTileY(tile);

        return Node(tileX,tileY);
    }
}
