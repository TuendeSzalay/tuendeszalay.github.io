###############################################################################################################################################################
## formantTrajectory.Praat                                                                                                                                    #
##                                                                                                                                                            #
## REQUIRES PRAAT 6.3.17 OR ABOVE                                                                                                                             #
##                                                                                                                                                            #       
## This script provides an interface for hand-correcting F1, F2, and F3 trajectories between pre-defined boundaries created using the correctBoundary.Praat   #
## As per correctBoundary.Praat, the boundaries are located on tier 3 (point tier) and are named as f2s and f2e, shorthand for "start of F2" and "end of F2". #
## To use different boundary names edit correctBoundary.Praat and the current script (lines 84-85).                                                           #
## The script loads sound files and matching textgrids from the subfolders of the "sound" folder and tracks corrected files.                                  #
##                                                                                                                                                            #
##                                                                                                                                                            #         
## References:                                                                                                                                                #
## Script by Tuende Szalay (contact at tuendeszalay.github.io). 																							  #
## counterSound, counterVowelPair, paintAndWait, and updateFormant procedures by Titia Benders and Tuende Szalay.											  #
## If you used the script (as-is or modified) cite                     																						  # 
## Szalay, T., Benders, T., Cox, F. & Proctor, M. (2022). Vowel merger in Australian English lateral-final rimes: /æɔ-æ/.                                     #
##  In Rosey Billington (Ed.) Proceedings of the 18th Australasian International Conference on Speech Science and Technology, (pp. 106-110).                  #
##                                                                                                                                                            #
## Sample data taken from the AusTalk audio corpus of Australian English accessible via https://app.alveo.edu.au/catalog/austalk                              #
## If you used the audio data, please cite:                                                                                                                   #
## Burnham, D., Estival, D., Fazio, S., Viethen, J. Cox, J., Dale, R., Cassidy, S., Epps, J., Togneri, R., Wagner, M., Kinoshita, Y.,                         #
##  Gocke, R., Arciuli, J., Onslow. M., Lewis, T., Butcher, A. and Hajek, J., “Building an audio-visual corpus of Australian English:                         # 
##  Large corpus collection with an economical portable and replicable Black Box”, Proc Interspeech, 841–844, 2011.                                           # 
###############################################################################################################################################################


#Define variables
#NOTE: as per MAUS & correctBoundary.Praat script, tier 1 (interval) contains the orthographic transcription of the word, tier 2 (interval) phoneme-level forced-alignment, and tier 3 (point) the boundaries
ortTier = 1
lTier = 3
 
#Reading all files
dir$ = "sound/"
Create Strings as directory list:  "vowelPairList", dir$
nVowelPair = Get number of strings

dirout$ = "/formants/"
createFolder: dirout$

#Create countertable for vowel pairs
counterZero = 1
call counterVowelPair

for iVowelPair from counterVowelPairZero to nVowelPair
	select Strings vowelPairList
	vowelPairName$ = Get string: iVowelPair 

	Create Strings as file list:  "soundList", dir$ + vowelPairName$ + "/*.wav"
	Create Strings as file list:  "gridList", dir$ + vowelPairName$ + "/*.TextGrid"

	# get the number of all files in the Strings object
	nSound = Get number of strings
	nGrid = Get number of strings
	
	#Create countertable for SOUNDS
	call counterSound

	if newVowelPair <> 2
		# start a loop from the first to the last entry of the file list
		for iSound from counterZero to nSound
			iRow = iSound
			
			select counterTable
			counterValue = Get value: iRow, "Counter"
		
			select Strings soundList
			soundName$ = Get string: iSound 
			sound = Read from file: dir$ + vowelPairName$ + "/" + soundName$
	
			select Strings gridList
			gridName$ = Get string: iSound 
			textGrid = Read from file: dir$ + vowelPairName$ + "/" + gridName$
			
			fileName$ = soundName$ - ".wav"
			
			#look for previously saved formant data
			settingsTableExists = fileReadable(dirout$ + fileName$ + "_" + "formant_settings.csv")
			formantTableExists = fileReadable(dirout$ + fileName$ + "_" + "formant.csv")
			formantExists =  fileReadable(dirout$ + "/" + fileName$ +"_original_formant" + ".txt")

			#get previously saved info from counterTable
			select counterTable
			creakyValue =  Get value: iRow, "Creaky"
			commentString$ =  Get value: iRow, "Comment"
			counterValue = Get value: iRow, "Counter"

			#shorten sound
			#NOTE: if using different boundary names, search the "text" column for different names
			select textGrid
			gridTable = Down to Table: "no", 6, "yes", "no"
			rowF2S = Search column: "text", "f2s"
			rowF2E = Search column: "text", "f2e"
			rowOrt = Search column: "tier", "ORT-MAU"
			f2sLoc = Get value: rowF2S, "tmin"	
			f2eLoc = Get value: rowF2E, "tmin"
			ort$ = Get value: rowOrt, "text"
		
			select sound
			shortSound = Extract part:  f2sLoc-0.02,  f2eLoc+0.02, "rectangular", 1, "yes"	
			shortSoundStart = f2sLoc-0.02
			
			#load existing formant data for analysed sound files or estimate formants for new files
			if settingsTableExists =1 and formantTableExists = 1 and formantExists = 1
				tableSettings = Read Table from comma-separated file: dirout$ + fileName$ + "_" + "formant_settings.csv"
				timeStep = Get value: 1, "TimeStep"
				nFormant = Get value: 1, "NFormant"
				maxFormant = Get value: 1, "MaxFormant"
				windowLength = Get value: 1, "WindowLength"
				preemphFormant = 	Get value: 1, "PreemphFilter"
		
				formant =  Read from file: dirout$ + fileName$ + "_" + "original_formant" + ".txt"
				
				formantTable =  Read Table from comma-separated file: dirout$ + fileName$ + "_" + "formant.csv"
				
			else 
				#load default settings
				tableSettings = Read Table from comma-separated file: dir$ + "defaultFormantSettings.csv"
				timeStep = Get value: 1, "TimeStep"
				nFormant = Get value: 1, "NFormant"
				maxFormant = Get value: 1, "MaxFormant"
				windowLength = Get value: 1, "WindowLength"
				preemphFormant = Get value: 1, "PreemphFilter"
				
				label REDO
				select shortSound
				duration = Get total duration
				formant = To Formant (burg): 'timeStep', 'nFormant', 'maxFormant', 'windowLength', 'preemphFormant'
		
				formantTableMax = Down to Table: "yes", "yes", 6, "yes", 3, "yes", 3, "yes"
				formantTableMin = Extract rows where column (number): "time(s)", "greater than or equal to", f2sLoc
				formantTable = Extract rows where column (number): "time(s)", "less than or equal to", f2eLoc-0.03

				select formantTableMax
				plus formantTableMin
				Remove
			
			#if old -> load / new -> estimate
			endif

			select formantTable
			nTime = Get number of rows
			for iTime to nTime
				xTime'iTime' = Get value: iTime, "time(s)"
			endfor
			
			select shortSound
			spec = To Spectrogram: 'timeStep', 5500, 0.002, 20, "Gaussian"
			
			formantNr = 1	
			doFormantSettings = 1	
			while formantNr
				call paintAndWait 
				if formantNr		
					call updateFormant
				endif		
			endwhile

			#Save formant values and settings table here for current sound
		
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
			plus gridTable
			plus shortSound
			plus spec
			plus formant
			plus tableSettings
			plus formantTable
			Remove
			
			#update countertable for SOUNDS here
			select counterTable
			Set numeric value: iRow, "Counter", counterValue+1
			Set numeric value: iRow, "Creaky", creakyValue
			Set string value: iRow, "Comment", commentString$

			Save as comma-separated file: dir$ + vowelPairName$ + "/" + vowelPairName$+"_formant.csv"	
			
		#for iSound from counterZero to nSound
		endfor
	#if newVowelPair <> 2
	endif
	
	select counterTable
	plus Strings soundList
	select Strings gridList
	Remove
	
	#Update countertable for VOWEL PAIR
	select counterVowelPairTable
	counterValue = Get value: iVowelPair, "VowelPairCounter"
	Set numeric value: iVowelPair, "VowelPairCounter", counterValue+1
	Save as comma-separated file: dir$  + "corrected_vowelpairs_formant.csv"
	
#for iVowelPair from counterVowelPairZero to nVowelPair
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
	select textGrid
	nPoint = Get number of points: lTier
	for point to nPoint
		pointTime = Get time of point: lTier, 'point'
		pointLabel$ = Get label of point: lTier, 'point'
		demo Draw line: pointTime, 0, pointTime, 5500
		demo Text special: pointTime, "Centre", 4500, "Half", "Times", 20, "90", "'pointLabel$'"
	endfor
	
	#NOTE: You may want to adjust the size of circles for marking time (green) and formant estimates(maroon, red, pink)
	for iTime to nTime
		xTime = xTime'iTime'
		demo Paint circle: "Lime", xTime, 0, 0.002
	endfor

	select formantTable
	demo Maroon
	demo Scatter plot (mark): "time(s)", shortSoundStart, f2eLoc, "F1(Hz)", 0, 5500, 3, "no", "." 
	demo Red
	demo Scatter plot (mark): "time(s)", shortSoundStart, f2eLoc, "F2(Hz)", 0, 5500, 3, "no", "." 
	demo Pink
	demo Scatter plot (mark): "time(s)", shortSoundStart, f2eLoc, "F3(Hz)", 0, 5500, 3, "no", "." 

	demo Paint circle: "White", shortSoundStart+0.01, 5000, circleSize
	demo Magenta
	formantLabel$ = "F" + string$ (formantNr)
	demo Text special: shortSoundStart+0.01, "Centre", 5000, "Half", "Times", 20, "0", "'formantLabel$'"

	if doFormantSettings
		counterValue$ = string$ (counterValue) 

		beginPause: "formantSettings"
			comment:  "You have seen this token of " + ort$ +  " " +  "'counterValue$'" + " times"
			positive: "timeStep", 'timeStep'
			real: "nFormant", 'nFormant'
			positive: "maxFormant", 'maxFormant'
			positive: "windowLength", 'windowLength'
			positive: "preemphFormant", 'preemphFormant'
			boolean: "creakyValue", 'creakyValue'
			text: "commentString", "'commentString$'"
		clicked = endPause: "Prev." ,"Redo", "Correct formants", 3

		if clicked == 1
			iSound = iSound -2
			if iSound < 0
				iSound = 0
				pauseScript: "You're analysing the first word!"
			endif
			doFormantAnalysis = 0
			formantNr = 0
			goto END
		elsif clicked == 2
			if nFormant < 3
				pauseScript: "You must measure at least 3 formants!"
				nFormant = 3 
			endif
			select formant
			plus formantTable
			plus spec
			Remove
			goto REDO
		elsif clicked == 3
			doFormantSettings = 0		
		#if clicked
		endif
	#if doFormantSettings = TRUE
	endif
	
	while demoWaitForInput ( )
		if demoClicked ()
			time = demoX ( )
			fvalue_new = demoY ( )
			goto END
		elsif demoKey$ ( ) = ("1")
			formantNr = 1
			demo Paint circle: "White", shortSoundStart+0.01, 5000, circleSize
			demo Magenta
			formantLabel$ = "F" + string$ (formantNr)
			demo Text special: shortSoundStart+0.01, "Centre", 5000, "Half", "Times", 20, "0", "'formantLabel$'"
		elsif demoKey$ ( ) = ("2")
			formantNr = 2
			demo Paint circle: "White", shortSoundStart+0.01, 5000, circleSize
			demo Magenta
			formantLabel$ = "F" + string$ (formantNr)
			demo Text special: shortSoundStart+0.01, "Centre", 5000, "Half", "Times", 20, "0", "'formantLabel$'"
		elsif demoKey$ ( ) = ("3")
			formantNr = 3
			demo Paint circle: "White", shortSoundStart+0.01, 5000, circleSize
			demo Magenta
			formantLabel$ = "F" + string$ (formantNr)
			demo Text special: shortSoundStart+0.01, "Centre", 5000, "Half", "Times", 20, "0", "'formantLabel$'"
		else
			beginPause:  "Are you done with this token?"
			#NOTE: the "Keep correcting" function requires Praat v6.3.17 or above	
			clicked = endPause: "Keep correcting", "Redo analysis", "Save & next", "Save & update comment",  3
			if clicked == 1
				#do nothing
			elif clicked == 2
				beginPause:  "WARNING: all edits and comments to " + fileName$ + " will be LOST if you redo the analysis"
				clicked = endPause: "Redo analysis", "Stay with the current analysis", 1
				if clicked  = 1
					select formant
					plus formantTable
					plus spec
					Remove
					goto REDO
				elif clicked  = 2
					#do nothing
				endif
			elif clicked == 3
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
	firstTime = Get value: 1, "time(s)"
	row = round( (time - firstTime)/timeStep)+1

	nRow = Get number of rows
	if 0 < row & row <= nRow
		if fvalue_new > 50
			Set numeric value: 'row', "F'formantNr'(Hz)", 'fvalue_new'
		else
			Set numeric value: 'row', "F'formantNr'(Hz)", 0
		endif
	endif

endproc

###################################################################################################

procedure saveFormant

	createDirectory: dirout$ 

	#save formant settings
	tableSettings = Create Table with column names: "tableSettings", 1, "FileName TimeStep NFormant MaxFormant WindowLength PreemphFilter"
	Set string value: 1, "FileName", soundName$
	Set numeric value: 1, "TimeStep", 'timeStep'
	Set numeric value: 1, "NFormant", 'nFormant'
	Set numeric value: 1, "MaxFormant", 'maxFormant'
	Set numeric value: 1, "WindowLength", 'windowLength'
	Set numeric value: 1, "PreemphFilter", 'preemphFormant'

	Save as comma-separated file: dirout$ + fileName$ + "_" + "formant_settings.csv"

	#save original formants
	select formant
	Save as text file: dirout$ + "/" + fileName$ +"_original_formant" + ".txt"

	#Save corrected formants
	select formantTable
	nRow = Get number of rows
	Insert column: 1, "filename"
		for row to nRow
			Set string value: row, "filename", soundName$
		endfor	
	Save as comma-separated file: dirout$ + fileName$ + "_" + "formant.csv"		

endproc

###################################################################################################

procedure counterSound
#procedure by Titia Benders & Tuende Szalay

	tableexists = fileReadable(dir$ + vowelPairName$ + "/" + vowelPairName$+"_formant.csv")

	if tableexists == 1
		counterTable = Read Table from comma-separated file: dir$ + vowelPairName$ + "/" + vowelPairName$+"_formant.csv"
	elsif tableexists == 0
		counterTable = Create Table with column names: vowelPairName$ + "_formant", nSound, "Soundfile Counter Creaky Comment"
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
		Save as comma-separated file: dir$ + vowelPairName$ + "/" + vowelPairName$+"_formant.csv"
	endif

	#pause window to possibly change counterZero
	counterZero = Search column: "Counter", "0"
	if counterZero == 0
		counterZero$ = "You've finished all soundfiles from the pair " + vowelPairName$ + "."
		beginPause: "Select your vowel pair"
			comment: counterZero$
		newVowelPair = endPause: "Stay at current pair", "Go to next pair" , 2
		if newVowelPair == 1
			counterZero = nSound
		endif
	else
		counterZero$ = "Start working with the pair " + vowelPairName$ + " from soundfile No. " + string$ (counterZero)
		newVowelPair = 1
	endif

	if newVowelPair == 1 
		beginPause: "Select your sound file!"
			comment: counterZero$
			comment: "Where do you want to start from?"
			positive: "counterZero", counterZero
		endPause: "Happy annotating!" , 1

		if counterZero == 1
			pauseScript: "You are about to start vowel pair ", vowelPairName$ 
		elsif counterZero > nSound
			pauseScript: "There are only  " + string$ (nSound) + " sound files for vowel pair " + vowelPairName$ + ". Select a number below that."
		else
			pauseScript: "You are about to continue vowel pair ", vowelPairName$
		endif
	endif
	
endproc

###################################################################################################

procedure counterVowelPair
#procedure by Titia Benders & Tuende Szalay

	tableexists = fileReadable(dir$ + "corrected_vowelpairs_formant.csv")
	if tableexists == 1
		counterVowelPairTable = Read Table from comma-separated file: dir$ + "corrected_vowelpairs_formant.csv"
	elsif tableexists == 0
		counterVowelPairTable = Create Table with column names: "corrected_vowelpairs_formant", nVowelPair, "VowelPair VowelPairCounter"
		for iRow to nVowelPair
			select Strings vowelPairList
			vowelPair$ = Get string: iRow
			select counterVowelPairTable
			Set string value: iRow, "VowelPair", vowelPair$
		endfor
		Formula: "VowelPairCounter", "0"
		Save as comma-separated file: dir$  + "corrected_vowelpairs_formant.csv"
	endif

	#pause window to possibly change counterVowelPairZero
	counterVowelPairZero = Search column: "VowelPairCounter", "0"

	counterVowelPairZero$ = "Start working with vowel pair "  + string$ (counterVowelPairZero)

	beginPause: "Select your VowelPair!"
		comment: counterVowelPairZero$
		comment: "Where do you want to start from?"
		positive: "counterVowelPairZero", counterVowelPairZero
	endPause: "Happy annotating!" , 1

	if counterVowelPairZero > nVowelPair
		pauseScript: "There are only  ", nVowelPair, " vowel pairs ",  ". Select a number below ", nVowelPair
	endif

endproc

###################################################################################################

procedure updateComment

	beginPause: "Update my comment"
		text: "commentString", "'commentString$'"
	clicked = endPause: "Done", 1

endproc 
###################################################################################################

