#Extract target words from long sound

#Define directories
sourcedir$ = "long_sound/"
outdir$ = "extracted_sound/"

ortTier = 1
nCond = 2


Create Strings as directory list:  "participantList", sourcedir$
nPart = Get number of strings

for iPart to nPart
	missedTargets = Create Strings from tokens: "tokens", "", " ,"

	#Get partID
	select Strings participantList
	partID$ = Get string: iPart
	
	Create Strings as file list:  "gridList", sourcedir$ + partID$ + "/*.TextGrid"
	nGrid = Get number of strings
	Create Strings as file list:  "soundList", sourcedir$ + partID$ + "/*.wav"
	nSound = Get number of strings
	if nSound > 1 or nGrid > 1
		pauseScript: "There is more than one sound/grid file. Fix it!"
	endif
	
	for iCond to nCond
		if iCond = 1
			targetList = Read Strings from raw text file: "swList.txt"
			condDir$ = "SW_Targets\"
			createFolder: outdir$ + "SW_Targets"
		elsif iCond = 2
			targetList = Read Strings from raw text file: "wsList.txt"
			condDir$ = "WS_Targets\"
			createFolder: outdir$ + "WS_Targets"
		endif
		nTarget = Get number of strings
		
		select Strings soundList
		soundName$ = Get string: 1
		select Strings gridList
		gridName$ = Get string: 1
		
		sound = Read from file: sourcedir$ + partID$ + "/" + soundName$
		grid = Read from file: sourcedir$ + partID$ + "/" + gridName$
		ortGrid = Extract one tier: ortTier
		gridTable = Down to Table: "no", 6, "yes", "no"
		
		for iTarget to nTarget
			select targetList
			iTarget$ = Get string: iTarget

			select gridTable
			targTable = Extract rows where column (text): "text", "is equal to", iTarget$
			nRep = Get number of rows
			
			if nRep > 0
				for iRep to nRep
					select targTable
					start = Get value: iRep, "tmin"
					end = Get value: iRep, "tmax"
				
					select sound
					shortSound = Extract part: start, end, "rectangular", 1.0, "no"
					
					select grid
					shortGrid = Extract part: start, end, "no"
				
					saveName$ = partID$ + "_" + iTarget$ + string$ (iRep)
					select shortSound
					Save as WAV file: outdir$ + "\" + condDir$ + saveName$ + ".wav"
					select shortGrid
					Save as text file: outdir$ + "\" + condDir$ + saveName$ + ".TextGrid"

					select shortSound
					plus shortGrid
					Remove
				
				#for iRep to nRep
				endfor
			else
				select missedTargets
				Insert string: 0, iTarget$
			#if nRep > 0
			endif

		select targTable
		Remove
		#for iTarget to nTarget
		endfor
		

	select targetList
	Remove
	#for iCond to nCond
	endfor
	
	select missedTargets
	nMissed = Get number of strings
	if nMissed > 0
		select missedTargets
		Save as raw text file:  outdir$ + "/" + partID$ + "_missed_targets.txt"
	endif
	select Strings soundList
	plus Strings gridList
	plus sound
	plus grid
	plus ortGrid
	plus gridTable
	Remove
#for iPart to nPart	
endfor	


pauseScript: "Your files are in " + outdir$