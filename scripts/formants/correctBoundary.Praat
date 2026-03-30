###############################################################################################################################################################
## correctBoundary.Praat                                                                                                                                      #
##                                                                                                                                                            #         
## This script provides an interface for hand-correcting vowel- and rime boundaries placed by the MAUS forced-aligner.                                        #
## The script was specifically written for /hVd/ and /hVl/ words containing the Australian English FLEECE, KIT, GOOSE, FOOT, MOUTH, TRAP, GOAT or LOT vowels. #
## To analyse other target words, define other targets (line 25) and segments (lines 110-151).                                                                #
## The script loads sound files and matching textgrids from the subfolders of the "sound" folder and tracks corrected files.                                  #
##                                                                                                                                                            #
##                                                                                                                                                            #         
## References:                                                                                                                                                #
## Script by Tuende Szalay (contact at tuendeszalay.github.io). counterSound and counterVowelPair procedures by Titia Benders and Tuende Szalay.      		  #
## If you used the script (as-is or modified), cite                    																						  #                                                                                                                                 # 
## Szalay, T., Benders, T., Cox, F. & Proctor, M. (2022). Vowel merger in Australian English lateral-final rimes: /æɔ-æ/.                                     #
##  In Rosey Billington (Ed.) Proceedings of the 18th Australasian International Conference on Speech Science and Technology, (pp. 106-110).                  #
##                                                                                                                                                            #
## Sample data taken from the AusTalk audio corpus of Australian English accessible via https://app.alveo.edu.au/catalog/austalk                              #                                                                                                                                 #   
## If you used the audio data, please cite:                                                                                                                   #
## Burnham, D., Estival, D., Fazio, S., Viethen, J. Cox, J., Dale, R., Cassidy, S., Epps, J., Togneri, R., Wagner, M., Kinoshita, Y.,                         #
##  Gocke, R., Arciuli, J., Onslow. M., Lewis, T., Butcher, A. and Hajek, J., “Building an audio-visual corpus of Australian English:                         # 
##  Large corpus collection with an economical portable and replicable Black Box”, Proc Interspeech, 841–844, 2011.                                           # 
###############################################################################################################################################################


#Define target words and landmarks
#NOTE: if target words are changed, target vowels must be changed too (lines 110-151)
stringOfTargets$ = "heed heel hid hill howd howl had Hal hod holl hode hole whod pool hood pull" 

#NOTE: The landmark names f2s and f2e are shorthand for "start of F2 in target vowel" and "end of F2 in target vowel/rime". Rename the landmarks as appropriate.
landmarkTier = 3
maxLandmarks =  2
stringOfLandmarks$ = "f2s f2e"
listOfLandmarks =  Create Strings as tokens: "f2s,f2e", ","
nCompLandmark = Get number of strings

#Reading all files
dir$ = "sound/"
Create Strings as directory list:  "vowelPairList", dir$
nVowelPair = Get number of strings

#Create countertable for VOWEL PAIRS
counterZero = 1
call counterVowelPair

for iVowelPair from counterVowelPairZero to nVowelPair
	#Get soundfiles in directories
	select Strings vowelPairList
	vowelPairName$ = Get string: iVowelPair 

	Create Strings as file list:  "soundList", dir$ + vowelPairName$ + "/*.wav"
	Create Strings as file list:  "gridList", dir$ + vowelPairName$ + "/*.TextGrid"

	nSound = Get number of strings
	nGrid = Get number of strings

	#Create countertable for SOUNDS
	call counterSound

	if newVowelPair <> 2
		# start a loop from the first to the last entry of the file list
		for iSound from counterZero to nSound		
			#load sound and grid
			iRow = iSound
			
			select counterTable
			counterValue = Get value: iRow, "Counter"
			
			select Strings soundList
			soundName$ = Get string: iSound 
			sound = Read from file: dir$ + "/" + vowelPairName$ + "/" + soundName$

			select Strings gridList
			gridName$ = Get string: iRow 
			textGrid = Read from file: dir$ + "/" + vowelPairName$ + "/" + gridName$

			
			#get previously saved info from counterTable
			select counterTable
			creakyValue =  Get value: iRow, "Creaky"
			excludeValue = Get value: iRow, "Exclude"
			commentString$ =  Get value: iRow, "Comment"
			counterValue = Get value: iRow, "Counter"
			
			#get the right number of tiers
			#NOTE: the sound files were force-algined using MAUS generating ORT and MAU tiers, but no KAN tier
			select textGrid
			textGridName$ = selected$ ("TextGrid", 1 )
			nTier = Get number of tiers

			while counterValue = 0 and nTier <> 2
				plus sound 
				View & Edit
				pauseScript: "Make sure that have exactly 2 tiers: ORT and MAU!"
				select textGrid
				nTier = Get number of tiers
			endwhile
			
			while counterValue > 0  and nTier <> 3
				plus sound 
				View & Edit
				pauseScript: "Make sure that you have exaclty 3 tiers: ORT, MAU, and F2Landmarks!"
				select textGrid
				nTier = Get number of tiers
			endwhile		
			
			#Get values from MAU and copy it to landmark tier
			select textGrid
			gridTable = Down to Table: "no", 6, "yes", "no"	
			ortRow = Search column: "tier", "ORT-MAU"
			target$ = Get value: ortRow, "text"
			
			#NOTE: the order of vowel$ variable is the reverse of the order of targets in line 25.
			#NOTE: to change target word and segment re-define targets in line 25 and segment variables below.
			vowel = index(stringOfTargets$, target$)
			if vowel >= 67
				vowel$ = "ʊ"	
			elsif vowel >= 57
				vowel$ = "ʉː"	
			elsif vowel >= 47
				vowel$ = "əʉ"
			elsif vowel >= 38
				#NOTE: MAUS may transcribe /ɔ/ as */ɒ/
				vowel1$ = "ɔ"
				vowel2$ = "ɒ"
			elsif vowel >= 30
				vowel$ = "æ"
			elsif vowel >= 20
				vowel$ = "æɔ"	
			elsif vowel >= 11
				vowel$ = "ɪ"
			else
				vowel$ = "iː"
			endif		
			
			if vowel < 47 & vowel >= 38
				vowelRow = Search column: "text", vowel1$
					if vowelRow = 0
						vowelRow = Search column: "text", vowel2$
					endif	
			else
				vowelRow = Search column: "text", vowel$	
			endif
			
			#NOTE: the script looks for pre-/d/ vowels and /l/-final rimes. Re-define the variable "end" to look for vowels only.
			start = Get value: vowelRow, "tmin"
			
			#NOTE: the script relies on the spelling of target words (line 25) to identify /d/-final and /l/-final words
			if right$(target$, 1) = "d" or right$(target$, 2) = "de" 
				end = Get value: vowelRow, "tmax"
			elsif right$(target$, 1) = "l" or right$(target$, 2) = "le"
				lRow = Search column: "text", "l"
				end = Get value: lRow, "tmax"
			endif
			
			if nTier = 2	
				select textGrid
				Insert point tier: landmarkTier, "F2Landmarks"
				Insert point: landmarkTier, start, "f2s"
				Insert point: landmarkTier, end, "f2e"
			endif

			select textGrid		
			plus sound
			View & Edit
			editor TextGrid 'textGridName$'
				Zoom... start-0.5 end+0.5
			endeditor
			
			#Add and check landmarks
			call addLandmarks
			
			if excludeValue = 0
				call checkLandmarks
			endif

			#Save edited textgrid & remove from object window
			select textGrid
			Save as text file: dir$ + "/" + vowelPairName$ + "/" + textGridName$ + ".TextGrid"
			select sound
			plus textGrid
			plus gridTable
			Remove
			
			#update countertable for SOUNDS here
			select counterTable
			Set numeric value: iRow, "Counter", counterValue+1
			Set numeric value: iRow, "Creaky", creakyValue
			Set numeric value: iRow, "Exclude", excludeValue
			Set string value: iRow, "Comment", commentString$

			Save as comma-separated file: dir$ + "/" + vowelPairName$ + "/" + vowelPairName$+"_landmark.csv"	
		
		#for iSound from counterZero to nSound
		endfor

	#if newvowelPair <> 2
	endif
	
	select counterTable
	plus Strings soundList
	select Strings gridList
	Remove

	#Update countertable for VOWEL PAIRS
	select counterVowelPairTable
	counterValue = Get value: iVowelPair, "VowelPairCounter"
	Set numeric value: iVowelPair, "VowelPairCounter", counterValue+1
	Save as comma-separated file: dir$ + "/"  + "corrected_vowel_pair_landmark.csv"

#for iVowelPair from counterVowelPairZero to nVowelPair
endfor

pauseScript: "CONGRATULATIONS! You've added all the landmarks!"


####################################################################################################################################

procedure addLandmarks

	counterValue$ = string$ (counterValue) 
	beginPause: "Add landmarks"
		comment: "You have seen this token " + "'counterValue$'" + " times"
		comment: "On the F2LANDMARKS tier, you must have"
		comment: "	f2s = F2 starts in vowel"
		comment: "	f2e = F2 ends in vowel or at the end of /l/"
		boolean: "excludeValue", 'excludeValue'
		boolean: "creakyValue", 'creakyValue'
		text: "commentString", "'commentString$'"

	clicked = endPause:  "Prev. word", "Next word", 2

	#NOTE: for the "Prev." button to work, change the iteration for the variable of the immediate for-loop in which addLandmarks is called. As addLandmarks is called in "for iSound to nSound", change the value of iSound (and not iVowelPair).
	if clicked = 1
		iSound = iSound - 2
		if iSound < 0
			iSound = 0
			pauseScript: "You're analysing the first word. Move to the next!"
		endif
	endif

endproc

##############################################################################################################################

procedure checkLandmarks

	label REDO

	error$ = ""	
	usedLandmarks$ = ""
	absentLandmark$ = "" 

	#Check number of landmarks
	select textGrid
	nLandmarks = Get number of points: landmarkTier

	while nLandmarks <> maxLandmarks
		select sound
		plus textGrid
		View & Edit
		beginPause: "Maximum landmarks" 
			comment: "There should be " + string$ (maxLandmarks) + " landmarks. Fix it!"
			clicked = endPause: "Save", "Update comment & Save", 1
			if clicked = 2
				call updateComment
			endif
			select textGrid 
			nLandmarks = Get number of points: landmarkTier
	endwhile

	#check label of landmarks
	for iTier from landmarkTier to landmarkTier	
		for iLandmark to nLandmarks
			select textGrid
			landmark$ = Get label of point: landmarkTier, iLandmark
			landmarkOnList = index(stringOfLandmarks$, landmark$) 
			if landmarkOnList = 0
				error$ = error$ + landmark$ + tab$
			endif
		#for landmark
		endfor


		if length(error$) > 0
			select sound
			plus textGrid
			View & Edit
			beginPause: "Landmark labels" 
				comment: "The only valid landmark(s) on tier " + string$ (landmarkTier) + " are " + stringOfLandmarks$ + " . Fix " + error$
			clicked = endPause: "Save", "Update comment & Save", 1
			if clicked = 2
				call updateComment
			endif
				iTier = landmarkTier	
		endif
	#for iTier from landmarkTier to landmarkTier		
	endfor

	#warn about missing landmarks
	for iLandmark to maxLandmarks
		select textGrid
		iLandmark$ = Get label of point: landmarkTier, iLandmark
		usedLandmarks$ = usedLandmarks$ + iLandmark$ + tab$
	endfor	


	for iCompLandmark to nCompLandmark
		select listOfLandmarks
		iCompLandmark$ = Get string: iCompLandmark
		compLandmarkOnList = index(usedLandmarks$, iCompLandmark$)
		if compLandmarkOnList = 0
			absentLandmark$ = absentLandmark$ + tab$ + iCompLandmark$
		endif	
	endfor

	if length(absentLandmark$) > 0
		select sound
		plus textGrid
		View & Edit
		
		beginPause: "Absent landmarks"
			comment: "You MUST add the landmarks f2s and f2e before proceeding."
		clicked = endPause: "Save", "Update comment & Save", 1
		if clicked = 2
			call updateComment
		endif
		goto REDO
		
	#if length(absentLandmark$) > 0		
	endif

endproc

##############################################################################################################################

procedure counterSound
#procedure by Titia Benders & Tuende Szalay

	tableexists = fileReadable(dir$ + vowelPairName$ + "/" + vowelPairName$+"_landmark.csv")

	if tableexists == 1
		counterTable = Read Table from comma-separated file: dir$ + vowelPairName$ + "/" + vowelPairName$+"_landmark.csv"	
	elsif tableexists == 0
		counterTable = Create Table with column names: vowelPairName$ + "_landmark", nSound, "Soundfile Counter Creaky Exclude Comment"
		for iRow to nSound
			select Strings soundList
			soundFile$ = Get string: iRow
			select counterTable
			Set string value: iRow, "Soundfile", soundFile$
		endfor
		Formula: "Counter", "0"
		Formula: "Creaky", "0"
		Formula: "Exclude", "0"	
		Formula: "Comment", """"""
		Save as comma-separated file: dir$ +  vowelPairName$ + "/" + vowelPairName$+"_landmark.csv"
	endif

	#pause window to possibly change counterZero
	counterZero = Search column: "Counter", "0"
	if counterZero == 0
		counterZero$ = "You've finished all soundfiles from the vowel pair " + vowelPairName$ + "."
		beginPause: "Select the vowel pair"
			comment: counterZero$
		newVowelPair = endPause: "Stay at current pair", "Go to next pair" , 2
		if newVowelPair == 1
			counterZero = nSound
		endif
	else
		counterZero$ = "Start the vowel pair " + vowelPairName$ + " from soundfile No. " + string$ (counterZero)
		newVowelPair = 1
	endif

	if newVowelPair == 1 
		beginPause: "Select your sound file!"
			comment: counterZero$
			comment: "Where do YOU want to start from?"
			positive: "counterZero", counterZero
		endPause: "Happy annotating!" , 1

		if counterZero == 1
			pauseScript: "You are about to start the vowel pair ", vowelPairName$ 
		elsif counterZero > nSound
			pauseScript: "There are only  ", nSound, " sound files for the pair ", vowelPairName$, ". Select a number below ", nSound
		else
			pauseScript: "You are about to continue the vowel pair ", vowelPairName$
		endif
	endif

endproc

##############################################################################################################################

procedure counterVowelPair
#procedure by Titia Benders & Tuende Szalay

	tableexists = fileReadable(dir$ + "\"  + "corrected_vowel_pair_landmark.csv")

	if tableexists == 1
		counterVowelPairTable = Read Table from comma-separated file: dir$ + "corrected_vowel_pair_landmark.csv"
	elsif tableexists == 0
		counterVowelPairTable = Create Table with column names: "corrected_vowel_pair_landmark", nVowelPair, "VowelPair VowelPairCounter"
		for iRow to nVowelPair
			select Strings vowelPairList
			vowelPair$ = Get string: iRow
			select counterVowelPairTable
			Set string value: iRow, "VowelPair", vowelPair$
		endfor
		Formula: "VowelPairCounter", "0"
		Save as comma-separated file: dir$  + "corrected_vowel_pair_landmark.csv"
	endif

	#pause window to possibly change counterVowelPairZero
	counterVowelPairZero = Search column: "VowelPairCounter", "0"

	counterVowelPairZero$ = "Start working with vowel pair "  + string$ (counterVowelPairZero)

	beginPause: "Select your VowelPair!"
		comment: counterVowelPairZero$
		comment: "Do you want to change to another pair?"
		positive: "counterVowelPairZero", counterVowelPairZero
	endPause: "Happy annotating!" , 1

	if counterVowelPairZero > nVowelPair
		pauseScript: "There are only  ", nVowelPair, " vowel pairs.",  " Select a number below ", nVowelPair
	endif

endproc

##############################################################################################################################

procedure updateComment

	beginPause: "Update my comment"
		text: "commentString", "'commentString$'"
	clicked = endPause: "Done", 1

endproc 
##############################################################################################################################
