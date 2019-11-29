--[[
	��ͼ����
	@Author: ccb
	@Date: 2017-11-01
]]
local ViewBase = class("ViewBase", function()
	local node = display.newNode();
	node:setNodeEventEnabled(true);
	cc(node):addComponent("components.behavior.EventProtocol"):exportMethods();
	return node;
end);

-- ����
ViewBase.FULL_VIEW 		= 4; 	-- ȫ��
ViewBase.LG_VIEW		= 3; 	-- ��
ViewBase.MID_VIEW		= 2; 	-- ��
ViewBase.SML_VIEW		= 1; 	-- С
ViewBase.TINY_VIEW		= 0; 	-- С
ViewBase.UNKOWN_VIEW 	= -1; 	-- δ֪
ViewBase.VT_MIN			= ViewBase.SML_VIEW;
ViewBase.VT_MAX			= ViewBase.FULL_VIEW;

--[[ ���� ]]
function ViewBase:ctor()

	-- ��ͼ����
	self._viewType = self.UNKOWN_VIEW;
	
	-- ע����ͼid
	self._viewId = xg.const.VIEW_ID[self.__cname];
end

--[[ �ж��Ƿ���view���� ]]
function ViewBase:isViewObject()
	return self._viewType ~= nil;
end

--[[ ע����ͼ���� ]]
function ViewBase:registerViewType(viewType)
	self._viewType = viewType;
end

--[[ ��ȡ��ͼ���� ]]
function ViewBase:getViewType()
	return self._viewType;
end

--[[ ��ȡ��ͼId ]]
function ViewBase:getViewId()
	return self._viewId;
end

--[[ �ر���ͼ ]]
function ViewBase:closeView()
	local bInterrupt = self:onCloseView();
	if not bInterrupt then
		display.getRunningScene():closeView(self);
	end
end

--[[ �����ر���ͼ ]]
function ViewBase:onCloseView()
	-- ����true��ʾȡ���ر�
	-- ����false��nil��ʾ�����ر�
	return false;
end

--[[ �˳����ڵ���� ]]
function ViewBase:onExit()
	xg.event:dispatchEvent({name = "ExitView", view = self});
end

--[[ ���븸�ڵ���� ]]
function ViewBase:onEnter()
	-- �ɷ��ڵ�onEnter��Ϣ
	xg.event:dispatchEvent({name = "EnterView", view = self});
end

--[[ �����³���ʱ����Ч���� ]]
function ViewBase:onEnterTransitionFinish()

end

--[[ �˳����г���ʱ����Ч��ʼ ]]
function ViewBase:onExitTransitionStart()

end

--[[ ����ȫ�������ڴ�ɾ��ʱ ]]
function ViewBase:onCleanup()

end

return ViewBase;
