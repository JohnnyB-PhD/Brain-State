%PETHs
%PETHs
%!!!CHANGE the path of the files you need to analyze!!!
filestoanalyze= "C:\Users\jbroussard5\Desktop\NOVELLOCATION\Parking\F\*.nex5"
numfiles=GetFileCount(filestoanalyze)

for iterations = 1 to numfiles
	name = GetFileName(iterations)
	doc=OpenDocument(name)
	Trace(name)
    
    SelectAllNeurons(doc)
    ApplyTemplate(doc,"LIA_PETH_Z")
%SendResultsSummaryToExcel(doc,"C:\Users\jbroussard5\Desktop\NOVELLOCATION\Summary", "LIA", 1, "CellNameStuff",1,1)

end