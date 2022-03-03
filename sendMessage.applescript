on run {}
	set contacFilePath to selectedImportFile()
	set filePath to getPathMessageFile()
	if checkFileExist(filePath) then
		set message to getContentMessage(filePath)
		showConfirmSendMessage(message, contacFilePath)
	else
		showAlertInputMessage(filePath, contacFilePath)
	end if
end run

on showConfirmSendMessage(message, contacFilePath)
	activate
	set alertMessage to "Are you sure you want to send to the contact with message: 
" & message
	set question to display dialog alertMessage buttons {"Send message", "Cancel", "Edit message"} default button 1
	set answer to button returned of question
	if answer is equal to "Send message" then
		set contacts to readFile(contacFilePath)
		set canSendMessage to validateContacts(contacts)
		if canSendMessage then
			sendMessage(message, contacts)
		else
			display dialog "List is empty"
		end if
	else
		if answer is equal to "Edit message" then
			openFile()
		end if
	end if
end showConfirmSendMessage

on showAlertInputMessage(messagePath, contacFilePath)
	activate
	set message to the text returned of (display dialog "Enter message" default answer "")
	writeMessageToFile(message, messagePath)
	showConfirmSendMessage(message, contacFilePath)
	
end showAlertInputMessage

on writeMessageToFile(message, messagePath)
	try
		set myFile to (open for access messagePath with write permission)
		set eof of myFile to 0
		write message to myFile starting at eof
		close access myFile
	on error
		try
			close access messagePath
		end try
	end try
end writeMessageToFile

on openFile()
	set filePath to getPathMessageFile()
	set Target_Filepath to POSIX file filePath
	tell application "Finder" to open Target_Filepath
end openFile

on validateContacts(contacts)
	set listSize to count of contacts
	if listSize is greater than 1 then
		return true
	else
		return false
	end if
end validateContacts

on selectedImportFile()
	tell application "Finder"
		activate
		set importFile to choose file with prompt "Import file list of phone numbers" of type {"txt"}
		set filePath to (POSIX path of importFile)
		return filePath
	end tell
end selectedImportFile

on readFile(unixPath)
	set srcFile to POSIX file unixPath
	return paragraphs of (read srcFile as Çclass utf8È)
end readFile

on getContentMessage(filePath)
	#set content to (open for access (POSIX file filePath))
	
	set message to (read filePath as Çclass utf8È)
	return message
end getContentMessage

on checkFileExist(filePath)
	tell application "Finder"
		if exists filePath as POSIX file then
			return true
		else
			return false
		end if
	end tell
end checkFileExist

on getPathMessageFile()
	set fileName to "message.txt"
	set currentPath to getCurrentPath()
	set filePath to currentPath & fileName
	return filePath
end getPathMessageFile

on getCurrentPath()
	tell application "Finder"
		set currentPath to (POSIX path of (container of (path to me) as alias))
		return currentPath
	end tell
end getCurrentPath

on sendMessage(message, contacts)
	tell application "Messages"
		repeat with contact in contacts
			if length of contact is greater than 0 then
				set targetService to (1st account whose service type = iMessage)
				set targetBuddy to participant contact of targetService
				send message to targetBuddy
			end if
		end repeat
	end tell
end sendMessage

on sendShowMessage(message, contacts)
	repeat with contact in contacts
		if length of contact is greater than 0 then
			display dialog contact
		end if
	end repeat
end sendShowMessage

