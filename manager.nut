require("commands/findPriority.nut");

class Manager {
	_queue = null;

    constructor() {
        _queue = PriorityQueue();
    }
}

function Manager::Next() {
	local command = this._queue.Pop();
	if (command == null) {
		FindPriority(this).Execute();
	} else {
        command.Execute();
    }
}

function Manager::InsertCommand(command, priority) {
	this._queue.Insert(command, priority);
}
