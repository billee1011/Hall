-- struct TaskInfo
-- {
-- 	int nTaskID;			// 任务ID
-- 	char szTaskName[128];	// 任务名称
-- 	char szTaskDesc[256];	// 任务描述
-- 	int nTaskType;			// 任务类型
-- 	int nTaskStatus;		// 状态，0未领取，1已领取
-- 	int nTaskSchedule;		// 进度
-- 	int nTaskTarget;		// 目标
-- 	int nToolNum;			// 道具数量
-- 	int nToolType;			// 道具类型	1 = 金币 2 = 话费券（碎片）
		
-- 	TaskInfo()
-- 	{
-- 		memset(this,0,sizeof(TaskInfo));
-- 	}
-- };

TaskInfo = {}
TaskInfo.__index = TaskInfo

function TaskInfo:new()
	
	local self = {
		nTaskID = 0,
		szTaskName = "szTaskName",
		szTaskDesc = "szTaskDesc",
		nTaskType = 0,
		nTaskStatus = 0,
		nTaskSchedule = 0,
		nTaskTarget = 0,
		nToolNum = 0,
		nToolType = 0
	}

	setmetatable(self, TaskInfo)
	return self
end
