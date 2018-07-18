/* 
------------------------------------------------------------------
BATCH RETARGETER, 3dsmax 2013-2016 (tested)
George Allan AKA PixelDamage
www.pixeldamage.net
-------------------------------------------------------------------


---------------
Version 1.06 (13 Oct 2015) - added getallbips function
---------------
---------------
Update 1.05 (21 Jan 2015) - added a check for zero length animations (single frame on key 0)
---------------
---------------
Update 1.04 (18 Dec 2014) - added code to recursively select custom hierarchies (thanks to Jim Jagger's Bip Tools for reference)
---------------

-------------------
OVERVIEW
-------------------
This is a script to batch retarget all bip files in c:\batch\in to c:\batch\out 
The script will check if these folders exist and prompt the user to auto generate them 

c:\batch\in\*.bip and biped.fig >>>>> Script Retarget >>>>>> fbx (fbx specific export settings can be changed below)

-------------------
OTHER NOTES
-------------------
This is my first proper Maxscript. I've tested it fairly thorougly and it seems to be quite robust and has saved me a lot of time so far. 
If you have any tips, bugs or requests please contact me at pixeldamage@hotmail.com


-------------------
IMPORTANT!!: 
-------------------
BIPED must be called by it's default name "Bip"
BIPED.FIG must be placed in C:\BATCH\IN FOLDER with the source BIP files
Twist Links must be unfrozen
*/
  
MacroScript BatchRetargeter
category:"Pixeldamage"
tooltip:"Batch Bip to FBX Retargeter 1.06"
buttontext:"BatchRT"
 
(	
	Print "*****************************************"
	Print "pixeldamage's Batch Retargeter (www.pixeldamage.net)"
	Print "pixeldamage@hotmail.com"
	Print "*****************************************"
	-- This is the main variable which controls whether or not the retargeter runs based on having found the source files necessary
	Retargeting=true
 	st = timestamp()
			(	--check for biped named Bip
			if $Bip==undefined then Bipquery=false
			if Bipquery==false then Retargeting=false
			if Retargeting==false then messageBox "Please ensure you have a biped called Bip (not Bip001 or anything else) in your scene.  \n\nYou can rename it by going to:  \n\nMotion Tab/Biped/Modes & Display/Name"
			--allbips = getallbips()
			
			fn getAllBips =
			(
					allBips = #()
					for obj in geometry do
					(
						if classof obj.controller == Vertical_Horizontal_Turn then 
						(
							append allBips obj
						)
					)
					return allBips
				)
			
			allbips = getallbips()
			
			)
		
	
			-- Using dotNet - Find if user has required input folders

			InputDirCheck= ((dotnetclass "System.IO.Directory").exists "c:\\batch\\in") 

				If InputDirCheck==True  then 
															(
																print "Checking for c:\batch\in..."
																print InputDirCheck
																messageBox "Succesfully located your source folder :\n\nc:\batch\in" title:"Success :)" beep:false 
																print "Succesfully located the source folder" 		
															)	
					else if 
							queryBox "This script requires an input (source) folder to load your .bip files. \n\nPlease allow me to generate the required folders : \n\nc:\batch\in  \nc:\batch\out \n\nShall I generate these folders? \n\n(No will exit the script) "
							then 
								(	
									--make necessary directories for input and output files

										--this is where the source .bip files go
											makeDir "C:\\batch\\in" 
										--this is where the fbx export data goes
											makeDir "C:\\batch\\out"

									Retargeting=false			
									messageBox "Succesfully generated these two folders at:\n\nc:\batch\in \nc:\batch\out \n \nNow please manually copy your: \n\n1)*.bip animation files \n2)biped.fig file \n\ninto c:\batch\in source folder and re-run this script" beep:false 
								)

					else 
								(
									Retargeting=false 
										print "Retargeting has failed due to missing batch folder in c:\batch\in"
								)

		InputFigCheck= ((dotnetclass "System.IO.File").exists "c:\\batch\\in\Biped.Fig")
											
		If InputFigCheck==True then print "Biped.Fig file located" else 
		(
			Retargeting=false
			print "Retargeting status:" 
			print Retargeting
			messageBox "Please add your :\n\nbiped.fig (named as such) \n\nto: \n\nc:\batch\in\n\nThis is so I can retarget each fbx to the target biped." title:"Oh just one last thing..."
		)
				
If Retargeting==true do
	
			(
				-- Disable figure mode
				$Bip.controller.figureMode=false

				-- Cycles through all bip files in our c:\batch\in directory and imports bip into our biped
				files = getFiles "C:\\batch\\in\\*.bip"
											
				-- FBX EXPORT SETTINGS CHANGED HERE
										FbxExporterSetParam "Cameras" false
										FbxExporterSetParam "Lights" false
										FbxExporterSetParam "Skin" false 
										FbxExporterSetParam "EmbedTextures" false
										FbxExporterSetParam "Animation" true							
										FBXExporterSetParam "UpAxis" "Y"
										FBXExporterSetParam "BakeAnimation"  true
										FBXExporterSetParam "ConvertUnit" "m"
										FBXExporterSetParam "FileVersion" "FBX201300" 
										FBXExporterSetParam "AxisConversionMethod" #animation

				-- select biped and load bip files one by one
				for f in files do   
					
										(
											with redraw off
											undo off
											--delete all previous animation off the skeleton
											biped.clearAllAnimation$Bip.controller
											--load each bip file
											biped.loadbipfile $Bip.transform.controller f	
											--turn on figure mode
											$Bip.controller.figureMode=true
											--reload/reset the figure file
											biped.loadfigfile $Bip.transform.controller "c:\\batch\in\biped.fig"
											--turn off figure mode (ready to export)	
											$Bip.controller.figureMode=false
											
											--set frame length to animation key length
												
												-- find number of keys
												num_keys = numkeys $Bip.controller[1].controller
												-- get start frame
												startTime = getkeytime $Bip.controller[1].controller 1
												-- set end frame
												endTime = startTime
											
												-- loop through all the keys to find the last one and set as endtime string array
														for i = 1 to num_keys do
																(
																key_time = getkeytime $Bip.controller[1].controller i
																if key_time > endtime then
																endtime = key_time
																)

												--remove the frame 'f' from the string
												tempArr= filterstring (endtime as string) "f"
												--set endtime as an integer
												endTime_int= tempArr[1] as integer
												format "endTime = %\n" (endTime_int) 
												--set animation range to the correct key lenth
												if endTime_int > 0 then (animationRange = interval 0 endTime_int) else (animationRange = interval 0 1) 
																		
											
											--select whole biped for export
											clearSelection()
											
											--choosing custom hierarchies
												(
													temparray =#()
													select allBips		
													for i = 1 to 25 do
													(
														for j = 1 to $selection.count do
														(
															append temparray ($selection[j])
														)
														max select child
													)
													
													for i = 1 to temparray.count do
													(
														selectmore temparray[i]
													)
												)


											--export the fbx
											exportFile ("C:\\batch\\out\\"+ getfilenamefile (f) + ".fbx") #noPrompt selectedOnly:true using:FBXEXP
								)
			) 
			
		et = timestamp()
		print "total time ms="
		print (et-st)
		)
					