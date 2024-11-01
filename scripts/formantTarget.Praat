﻿###################################################################################################################################################################
## formantTarget.Praat                                                                                                                                            #
##                                                                                                                                                                #
## REQUIRES PRAAT 6.3.17 OR ABOVE                                                                                                                                 #
##                                                                                                                                                                #       
## This script provides an interface for hand-correcting F1, F2, and F3 measurements at vowel targets placed using correctBoundary_addTarget_inSent.Praat         #
## Note that individual vowels need to be extracted into a single .wav file from the sentence using extractVowel.Praat. 									      #
## As per correctBoundary_addTarget_inSent.Praat, the target is located on tier 3 (point tier) and named VNt, shorthand for "target of the Nth vowel".            #
## To use different target names edit correctBoundary_addTarget_inSent.Praat and the current script (lines XXX).                                                  #
## The script loads sound files and matching textgrids from the subfolders of the "sound" folder and tracks corrected files.                                  	  #
##                                                                                                                                                            	  #
##                                                                                                                                                            	  #         
## References:                                                                                                                                                    #
## Script by Tuende Szalay (contact at tuendeszalay.github.io), based on formantTrajectory.Praat (Szalay & Benders).											  # 
## If you used the script (as-is or modified), cite                                          				                                        			  #                                                                                                                                 # 
## Szalay, T., Nguyen, D. D., Chacon, A. & Madill, C.(2023). Formant change and individual variation in male-to-female transgender speakers during voice therapy. #
##  In J. Acoust. Soc. Am. 1 October 2023; 154 (4_supplement): A336. https://doi.org/10.1121/10.0023719.         			                                      #
##                                                                                                                                                                #
## Sample data taken from the AusTalk audio corpus of Australian English accessible via https://app.alveo.edu.au/catalog/austalk                                  #                                                                                                                                 #   
## If you used the audio data, please cite:                                                                                                                       #
## Burnham, D., Estival, D., Fazio, S., Viethen, J. Cox, J., Dale, R., Cassidy, S., Epps, J., Togneri, R., Wagner, M., Kinoshita, Y.,                             #
##  Gocke, R., Arciuli, J., Onslow. M., Lewis, T., Butcher, A. and Hajek, J., “Building an audio-visual corpus of Australian English:                             # 
##  Large corpus collection with an economical portable and replicable Black Box”, Proc Interspeech, 841–844, 2011.                                               # 
###################################################################################################################################################################

#Define variables
#NOTE: as per MAUS & correctBoundary_addTarget_inSent.Praat script, tier 1 (interval) contains the orthographic transcription of the word, tier 2 (interval) phoneme-level forced-alignment, and tier 3 (point) the targets
vTierNumber = 3

#NOTE: as per correctBoundary_addTarget_inSent.Praat, for every vowel, the first landmark is the start, the second is the target, and the third is the end of the vowel.
startRow = 1
targRow  = 2
endRow = 3

#Reading all files
dir$ = "extracted_sound/"
Create Strings as directory list:  "participantList", dir$
nParticipant = Get number of strings

dirout$ = "/formants/"
createFolder: dirout$

#Create countertable for vowel pairs
counterZero = 1
call counterParticipant

for iParticipant from counterParticipantZero to nParticipant
	select Strings participantList
	participantName$ = Get string: iParticipant 

	Create Strings as file list:  "soundList", dir$ + "/" + participantName$ + "/*.wav"
	Create Strings as file list:  "gridList", dir$ + "/" + participantName$ + "/*.TextGrid"

	# get the number of all files in the Strings object
	nSound = Get number of strings
	nGrid = Get number of strings
	
	#Create countertable for SOUNDS
	call counterSound

	if newparticipant <> 2
		# start a loop from the first to the last entry of the file list
		for iSound from counterZero to nSound
			iRow = iSound
			select Strings soundList
			soundName$ = Get string: iSound 
			sound = Read from file: dir$ + "/" + participantName$ + "/" + soundName$
	
			select Strings gridList
			gridName$ = Get string: iSound 
			textGrid = Read from file: dir$ + "/" + participantName$ + "/" + gridName$
			
			fileName$ = soundName$ - ".wav"
			
			#NOTE: the target word is the last word in the file name, i.e., between the last underscore and the .wav extension
			index1 = rindex(soundName$, "_")
			index2 = index(soundName$, ".")
			targName$ = mid$ (soundName$, index1+1, index2-index1-1)

			#Get  Landmarks and values here 
			select textGrid
			vTier = Extract one tier: vTierNumber
			landmarkTable = Down to Table: "no", 6, "yes", "no"
			
			select vTier
			Remove

			#get previously saved info from counterTable
			select counterTable
			creakyValue =  Get value: iRow, "Creaky"
			commentString$ =  Get value: iRow, "Comment"
			counterValue = Get value: iRow, "Counter"

			#look for previously saved formant data
			settingsTableExists = fileReadable(dirout$ + fileName$ + "_" + "formant_settings.csv")
			formantTableExists = fileReadable(dirout$ + fileName$ +  "_" + "formant.csv")
			formantExists =  fileReadable(dirout$ + "/" + fileName$ +"_original_formant" + ".txt")
				
			#load existing formant data for analysed sound files or estimate formants for new files
			if settingsTableExists == 1 and formantTableExists == 1 and formantExists == 1
				tableSettings = Read Table from comma-separated file: dirout$ + fileName$  + "_" + "formant_settings.csv"
				timeStep = Get value: 1, "TimeStep"
				nFormant = Get value: 1, "NFormant"
				maxFormant = Get value: 1, "MaxFormant"
				windowLength = Get value: 1, "WindowLength"
				preemphFormant = 	Get value: 1, "PreemphFilter"
				
				formant =  Read from file: dirout$ + fileName$ + "_" + "original_formant" + ".txt"
				
				formantTable =  Read Table from comma-separated file: dirout$ + fileName$  + "_" + "formant.csv"
				
			else 
				#load default settings
				tableSettings = Read Table from comma-separated file: dir$ + "defaultFormantSettings.csv"
				timeStep = Get value: 1, "TimeStep"
				nFormant = Get value: 1, "NFormant"
				maxFormant = Get value: 1, "MaxFormant"
				windowLength = Get value: 1, "WindowLength"
				preemphFormant = Get value: 1, "PreemphFilter"

				label REDO
				select landmarkTable
				landmark$ = Get value: targRow, "text"
				landmarkLoc = Get value: targRow, "tmin"
		
				select sound
				shortSound = Extract part: landmarkLoc-windowLength, landmarkLoc+windowLength, "rectangular", 1, "yes"
		
				select shortSound
				duration = Get total duration
				formant = To Formant (burg): 'timeStep', 'nFormant', 'maxFormant', 'windowLength', 'preemphFormant'
				formantTable = Down to Table: "yes", "yes", 6, "yes", 3, "yes", 3, "yes"
				Append column: "Landmark"
				Formula: "Landmark", "landmark$"	
				
				select shortSound
				Remove
			#if old -> load / new -> estimate
			endif
		
			#measure and plot formants 	
			select formantTable 
			nTime = Get number of rows
			for iTime to nTime
				xTime'iTime' = Get value: iTime, "time(s)"
			endfor
			
			select sound
			spec = To Spectrogram: 'timeStep', 5500, 0.002, 20, "Gaussian"
			soundEnd = Get total duration
	
			formantNr = 1	
			doFormantSettings = 1	
			while formantNr
				call paintAndWait
				if formantNr		
					call updateFormant
				endif		
			endwhile
			
			#SAVE Formant Values and Settings table here for individual landmark
	
			if settingsTableExists = 1 or formantTableExists = 1
				beginPause: "You have already saved formant data for  " + fileName$ + ".  Do you want to overwrite it?"
				clicked = endPause: "Yes, I do", "No, keep the previous data", 1
				if clicked = 1
					call saveFormant
				endif
			else
				call saveFormant
			endif

			select sound
			plus textGrid
			plus landmarkTable
			plus spec
			plus tableSettings
			plus formantTable
			Remove
			
			#update countertable for SOUNDS here
			select counterTable
			counterValue = Get value: iRow, "Counter"
			Set numeric value: iRow, "Counter", counterValue+1
			Set numeric value: iRow, "Creaky", creakyValue
			Set string value: iRow, "Comment", commentString$

			Save as comma-separated file: dir$ + participantName$ + "/" + participantName$+"_formant.csv"	
		#for iSound from counterZero to nSound
		endfor
	#if newparticipant <> 2
	endif

	select counterTable
	plus Strings soundList
	select Strings gridList
	Remove
	
	#Update countertable for PARTICIPANTS
	select counterParticipantTable
	counterValue = Get value: iParticipant, "ParticipantCounter"
	Set numeric value: iParticipant, "ParticipantCounter", counterValue+1
	Save as comma-separated file: dir$  + "corrected_participants_formant.csv"
	
#for iParticipant from counterParticipantZero to nParticipant
endfor


pauseScript: "CONGRATULATIONS! You've hand-checked all the formant trajectories!"

###################################################################################################

procedure paintAndWait
#procedure by Titia Benders & Tuende Szalay 

	#NOTE: circleSize defines the size of white circle used as the background for the F1/F2/F3 labels. The required size depends on the size of your screen.
	circleSize = 0.0055
	
	demo Erase all

	select spec
	demo Paint: 0, 0, 0, 0, 100, "yes", 50, 6, 0, "yes"

	demo Blue
	demo Dashed line
	select landmarkTable
	nPoint = Get number of rows
	for iPoint to nPoint
		pointTime = Get value: iPoint, "tmin"
		pointLabel$ = Get value: iPoint, "text"
		demo Draw line: pointTime, 0, pointTime, 5500
		demo Text special: pointTime, "Centre", 4500, "Half", "Times", 20, "90", "'pointLabel$'"
	endfor
	
	#NOTE: You may want to adjust the size of circles for marking time (green) and formant estimates(maroon, red, pink)
	for iTime to nTime
		xTime = xTime'iTime'
		demo Paint circle: "Lime", xTime, 0, 0.001
	endfor

	select formantTable
	demo Maroon

	demo Scatter plot (mark): "time(s)", 0, soundEnd, "F1(Hz)", 0, 5500, 3, "no", "."
	demo Red
	demo Scatter plot (mark): "time(s)", 0, soundEnd, "F2(Hz)", 0, 5500, 3, "no", "."
	demo Pink
	demo Scatter plot (mark): "time(s)", 0, soundEnd, "F3(Hz)", 0, 5500, 3, "no", "." 


	demo Paint circle: "White", 0.05, 5000, circleSize
	demo Magenta
	formantLabel$ = "F" + string$ (formantNr)
	demo Text special: 0.05, "Centre", 5000, "Half", "Times", 20, "0", "'formantLabel$'"

	if doFormantSettings
		counterValue$ = string$ (counterValue) 

		beginPause: "formantSettings"
			comment:  "You have seen the token " + targName$ +  " " +  "'counterValue$'" + " times"
			positive: "timeStep", 'timeStep'
			real: "nFormant", 'nFormant'
			positive: "maxFormant", 'maxFormant'
			positive: "windowLength", 'windowLength'
			positive: "preemphFormant", 'preemphFormant'
			boolean: "creakyValue", 'creakyValue'
			text: "commentString", "'commentString$'"
		clicked = endPause: "Prev." ,"Redo", "Correct formants", 3

		if clicked = 1
			iSound = iSound -2
			if iSound < 0
				iSound = 0
				pauseScript: "You are analysing the first vowel!"
			endif
			doFormantAnalysis = 0
			formantNr = 0
			goto END
		elsif clicked = 2
			if nFormant < 3
				pauseScript: "You must measure at least 3 formants!"
				nFormant = 3 
			endif
			goto REDO
		elsif clicked == 3
			doFormantSettings = 0	
		#if clicked == X
		endif
	#if doFormantSettings = TRUE
	endif
	
	label STAY
	while demoWaitForInput ( )	
		if demoClicked ()
			time = demoX ( )
			fvalue_new = demoY ( )
			goto END
		elsif demoKey$ ( ) = ("1")
			formantNr = 1
			demo Paint circle: "White", 0.05, 5000, circleSize
			demo Magenta
			formantLabel$ = "F" + string$ (formantNr)
			demo Text special: 0.05, "Centre", 5000, "Half", "Times", 20, "0", "'formantLabel$'"
		elsif demoKey$ ( ) = ("2")
			formantNr = 2
			demo Paint circle: "White", 0.05, 5000, circleSize
			demo Magenta
			formantLabel$ = "F" + string$ (formantNr)
			demo Text special: 0.05, "Centre", 5000, "Half", "Times", 20, "0", "'formantLabel$'"
		elsif demoKey$ ( ) = ("3")
			formantNr = 3
			demo Paint circle: "White", 0.05, 5000, circleSize
			demo Magenta
			formantLabel$ = "F" + string$ (formantNr)
			demo Text special: 0.05, "Centre", 5000, "Half", "Times", 20, "0", "'formantLabel$'"
		else
			beginPause:  "Are you done with this token?"
			clicked = endPause: "Keep correcting", "Redo analysis", "Save & next", "Save & update comment",  3
			if clicked = 1
				goto STAY
			elif clicked = 2
				beginPause:  "WARNING: all edits and comments to " + fileName$ + " will be LOST if you redo the analysis"
				clicked = endPause: "Redo analysis", "Stay with the current analysis", 1
				if clicked  = 1
					goto REDO
				elif clicked  = 2
					goto STAY
				endif
			elif clicked = 3
				formantNr = 0
				goto END
			elif clicked = 4
				call updateComment
				formantNr = 0
				goto END
			#if clicked == X
			endif
		#if demoClick or demoKey
		endif
	#while demoWaitForInput ( )
	endwhile

	label END

endproc

###################################################################################################

procedure updateFormant
#procedure by Titia Benders & Tuende Szalay

	selectObject: formantTable
	if fvalue_new > 50
		Set numeric value: 1, "F'formantNr'(Hz)", 'fvalue_new'
	else				
		Set numeric value: 1, "F'formantNr'(Hz)", 0
	endif

endproc

###################################################################################################

procedure saveFormant

	createDirectory: dirout$ 

	#save formant settings
	tableSettingsSave = Create Table with column names: "tableSettings", 1, "FileName TimeStep NFormant MaxFormant WindowLength PreemphFilter"
	Set string value: 1, "FileName", soundName$
	Set numeric value: 1, "TimeStep", 'timeStep'
	Set numeric value: 1, "NFormant", 'nFormant'
	Set numeric value: 1, "MaxFormant", 'maxFormant'
	Set numeric value: 1, "WindowLength", 'windowLength'
	Set numeric value: 1, "PreemphFilter", 'preemphFormant'

	Save as comma-separated file: dirout$ + fileName$ +  "_" + "formant_settings.csv"
	Remove

	#save original formants
	select formant
	Save as text file: dirout$ + "/" + fileName$ +  "_" + "original_formant" + ".txt"

	#Save corrected formants
	select formantTable
	nRow = Get number of rows
	Insert column: 1, "filename"
		for row to nRow
			Set string value: row, "filename", soundName$
		endfor	
	Save as comma-separated file: dirout$ + fileName$ +  "_" + "formant.csv"		

endproc

###################################################################################################

procedure counterSound
#procedure by Titia Benders & Tuende Szalay

	tableexists = fileReadable(dir$ + participantName$ + "/" + participantName$+"_formant.csv")

	if tableexists == 1
		counterTable = Read Table from comma-separated file: dir$ + participantName$ + "/" + participantName$+"_formant.csv"
	elsif tableexists == 0
		counterTable = Create Table with column names: participantName$ + "_formant", nSound, "Soundfile Counter Creaky Comment"
		for iRow to nSound
			select Strings soundList
			#write name of the file into a string variable
			soundFile$ = Get string: iRow
			select counterTable
			Set string value: iRow, "Soundfile", soundFile$
		endfor
		Formula: "Counter", "0"
		Formula: "Creaky", "0"
		Formula: "Comment", """"""
		Save as comma-separated file: dir$ + participantName$ + "/" + participantName$+"_formant.csv"
	endif

	#pause window to possibly change counterZero
	counterZero = Search column: "Counter", "0"
	if counterZero == 0
		counterZero$ = You've finished all soundfiles from Speaker " + participantName$ "."
		beginPause: "Select your speaker"
			comment: counterZero$
		newparticipant = endPause: "Stay at current speaker", "Go to next speaker" , 2
		if newparticipant == 1
			counterZero = nSound
		endif
	else
		counterZero$ = "Start working with Speaker " + participantName$ + " from soundfile No. " + string$ (counterZero)
		newparticipant = 1
	endif

	if newparticipant == 1 
		beginPause: "Select your sound file!"
			comment: counterZero$
			comment: "Where do you want to start from?"
			positive: "counterZero", counterZero
		endPause: "Happy annotating!" , 1

		if counterZero == 1
			pauseScript: "You are about to start participant ", participantName$ 
		elsif counterZero > nSound
			pauseScript: "There are only  ", + string$ (nSound) + " sound files for participant " + participantName$ + ". Select a number below that."
		else
			pauseScript: "You are about to continue participant", participantName$
		endif
	endif
	
endproc

###################################################################################################

procedure counterParticipant
#procedure by Titia Benders & Tuende Szalay

	tableexists = fileReadable(dir$ + "corrected_participants_formant.csv")
	if tableexists == 1
		counterParticipantTable = Read Table from comma-separated file: dir$ + "corrected_participants_formant.csv"
	elsif tableexists == 0
		counterParticipantTable = Create Table with column names: "corrected_participants_formant", nParticipant, "Participant ParticipantCounter"
		for iRow to nParticipant
			select Strings participantList
			participant$ = Get string: iRow
			select counterParticipantTable
			Set string value: iRow, "Participant", participant$
		endfor
		Formula: "ParticipantCounter", "0"
		Save as comma-separated file: dir$  + "corrected_participants_formant.csv"
	endif

	#pause window to possibly change counterParticipantZero
	counterParticipantZero = Search column: "ParticipantCounter", "0"

	counterParticipantZero$ = "Start working with Speaker "  + string$ (counterParticipantZero)

	beginPause: "Select your Participant!"
		comment: counterParticipantZero$
		comment: "Do you want to change to another Speaker?"
		positive: "counterParticipantZero", counterParticipantZero
	endPause: "Happy annotating!" , 1

	if counterParticipantZero > nParticipant
		pauseScript: "There are only  " + string$ (nParticipant) + " participants. Select a number below that."
	endif

endproc

###################################################################################################

procedure updateComment

	beginPause: "Update my comment"
		text: "commentString", "'commentString$'"
	clicked = endPause: "Done", 1

endproc 

###################################################################################################
