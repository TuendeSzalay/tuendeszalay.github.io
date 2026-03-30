###################################################################################################################################################################
## extractVowel.Praat                                                                                                                                             #
##                                                                                                                                                                #         
## This script automatically extracts multiple target vowels from a longer recording (a sentence).     															  #
## Vowel boundaries were identified by MAUS and hand-corrected using the correctBoundary_addTarget_inSent.Praat script.                                           #                                                                                           #
## The script uses two sentences containing the Australian English KIT vowels in three words per sentence.                                                        #
## To analyse other targets, define other words in the text file (lines 31-32).                                                                                   #
## The script loads sound files and matching textgrids from the subfolders of the "sound" folder and saves extracted vowels in the extracted_sound folder.        #
##                                                                                                                                                                #
##                                                                                                                                                                #         
## References:                                                                                                                                                    #
## Script written by Tuende Szalay (contact at tuendeszalay.github.io). If you used the script (as-is or modified), cite                                          #                                                                                                                                 # 
## Szalay, T., Nguyen, D. D., Chacon, A. & Madill, C.(2023). Formant change and individual variation in male-to-female transgender speakers during voice therapy. #
##  In J. Acoust. Soc. Am. 1 October 2023; 154 (4_supplement): A336. https://doi.org/10.1121/10.0023719.         			                                      #
##                                                                                                                                                                #
## Sample data taken from the AusTalk audio corpus of Australian English accessible via https://app.alveo.edu.au/catalog/austalk                                  #                                                                                                                                 #   
## If you used the audio data, please cite:                                                                                                                       #
## Burnham, D., Estival, D., Fazio, S., Viethen, J. Cox, J., Dale, R., Cassidy, S., Epps, J., Togneri, R., Wagner, M., Kinoshita, Y.,                             #
##  Gocke, R., Arciuli, J., Onslow. M., Lewis, T., Butcher, A. and Hajek, J., “Building an audio-visual corpus of Australian English:                             # 
##  Large corpus collection with an economical portable and replicable Black Box”, Proc Interspeech, 841–844, 2011.                                               # 
###################################################################################################################################################################

#Define directories
sourcedir$ = "sound/"
outdir$ = "extracted_sound/"

#Define sentence IDs and target words
#NOTE: in AusTalk, the numbers "002" and "058" identify the sentence in the filename.
sent1$ = "002"
sent2$ = "058"
word1List = Read Strings from raw text file: sourcedir$ + "sent1_words.txt"
word2List = Read Strings from raw text file: sourcedir$ + "sent2_words.txt"
#NOTE: in this dataset, the two sentences contain the same number of target words
noWord = Get number of strings

Create Strings as directory list:  "participantList", sourcedir$
nPart = Get number of strings

for iPart to nPart
	#Get partID
	select Strings participantList
	partID$ = Get string: iPart
	
	#Get csv created by correctBoundary_addTarget_inSent.Praat
	tableExists = fileReadable(sourcedir$ + partID$ + "/" + partID$ + "_landmark.csv")
	
	if tableExists == 1
		annotationTable = Read Table from comma-separated file: sourcedir$ + partID$ + "\" + partID$ + "_landmark.csv"
		nSent = Get number of rows
		nCol = Get number of columns
		#NOTE: correctBoundary_addTarget_inSent.Praat creates a tracker file with 7 columns for each participant
		if nCol == 7
			for iExt to noWord
				Append column: "Extracted"+string$(iExt)
				Formula: "Extracted"+string$(iExt), "0"
			endfor
		elif nCol == 10
			for iExt to noWord
				Formula: "Extracted"+string$(iExt), "0"
			endfor	
		endif

		for iSent to nSent
			#Get filename and load sound & grid
			select annotationTable
			soundName$ = Get value: iSent, "Soundfile" 
			gridName$ = soundName$ - "wav" + "TextGrid"
			saveName$ = soundName$ - ".wav"
			sent$ = right$(soundName$ - "-ch6-speaker16.wav", 3)

			sound = Read from file: sourcedir$ + partID$ + "\" + soundName$
			grid = Read from file: sourcedir$ + partID$ + "\" + gridName$
			vGrid = Extract one tier: 3	
			
			#Data validation
			gridTable = Down to Table: "no", 6, "yes", "no"

			for iWord to noWord
				if sent$ == sent1$
					select word1List
				elif sent$ == sent2$
					select word2List
				endif
				word$ = Get string: iWord
				
				select annotationTable
				excludeValue = Get value: iSent, "Exclude"+string$(iWord) 
				
				if excludeValue == 0
					select gridTable
					wordTable = Extract rows where column (text): "text", "contains", string$ (iWord)
					nLandmark = Get number of rows
				
					if nLandmark > 3
						pauseScript: "More than 1 reps of Word " + word$
					elif nLandmark < 3 and excludeValue == 0
						pauseScript: "Landmarks for " word$ + " are missing"
					elif nLandmark == 3 and excludeValue == 0
						select wordTable
						tmin = Get value: 1, "tmin"
						tmax = Get value: 3, "tmax"
					
						select sound
						shortSound = Extract part: tmin-0.05, tmax+0.05, "rectangular", 1.0, "no"
						select grid
						shortGrid = Extract part: tmin-0.05, tmax+0.05, "no"
						
						createFolder: outdir$ + partID$
						select shortSound
						Save as WAV file: outdir$ + partID$ + "\" + saveName$ + "_" + word$ + ".wav"
						select shortGrid
						Save as text file: outdir$ + partID$ + "\" + saveName$ + "_" + word$ + ".TextGrid"
						
						select annotationTable
						Set numeric value: iSent, "Extracted"+string$(iWord), 1
						Save as comma-separated file: sourcedir$ + partID$ + "\" + partID$ + "_sentence_annotation.csv"
					#if nLandmark == X
					endif
					
					select wordTable
					plus shortSound
					plus shortGrid
					Remove
					
				#if excludeValue == 0	
				endif
			#for iWord to noWord
			endfor
			
			select sound
			plus grid
			plus vGrid
			plus gridTable
			Remove
		#for iSent to nSent	
		endfor
	
	select annotationTable
	Remove
	#if tableExists == 1	
	endif
	
#for iPart to nPart	
endfor

pauseScript: "Your files are in " + outdir$
