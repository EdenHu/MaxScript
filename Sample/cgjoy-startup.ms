Macroscript Exporter	
category:"Custom"
tooltip:" ExportTool "
--buttontext:"None" 
(
	
	local copyType=1
	local exConfigFile--@"C:\Users\milk\Documents\3dsMax\FBX\3dsMax2014_X64\Presets\2016.1\export\unity.fbxexportpreset"
	local pathSource--@"C:\Users\milk\Desktop\123"
	local pathSave
	
	fn StringIsEmpty str=
	(
		if (str==undefined or str=="" or str==" ") then 
		(
			return true
		)else
		(
			return false
		)
	)

	
	fn FilesProcess fPath=
	(
		arrNameTypes=#()
		case copyType of
			(
				1:
				(
					append arrNameTypes ".max"
				)
				2:
				(
					append arrNameTypes ".max"
					append arrNameTypes ".png"
				)
				3:
				(
					append arrNameTypes ".max"
					append arrNameTypes ".tga"
				)
				4:
				(
					append arrNameTypes ".max"
					append arrNameTypes ".psd"
				)
				5:
				(
					append arrNameTypes ""
				)
			)
		for type in arrNameTypes do
		(
			theFiles=getFiles(fPath+@"/*"+type)
			if (theFiles!=undefined and theFiles.count>0) then
			(
				for f in theFiles do
				(

					fileNameType= getFilenameType  f
					newPath=replace fPath 1 (pathSource.count) pathSave
					if (doesFileExist newPath)==false do
					(
						makeDir newPath --create folder
					)
					if fileNameType==".max" then
					(
						
						FBXExporterSetParam "LoadExportPresetFile" exConfigFile
						loadMaxFile f --useFileUnits:true quiet:false
						--saveMaxFile  
						max select all
						fileName=getFilenameFile f
						exportFile  (newPath+@"\"+fileName+".fbx") #noPrompt selectedOnly:true using:FBXEXP
					)
					else
					(
						copyFile f (newPath+(filenameFromPath  f))
					)
				)				
			)		
		)
		
	)
	
	--Find Path 
	fn FindFile fPath =
	(
		--print fPath
		for dir in GetDirectories (fPath+@"\*") do
		(
			--ExportFBX dir oldPath newPath
			FindFile dir 
		)
		FilesProcess fPath
	)
	
	
	try(destroyDialog exportWindow )catch()
	rollout exportConfig "Configuration" 
	(
		
		radiobuttons  rad_SeType "CopyFile :" \
		labels:#("None","PNG","TGA","PSD","ALL") columns:5 align:#left  \
		offsets:#([65,-16], [5,-16], [-60,-16], [-120,-16],[-180,-16]) default:1
		on rad_SeType  changed state do
			(
				copyType=state
			)
		
		button btn_ExConfigPath "Find Export Configuration File " width:355 \
		tooltip:"EX: C:\Users\UserName\Documents\3dsMax\FBX\3dsMax2014_X64\Presets\2015.0\export"
		on btn_ExConfigPath pressed do
			(
				f = getOpenFileName types:"Data(*.fbxexportpreset)|*.fbxexportpreset"
				if f!=undefined do
				(
					 btn_ExConfigPath.text=f
					exConfigFile=btn_ExConfigPath.text
				)
			)
		
	)
	
	rollout exportWindow "Export"
	(
		
		group "Source Path" 
		(
		edittext sourceTxt "Source:" fieldWidth:235 labelOnTop:false across:2 align:#left
		on sourceTxt changed txt do
			(
				--And the name is not the empty string,
				if txt != "" do
				(
					pathSource=txt
				)
			
			)
		button sourceButton "..." width:35 height:25 offset:[65,-5] 
		--button theBorderlessButton pathSource border:true
		on sourceButton pressed do
			(
				sp= getSavePath caption "Select Source Path"
				if sp!=undefined do
				(
					sourceTxt.text= sp
					pathSource=sp
				)
					
			)
		)
		
		group "Save Path" 
		(
		edittext prefix_Save "Save   :" fieldWidth:235 labelOnTop:false across:2 align:#left
		on prefix_Save changed txt do
			(
				--And the name is not the empty string,
				if txt != "" do
				(
					pathSave=txt
				)
			)
		button btn_Save "..."  width:35 height:25  offset:[65,-5]  --across:2 align:#right
			on btn_Save pressed do
			(
				sp= getSavePath caption "Select Save Path"
				if sp!=undefined do
				(
					prefix_Save.text= sp
					pathSave=sp
				)
			)
			
		)
		
		button exportButton "Explort"  width:100 height:25 across:2 alingn:#left
			on exportButton pressed do
			(
				--print sourceTxt.text
				--print saveTxt.text
				
				if (StringIsEmpty pathSource) then
				(
					messagebox("Source Path Is Null .")
				)
				
				else if (StringIsEmpty pathSave)then
				(
					messagebox(" Save Path Is Null .")
				)
				
				else if (StringIsEmpty exConfigFile)then
				(
					messagebox(" Export ConfigFile File Is Null .\n Example C:\Users\UserName\Documents\
						\n 3dsMax\FBX\3dsMax2014_X64\Presets\2015.0\export")
				)
				
				else
				(
					try
					(
						setSilentMode on 
						FindFile pathSource
						setSilentMode off
					  
					)
					catch
					(
						format "*** % ***\n" (getCurrentException())
					)
					
				)
			)
		checkbutton  chk_Config  "OpenConfig"  width:100 height:25 
			on chk_Config changed state do
			(
				if state then
				(
					exportWindow.height=350	
				)
				else
				(
					exportWindow.height=135
				)
			)
		
		
		
		SubRollout theSubrollout "Configuration" height:95  --width:360 offset:[-5,0]
	)
	createDialog exportWindow 370 135
	AddSubRollout exportWindow.theSubrollout exportConfig
	
	
)