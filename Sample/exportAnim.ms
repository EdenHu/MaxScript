------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																					/* FBX Exporter MultiTakes
																					By Sen / PandaProds /Sen.Reallusion.CCD@free.fr
																					25/12/2012
																					3dsmax 2011 , fbx 2013
																					*/
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
if (FBXEXPORT != undefined) and (FBXEXPORT.isdisplayed ) do
	(destroyDialog FBXEXPORT)

---------------------------------------------------------------------------------------------------------------------------------------------------Rollout
---------------------------------------------------------------------------------------------------------------------------------------------------Rollout

rollout  FBXEXPORT "FBX Exporter"  
(	
Groupbox GPTake pos:[5,0] width:190 height:130
	edittext TakeName "TakeName : " pos:[10,15] width:180
	label LBStartFrame "FrameStart: " pos:[10,40]
	spinner SPStartFrame "" pos:[75,40] range:[animationRange.start ,animationRange.end,0] type:#integer width:48 
	label LBEndFrame "FrameEnd: " pos:[10,70]
	spinner SPEndFrame "" pos:[75,70] range:[animationRange.start ,animationRange.end,0] type:#integer width:48 
	button BTAdd "Add" pos:[10,100] width:50 height:20
	button BTRemove "Remove"  pos:[75,100] width:50 height:20 tooltip:"Remove Selected take"
	button BTRemoveALL "Reset" pos:[140,100] width:50 height:20 tooltip:"Reset all UI"
		
	dotNetControl lv "system.windows.forms.listView" pos:[5,135] width:190 height:200 
	
	Label LBFileName "FileName: " pos:[5,345]
	edittext EditTextFilename "" pos:[50,345] width:120
	label LBExtension ".fbx" pos:[171,345]
	editText edt_path "Export Location:" labelOnTop:true readOnly:true text: (pathConfig.getProjectSubDirectory 3)   pos:[13,372] 
	button btn_browse "Browse..." width:100 height:20 pos:[13,415] 
	button BTExportSelected "Export Selected" pos:[17,450]
	button BTExport"Export All" pos:[130,450]
	
	label credits "main credits:" pos:[70,480] 
	hyperLink  HPemail "Sen.Reallusion.CCD@free.fr"  pos:[33,500] 
	address:"Sen.Reallusion.CCD@free.fr" 
	

-----------------------------------------------------------------------------------------------------------------------------------------------------Variables
-----------------------------------------------------------------------------------------------------------------------------------------------------Varialbes

	--Variables
	
	local align = dotNetClass "System.Windows.Forms.HorizontalAlignment"
	local Columnslv = #(#("Name", 106, align.Center),#("Start", 40, align.Center),#("End", 40, align.Center))
	local itemClass = dotNetClass "ListViewItem"
	local MyTakeArray = #()
	local TestNameResult	
		
		
		
-----------------------------------------------------------------------------------------------------------------------------------------------------Functions
-----------------------------------------------------------------------------------------------------------------------------------------------------Functions
		
	--Functions 
		
	fn initLv lv  =
	(
		lv.view=(dotNetClass "system.windows.forms.view").details
		lv.FullRowSelect = true		
		lv.GridLines = true			
		lv.MultiSelect = true	
		lv.IsAccessible = false
		lv.backcolor = (dotnetclass "system.drawing.color").SteelBlue
		lv.LabelEdit = true
		lv.checkboxes = false
	)	
	
	fn addColumns MyLv Array =
	(
		for c in Array do
		(
			MyLv.columns.add c[1] c[2] c[3]
		)
	)		
	
	fn populateList MyLv TextEntered FirstFrame FrameEnd =
	(
		Nametake = TextEntered
		Start =  FirstFrame 
		End = FrameEnd
		data = #(NameTake)
		local item = for i in data collect
		(
			dotNetObject itemClass #(i ,Start, End)
		)
		MyLv.items.AddRange item	
		MyLV.Update()
	)			
		 
	
	-- ************* Fn from NET-ListViewWrapper.ms (3dsmax>stdplugs>stdscripts>....) : ***************
	
	 fn GetLvSelection lv =
	 (
	  --[brief] Returns a maxscript array of selected ListViewItems.
	  --    The SelectedItems property of a listview is of class 
	  --    System.Windows.Forms.SelectedListViewItemCollection
	  --[param] lv - A ListView control
	  --[return] A maxscript array of System.Windows.Forms.ListViewItem objects
	  local sel = lv.selectedItems
	  local result = #()
	  if sel.count != 0 then
	  (
	   local nCount = sel.count - 1 --.NET arrays are zero based
	   result = for i = 0 to nCount collect ( sel.item[i] )
	  )
	  else
	  (
	   result = #()
	  )
	  result
	 )
	 
	 fn GetLvItems Mylv =
	(
		--[brief] Returns a maxscript array of ALL ListViewItems in the listview control
		--[param] lv - The System.Windows.Forms.ListView class control
		--[return] A maxscript array of System.Windows.Forms.ListViewItem objects
		local result = #()
		local nCount = Mylv.items.count - 1 --.NET arrays are zero based
		local MylvItems = Mylv.items
		for i = 0 to nCount do
		(
			append result MylvItems.item[i]
		)
		result 
	) 	
	
	fn GetLvItemName Mylv nRow nColumn =
	(
		--[brief] Gets the text from the listviewItem or subItem. The listview
		--        must be in report mode, which means displaying its data in a 
		--        grid format. All .NET arrays are zero based.
		--[param] lv - The System.Windows.Forms.ListView class control
		--[param] nRow - An integer for the row, or ListViewItem to query
		--[param] nColumn - An integer for the column (if any) to help locate the cell
		--        by an x y coordinate system.
		--[return] A string from the specified cell.
		MyTakeArray = #()	
		(
			for i = 1 to nRow do		
			(
				local li = Mylv.Items.item[i-1]
				local si = li.subItems.item[1]
				local si2 = li.subItems.item[2]
				resultName = li.text 
				FirstFrame = si.text as integer
				EndFrame = si2.text as integer
				append MyTakeArray #(resultName , FirstFrame , EndFrame)
			)	
			print MyTakeArray
		)
	) 	 
	
	fn Testname =
	(
		for i = 1 to lv.items.count do			
		(
			local li = lv.Items.item[i-1]
			resultName = li.text 
			if resultName == "" then
			(
				TestNameResult = false
				return TestNameResult	
			)
			else 
			(
				TestNameResult = true
			)			
		)	
	return TestNameResult	
	)		
	 
-----------------------------------------------------------------------------------------------------------------------------------------------------OpenRollout
-----------------------------------------------------------------------------------------------------------------------------------------------------OpenRollout
			
	on FBXEXPORT open do
	(
		pluginManager.loadClass FBXIMP
		pluginManager.loadClass FBXexp
		initLV lv 
		addColumns lv Columnslv
		clearlistener()
	)
		
-----------------------------------------------------------------------------------------------------------------------------------------------------Button Events
-----------------------------------------------------------------------------------------------------------------------------------------------------Button Events
			
	on BTAdd pressed do
	(
		Newtake = Takename.text
		FrameStart = SPStartFrame.value as string
		FrameEnd = SPEndFrame.value as string
			if SPEndFrame.value >=  SPStartFrame.value  then
			(
			populateList lv	NewTake FrameStart FrameEnd
			SPStartFrame.value = 0
			SPEndFrame.value = 0
			TakeName.text = ""        
			)
			else
			(
			Messagebox  "Do not set a frameEnd < frameStart. If frameStart and frameEnd do not define an interval with keys the split function will not validate it" title:"Error" beep:true
			SPStartFrame.value = 0
			SPEndFrame.value = 0	
			)		    
	)	
		
	
	on BTRemove pressed do  
	( 
		tempItemsSelected = (GetLvSelection lv)
		 for i in tempItemsSelected do 
		 (
			 lv.Items.Remove i
		 )		 
	)  	 
	 
	
	on BTRemoveALL pressed do 
	(
		SPStartFrame.value = 0
		SPEndFrame.value = 0
		TakeName.text = ""  
		EditTextFilename.text = ""
		lv.items.clear() 		
	)	
	
		on btn_browse pressed do
			(
				folderPath = getSavePath()
				if folderPath !=undefined then edt_path.text = folderPath --copies savepath to text box above
			)--end do
	
	on BTExportSelected pressed do --export selected
	(
			if lv.items.count == 0 do
			(
				messagebox "No take to export ?????" title:"Fbx Exporter" beep:false
			)
			if lv.items.count > 0  then
			(
				Testname()
				(
						if TestNameResult == false then
						(
							messagebox "Please Name all your take" title:"Impossible Export " beep:false
						)
						else
						(
							ExportFileName = EditTextFilename.text as String	
							GetLvItemName lv lv.items.count 3			 
							(
							for i in MyTakeArray do 
								(
								FBXExporterSetParam "SplitAnimationIntoTakes" i[1] i[2] i[3]
								)
							
								if edt_path.text == "" then folderPath = pathConfig.getProjectSubDirectory 3 -- sets export folder to default 3dmax "project export folder" if proper one wasn't selected.
									else folderPath = edt_path.text
								exportfile (folderPath +"\\" + ExportFileName) using:fbxexp selectedOnly:true
								clearlistener()
							)
							FBXExporterSetParam "SplitAnimationIntoTakes" "-clear" 
						)	
				)
			)			
		EditTextFilename.text = ""
		SPStartFrame.value = 0
		SPEndFrame.value = 0
		TakeName.text = ""	
		MyTakeArray =#()						
	)	
	
	
	on BTExport pressed do --export all
	(
			if lv.items.count == 0 do
			(
				messagebox "No take to export ?????" title:"Fbx Exporter" beep:false
			)
			if lv.items.count > 0  then
			(
				Testname()
				(
						if TestNameResult == false then
						(
							messagebox "Please Name all your take" title:"Impossible Export " beep:false
						)
						else
						(
							ExportFileName = EditTextFilename.text as String	
							GetLvItemName lv lv.items.count 3			 
							(
							for i in MyTakeArray do 
								(
								FBXExporterSetParam "SplitAnimationIntoTakes" i[1] i[2] i[3]
								)
								
									if edt_path.text == "" then folderPath = pathConfig.getProjectSubDirectory 3 -- sets export folder to default 3dmax "project export folder" if proper one wasn't selected.
									else folderPath = edt_path.text
								exportfile (folderPath +"\\" + ExportFileName) using:fbxexp
								clearlistener()
							)
							FBXExporterSetParam "SplitAnimationIntoTakes" "-clear" 
						)	
				)
			)			
		EditTextFilename.text = ""
		SPStartFrame.value = 0
		SPEndFrame.value = 0
		TakeName.text = ""	
		MyTakeArray =#()						
	)	
	
	
	
	on HPemail rightClick do		
	(
	ShellLaunch "mailto:Sen.Reallusion.CCD@free.fr" ""
	)
	

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
)	
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------END	END END END END 

createDialog FBXEXPORT 200 530 style:#(#style_titlebar, #style_sysmenu,#style_minimizebox,#style_maximizebox) pos:(GetDialogPos FBXEXPORT + [25,160])