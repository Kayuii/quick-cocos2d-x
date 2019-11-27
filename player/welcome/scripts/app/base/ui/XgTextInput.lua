--[[
	整理 TextInput
	@Author: ccb
	@Date: 2017-11-22
	---------------------

	示例:
	1, 创建文本输入框
	local input = xg.ui:newTextInput({
		text = "Test",                                  -- 文本内容(可选)
		placeHolder = "Enter Place",                    -- 编辑框为空时提示文本(可选)
		fontColor = xg.color.green,                     -- 设置文本颜色 (可选)
		inputType = xg.ui.TEXT_INPUT_TYPE.EDITBOX,      -- 默认是 EditBox  (可选)
		maxLength = 10,                                 -- 编辑的最大数 (可选)
		passwordEnable = true,                          -- 需要显示成密码模式，传该值，反之可为nil (可选)
		size = cc.size(200, 50),                        -- 编辑框大小
		listener = function(event, editbox)             -- 监听方法 (可选)
			dump(event, "#####event");
		end
	});
	input:setReturnType(kKeyboardReturnTypeSend);   --设置键盘中return键显示的字符，此处是send
	input:setPosition(size.width/2, size.height/2);
	input:addTo(self);

	2, 如果参数列表中未传listener，可通过 onEdit 来注册监听。
	input:onEdit(function(event, pSender)
		-- event 返回的控件当前的状态
		if event == "began" then
			-- 开始输入
		elseif event == "changed" then
			-- 输入框内容发生变化
		elseif event == "ended" then
			-- 输入结束
		elseif event == "return" then
			-- 从输入框返回
		end
	end)

	3, 创建控件可根据情况来设置参数。
	
	-- 键盘返回类型
	enum KeyboardReturnType {
		kKeyboardReturnTypeDefault = 0,
		kKeyboardReturnTypeDone,
		kKeyboardReturnTypeSend,
		kKeyboardReturnTypeSearch,
		kKeyboardReturnTypeGo,
	};
	
	-- 定义文本停靠
	enum EditBoxTextAlignType {
		kEditBoxTextAlignLeft = 0,
		kEditBoxTextAlignRight,
		kEditBoxTextAlignCenter,
	};
	
	-- 定义允许用户输入的文本类型
	enum EditBoxInputMode {
		kEditBoxInputModeAny = 0, -- 允许用户输入任何文本, 包括换行符
		kEditBoxInputModeEmailAddr, -- 允许用户输入电子邮件地址
		kEditBoxInputModeNumeric, -- 允许用户输入整数值
		kEditBoxInputModePhoneNumber, -- 允许用户输入电话号码
		kEditBoxInputModeUrl, -- 允许用户输入 URL
		kEditBoxInputModeDecimal, -- 允许用户输入实数值
		kEditBoxInputModeSingleLine, -- 允许用户输入任何文本, 但换行符除外
	};
	
	-- 定义了输入文本是如何显示/格式化的
	enum EditBoxInputFlag {
		kEditBoxInputFlagPassword = 0, -- 输入的文本是机密数据, 只要有可能就应该被遮盖
		kEditBoxInputFlagSensitive, -- 输入的文本是敏感数据, 实现必须永远不要存储在用于预测、编号或其他加速输入方案的字典或表中
		kEditBoxInputFlagInitialCapsWord, -- 此标志是对实现的提示, 在文本编辑期间, 每个单词的初始字母都应大写
		kEditBoxInputFlagInitialCapsSentence, -- 此标志是对实现的提示, 在文本编辑期间, 每个句子的首字母都应大写
		kEditBoxInputFlagInitialCapsAllCharacters, -- 自动大写所有字符
	};
]]

local XgTextInput = class("XgTextInput", function(options)
	options = options or {};
	options.inputType 		= options.inputType or xg.ui.TEXT_INPUT_TYPE.EDITBOX;
	options.text 			= options.text or nil;
	options.placeHolder 	= options.placeHolder or nil;
	options.maxLength 		= options.maxLength or nil;
	options.passwordChar 	= options.passwordChar or nil;
	options.passwordEnable 	= options.passwordEnable or nil;
	options.size 			= options.size or cc.size(150, 30);
	options.font 			= options.fontName or xg.font.defName();
	options.fontSize 		= options.fontSize or xg.font.defSize();
	options.image 			= options.image or xg.const.DEF_TEXT_INPUT_IMAGE;
	options.listener 		= options.listener or nil;
	options.x, options.y 	= options.x or 0, options.y or 0;
	return ui.newEditBox(options);
end);

--[[ 构造函数 ]]
function XgTextInput:ctor(options)
	self._options = options or {};

	-- 补足这些设置
	if self._options.inputType == xg.ui.TEXT_INPUT_TYPE.EDITBOX then
		if self._options.text then
			self:setText(self._options.text);
		end
		if self._options.textAlign then
			self:setTextAlign(self._options.textAlign);
		end
		if self._options.placeHolder then
			self:setPlaceHolder(self._options.placeHolder);
		end
		if self._options.passwordEnable then
			self:setInputFlag(kEditBoxInputFlagPassword);
		end
		if self._options.maxLength and 0 ~= self._options.maxLength then
			self:setMaxLength(self._options.maxLength);
		end
		if self._options.font then
			self:setFontName(self._options.font);
		end
		if self._options.fontSize then
			self:setFontSize(self._options.fontSize);
		end
		if self._options.placeholderFontColor then
			self:setPlaceholderFontColor(self._options.placeholderFontColor);
		end
		if self._options.fontColor then
			self:setFontColor(self._options.fontColor);
		end
		-- 其他参数如果需要补足请参考 EditBox 的接口。
	end
end

--[[ 编辑监听 ]]
function XgTextInput:onEdit(callback)
	self._options.listener = callback or self._options.listener;
	if self._options.listener then
		if self._options.inputType == xg.ui.TEXT_INPUT_TYPE.EDITBOX then
			self:registerScriptEditBoxHandler(self._options.listener);
		end
	end
end

return XgTextInput;
