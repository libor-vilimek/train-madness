class Manager {
	_queue = null;
    _industryRoutes = [];

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

function Manager::AddNewIndustryRoute(industryRoute) {
    _industryRoutes.push(industryRoute);
}

function Manager::GetIndustryRoutes() {
    return this._industryRoutes;
}