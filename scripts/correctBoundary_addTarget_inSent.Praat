﻿###################################################################################################################################################################
## correctBoundary_addTarget_inSent.Praat                                                                                                                         #
##                                                                                                                                                                #         
## This script provides an interface for hand-correcting vowel boundaries placed by the MAUS forced-aligner and adding vowel targets.                             #
## The script identifies multiple target vowels in a sentence.                                                                                                    #
## The script uses two sentences containing the Australian English KIT vowels in three words per sentence.                                                        #
## To analyse other targets, define other words (lines 78-87), vowels (line 146), and landmarks (line 29-30).                                                     #
## The script loads sound files and matching textgrids from the subfolders of the "sound" folder and tracks corrected files.                                      #
##                                                                                                                                                                #
##                                                                                                                                                                #         
## References:                                                                                                                                                    #
## Script by Tuende Szalay (contact at tuendeszalay.github.io), based on correctBoundary.Praat (Szalay & Benders).												  # 
## If you used the script (as-is or modified), cite                                          																	  #                                                                                                                                 # 
## Szalay, T., Nguyen, D. D., Chacon, A. & Madill, C.(2023). Formant change and individual variation in male-to-female transgender speakers during voice therapy. #
##  In J. Acoust. Soc. Am. 1 October 2023; 154 (4_supplement): A336. https://doi.org/10.1121/10.0023719.         			                                      #
##                                                                                                                                                                #
## Sample data taken from the AusTalk audio corpus of Australian English accessible via https://app.alveo.edu.au/catalog/austalk                                  #                                                                                                                                 #   
## If you used the audio data, please cite:                                                                                                                       #
## Burnham, D., Estival, D., Fazio, S., Viethen, J. Cox, J., Dale, R., Cassidy, S., Epps, J., Togneri, R., Wagner, M., Kinoshita, Y.,                             #
##  Gocke, R., Arciuli, J., Onslow. M., Lewis, T., Butcher, A. and Hajek, J., “Building an audio-visual corpus of Australian English:                             # 
##  Large corpus collection with an economical portable and replicable Black Box”, Proc Interspeech, 841–844, 2011.                                               # 
###################################################################################################################################################################

#Define tiers created by MAUS
ortTier = 1
phonTier = 2
landmarkTier = 3

#Define sentence IDs and target words
sent1$ = "002"
sent2$ = "058"
targets1$ = "kid milk spilt"
targets2$ = "chill wind twins"


#NOTE: The landmark names VNs, VNt, and VNe are shorthand for "start of the Nth vowel", "target of the Nth vowel", and "end of the Nth vowel" respectively. Rename the landmarks as appropriate.
stringOfLandmarks$ = "V1s V1t V1e V2s V2t V2e V3s V3t V3e"
listOfLandmarks =  Create Strings as tokens: "V1s,V1t,V1e,V2s,V2t,V2e,V3s,V3t,V3e", ","

#Reading all files
dir$ = "sound/"
Create Strings as directory list:  "participantList", dir$
nParticipant = Get number of strings

#Create countertable for PARTICIPANTS
counterZero = 1
call counterParticipant

for iParticipant from counterParticipantZero to nParticipant
	#Get soundfiles in directories
	select Strings participantList
	participantName$ = Get string: iParticipant

	Create Strings as file list:  "soundList", dir$ + participantName$ + "/*.wav"
	Create Strings as file list:  "gridList", dir$ + participantName$ + "/*.TextGrid"

	nSound = Get number of strings
	nGrid = Get number of strings

	#Create countertable for SOUNDS
	call counterSound
	
	if newParticipant <> 2
		# start a loop from the first to the last entry of the file list
		for iSound from counterZero to nSound
			#load sound and grid
			iRow = iSound
			
			select counterTable
			counterValue = Get value: iRow, "Counter"
			
			select Strings soundList
			soundName$ = Get string: iSound 
			sound = Read from file: dir$ + "/" + participantName$ + "/" + soundName$

			select Strings gridList
			gridName$ = Get string: iRow 
			textGrid = Read from file: dir$ + "/" + participantName$ + "/" + gridName$
			
			#NOTE: in the AusTalk sentence task,the sentence ID is the last three digits before "-ch6-speaker16". Adjust the sentence ID as required	
			#NOTE: sentence-codes and target words can be stored in a separate txt file
			sentName$ = right$(gridName$ - "-ch6-speaker16.TextGrid", 3)
			if sentName$ == sent1$
				stringOfTargets$ = targets1$
				listOfTargets = Read Strings from raw text file: dir$ + "sent1_words.txt"
				nTarget = Get number of strings
			elif sentName$ == sent2$
				stringOfTargets$ = targets2$
				listOfTargets = Read Strings from raw text file: dir$ + "sent2_words.txt"
				nTarget = Get number of strings
			endif
			maxLandmarks = 2*nTarget + nTarget
			nCompLandmark = 2*nTarget + nTarget
			
			#get previously saved info from counterTable
			select counterTable
			creakyValue =  Get value: iRow, "Creaky"
			commentString$ =  Get value: iRow, "Comment"
			counterValue = Get value: iRow, "Counter"
			for iTarget to nTarget
				iTarget$ = string$ (iTarget)	
				exclude'iTarget' = Get value: iRow, "Exclude"+iTarget$
			endfor
			excludeValue = exclude1 + exclude2 + exclude3
			excludeList = Create Strings from tokens: "excludeList", "'exclude1','exclude2','exclude3'", " ,"
			
			#get the right number of tiers
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
				pauseScript: "Make sure that you have exaclty 3 tiers: ORT, MAU, and VLandmarks!"
				select textGrid
				nTier = Get number of tiers
			endwhile		
			
			#Get values from MAU and copy it to landmark tier
			select textGrid
			gridTable = Down to Table: "no", 6, "yes", "no"	
			
			for iTarget to nTarget
				iTarget$ = string$ (iTarget)

				select excludeList
				excludeToken$ = Get string: iTarget
				excludeToken = number (excludeToken$)

				select listOfTargets
				target$ = Get string: iTarget
				
				select gridTable
				targRow = Search column: "text", target$
				
				while targRow == 0
					pauseScript: "Incorrect automatic transcription. Fix the text, save the grid, and restart the script!"
				endwhile

				wordStart = Get value: targRow, "tmin"
				wordEnd = Get value: targRow, "tmax"
				
				#NOTE: to look for a vowel other than AusE KIT, change the the IPA symbol below
				iTable = Extract rows where column (text): "text", "is equal to", "ɪ"
				niRow = Get number of rows
				
				while niRow == 0
					pauseScript: "Incorrect automatic transcription. Fix IPA, save the grid, and restart the script!"
				endwhile
				
				start = 0
				end = 0 

				for iiRow to niRow
					iStart = Get value: iiRow, "tmin"
					iEnd = Get value: iiRow, "tmax"
					if iStart >= wordStart & iEnd <= wordEnd
						start = iStart
						end = iEnd
						mid = start + ((end - start)/2)
					endif	
				endfor	
				
				while start == 0 or end == 0
					pauseScript: "Incorrect word-IPA alignment. Fix grid, save the grid, and restart the script!"
				endwhile
				
				select textGrid
				nTier = Get number of tiers

				#NOTE: nocheck is required for the Prev. word button to work. Alternatively, a countZero procedure can be called for counting Targets
				if nTier = 2	
					select textGrid
					Insert point tier: landmarkTier, "VLandmarks"
					Insert point: landmarkTier, start, "V"+iTarget$+"s"
					Insert point: landmarkTier, end, "V"+iTarget$+"e"
				elif nTier = 3	& counterValue == 0
					nocheck Insert point: landmarkTier, start, "V"+iTarget$+"s"
					nocheck Insert point: landmarkTier, end, "V"+iTarget$+"e"
				endif
				targIndex = Get nearest index from time: landmarkTier, mid
				targTime = Get time of point: landmarkTier, targIndex

				select textGrid		
				plus sound
				View & Edit
				editor TextGrid 'textGridName$'
					Zoom... wordStart wordEnd
					Play... wordStart wordEnd
					Move cursor to... targTime
				endeditor
				
				#Add and check landmarks
				call addLandmarks

				editor TextGrid 'textGridName$'
					Close
				endeditor
				
				select iTable
				Remove
			#for iTarget to nTarget
			endfor

			if excludeValue < nTarget
				call checkLandmarks
			endif
				
			#save new textgrid & remove from object window
			select textGrid
			Save as text file: dir$ + "/" + participantName$ + "/" + textGridName$ + ".TextGrid"

			#update countertable for SOUNDS here
			select counterTable
			Set numeric value: iRow, "Counter", counterValue+1
			Set numeric value: iRow, "Creaky", creakyValue
			for iTarget to nTarget
				select excludeList
				iExclude$ = Get string: iTarget
				iExclude = number (iExclude$)
				colExclude$ = string$ (iTarget)
				select counterTable
				Set numeric value: iRow, "Exclude"+colExclude$, iExclude 
			endfor
			Set string value: iRow, "Comment", commentString$
			Save as comma-separated file: dir$ + "/" + participantName$ + "/" + participantName$+"_landmark.csv"	
			
			select sound
			plus textGrid
			plus listOfTargets
			plus gridTable
			plus Strings excludeList
			Remove
			
		#for iSound from counterZero to nSound
		endfor

	#if newParticipant <> 2
	endif

	#Update countertable for PARTICIPANT
	select Strings soundList
	plus Strings gridList
	plus counterTable
	Remove

	select counterParticipantTable
	counterValue = Get value: iParticipant, "ParticipantCounter"
	Set numeric value: iParticipant, "ParticipantCounter", counterValue+1
	Save as comma-separated file: dir$  + "corrected_participant_landmark.csv"

#iParticipant from counterParticipantZero to nParticipant
endfor

pauseScript: "CONGRATULATIONS! You've added all the landmarks!"


####################################################################################################################################

procedure addLandmarks

	counterValue$ = string$ (counterValue) 
	beginPause: "Add landmarks"
		comment: "The target word is " + target$
		comment: "You have seen this sound file " + "'counterValue$'" + " times"
		
		comment: "On the VLandmarks tier, you must have"
		comment: "	VXs: the vowel starts"
		comment: "	VXe: the vowel ends"
		comment: "	VXt = vowel target (monophthong)"
		boolean: "creakyValue", 'creakyValue'
		boolean: "excludeToken", 'excludeToken'
		text: "commentString", "'commentString$'"
	clicked = endPause:  "Prev. word", "Save & next", 2

	#NOTE: for the "Prev." button to work, change the iteration for the variable of the immediate for-loop in which addLandmarks is called. As if addLandmarks is called in the for iTarget to nTarget loop, change the value of iTarget (and not iSound or iParticipant).
	if clicked = 1
		iTarget = iTarget - 2
		if iTarget < 0
			iTarget = 0
			pauseScript: "You are analysing the first word."
		endif
	else
		excludeValue = excludeValue + excludeToken 
		select excludeList
		Set string: iTarget, string$ (excludeToken)
	endif

endproc

#############################################################################################################################

procedure checkLandmarks

	label REDO

	error$ = ""	
	usedLandmarks$ = ""
	absentLandmark$ = "" 

	#Check number of landmarks
	select textGrid
	nLandmarks = Get number of points: landmarkTier
	totalExclude = 0
	for iTarget to nTarget
		select excludeList
		iExclude$ = Get string: iTarget
		iExclude = number (iExclude$)
		totalExclude = totalExclude + iExclude
	endfor

	while nLandmarks + 3*totalExclude <> maxLandmarks
		select sound
		plus textGrid
		View & Edit
		beginPause: "Maximum landmarks" 
			comment: "There should be " + string$ (maxLandmarks - 3*totalExclude) + " landmarks. Fix it!"
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
		#for iLandmark to nLandmarks
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
		#if length(error$) > 0
		endif
	
	#for iTier from landmarkTier to landmarkTier		
	endfor

	#warn about missing landmarks
	for iLandmark to nLandmarks
		select textGrid
		iLandmark$ = Get label of point: landmarkTier, iLandmark
		usedLandmarks$ = usedLandmarks$ + iLandmark$ + tab$
	endfor	

	for iCompLandmark to nCompLandmark
		select listOfLandmarks
		iCompLandmark$ = Get string: iCompLandmark
		compLandmarkOnList = index(usedLandmarks$, iCompLandmark$)
		
		select excludeList
		iExclude$ = Get string: ceiling( iCompLandmark/3 )
		if compLandmarkOnList == 0 and iExclude$ == "0"
			absentLandmark$ = absentLandmark$ + tab$ + iCompLandmark$
		endif	
	endfor

	if length(absentLandmark$) > 0
		select sound
		plus textGrid
		View & Edit
		
		beginPause: "Absent landmarks"
			comment: "You MUST add the landmarks " + absentLandmark$ + " before proceeding."
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

	tableexists = fileReadable(dir$ + participantName$ + "/" + participantName$+"_landmark.csv")

	if tableexists = 1
		counterTable = Read Table from comma-separated file: dir$ + participantName$ + "/" + participantName$+"_landmark.csv"	
	elsif tableexists = 0
		counterTable = Create Table with column names: participantName$ + "_landmark", nSound, "Soundfile Counter Creaky Exclude1 Exclude2 Exclude3 Comment"
		for iRow to nSound
			select Strings soundList
			soundFile$ = Get string: iRow
			select counterTable
			Set string value: iRow, "Soundfile", soundFile$
		endfor
		Formula: "Counter", "0"
		Formula: "Creaky", "0"
		Formula: "Exclude1", "0"
		Formula: "Exclude2", "0"	
		Formula: "Exclude3", "0"
		Formula: "Comment", """"""
		Save as comma-separated file: dir$ +  participantName$ + "/" + participantName$+"_landmark.csv"
	#if tableexists = 1	
	endif

	#pause window to possibly change counterZero
	counterZero = Search column: "Counter", "0"

	if counterZero = 0
		counterZero$ = "You've finished all soundfiles from participant " + participantName$ + "."
		beginPause: "Select your participant"
			comment: counterZero$
		newParticipant = endPause: "Stay at current participant", "Go to next participant" , 2
		if newParticipant = 1
			counterZero = nSound
		endif
	else
		counterZero$ = "Annotate the participant " + participantName$ + " from soundfile No. " + string$ (counterZero)
		newParticipant = 1
	endif

	if newParticipant = 1 
		beginPause: "Select your sound file!"
			comment: counterZero$
			comment: "Where do YOU want to start from?"
			positive: "counterZero", counterZero
		endPause: "Happy annotating!" , 1

		if counterZero = 1
			pauseScript: "You are about to start the participant ", participantName$ 
		elsif counterZero > nSound
			pauseScript: "There are only  ", nSound, " sound files for participant ", participantName$, ". Select a number below ", nSound
		else
			pauseScript: "You are about to continue the participant ", participantName$
		endif
	endif

endproc

##############################################################################################################################

procedure counterParticipant
#procedure by Titia Benders & Tuende Szalay

	tableexists = fileReadable(dir$ + "\"  + "corrected_participant_landmark.csv")

	if tableexists == 1
		counterParticipantTable = Read Table from comma-separated file: dir$ + "corrected_participant_landmark.csv"
	elsif tableexists == 0
		counterParticipantTable = Create Table with column names: "corrected_participant_landmark", nParticipant, "Participant ParticipantCounter"
		for iRow to nParticipant
			select Strings participantList
			participantName$ = Get string: iRow
			select counterParticipantTable
			Set string value: iRow, "Participant", participantName$
		endfor
		Formula: "ParticipantCounter", "0"
		Save as comma-separated file: dir$  + "corrected_participant_landmark.csv"
	endif

	#pause window to possibly change counterParticipantZero
	counterParticipantZero = Search column: "ParticipantCounter", "0"

	counterParticipantZero$ = "Start working with participant "  + string$ (counterParticipantZero)

	beginPause: "Select your participant!"
		comment: counterParticipantZero$
		comment: "Do you want to change to another participant?"
		positive: "counterParticipantZero", counterParticipantZero
	endPause: "Happy annotating!" , 1

	if counterParticipantZero > nParticipant
		pauseScript: "There are only  ", nParticipant, " participants.",  " Select a number below ", nParticipant
	endif

endproc

##############################################################################################################################

procedure updateComment

	beginPause: "Update my comment"
		text: "commentString", "'commentString$'"
	clicked = endPause: "Done", 1

endproc 
##############################################################################################################################
