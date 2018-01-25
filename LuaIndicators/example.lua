Settings= {
	Name = "Example1" 
}
function Init()
	return 1
end
function OnCalculate(index)
	local label = {}
	label.DATE = '20180104'
	label.TIME = '173000'
	label.YVALUE = 238
	label.R = 0 
	label.G = 0 
	label.B = 0 
	label.TRANSPARENCY = 0 
	label.TRANSPARENT_BACKGROUND = 1
	label.FONT_FACE_NAME = 'Verdana'  
	label.FONT_HEIGHT = 10  
	label.HINT = 'sdf'
	label.TEXT = 'text'
	local LabelID = AddLabel('asdf', label)
	return nil
end 
