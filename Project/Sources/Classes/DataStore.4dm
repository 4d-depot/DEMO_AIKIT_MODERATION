Class extends DataStoreImplementation

exposed Function apiKeyCheck($apiKey : Text) : Boolean
	var $client:=cs:C1710.AIKit.OpenAI.new($apiKey)
	var $moderation:=$client.moderations.create("test").moderation
	If (Type:C295($moderation)=Is undefined:K8:13)
		return False:C215
	End if 
	
	If (Type:C295($moderation)=Is null:K8:31)
		return False:C215
	Else 
		return True:C214
	End if 
	
exposed Function getComments() : cs:C1710.CommentsSelection
	return ds:C1482.Comments.all().orderBy("createdAt asc, time asc")
	
	
exposed Function processComment($forumComment : Text; $apiKey : Text) : cs:C1710.CommentsSelection
	
	var $client:=cs:C1710.AIKit.OpenAI.new($apiKey)
	
	var $moderation:=$client.moderations.create($forumComment).moderation
	
	var $isFlagged : Boolean:=$moderation.results[0].flagged
	
	var $user : cs:C1710.UsersEntity
	$user:=This:C1470.getOrCreateUser()
	
	var $comment:=ds:C1482.Comments.new()
	$comment.createdAt:=Current date:C33
	$comment.time:=Current time:C178
	
	$comment.userID:=$user.ID
	$comment.flaggedObject:=$moderation
	
	If $isFlagged
		$comment.content:="This content has been reviewed and found to be inappropriate or not in compliance with our guidelines. As a result, it has been moderated."
		$comment.flagged:="Inappropriate content"
	Else 
		$comment.content:=$forumComment
		$comment.flagged:="Validated content"
	End if 
	
	$comment.save()
	
	return ds:C1482.Comments.all().orderBy("createdAt asc, time asc")
	
Function getOrCreateUser() : cs:C1710.UsersEntity
	
	$people:=New collection:C1472
	$people.push(New object:C1471("name"; "Marie Durand"; "partner"; "Partners"))
	$people.push(New object:C1471("name"; "Jean Dupont"; "partner"; "4D Staff"))
	$people.push(New object:C1471("name"; "Elise Martin"; "partner"; "Partners"))
	$people.push(New object:C1471("name"; "Luc Moreau"; "partner"; "4D Staff"))
	$people.push(New object:C1471("name"; "Sophie Bernard"; "partner"; "Partners"))
	$people.push(New object:C1471("name"; "Thomas Leroy"; "partner"; "4D Staff"))
	$people.push(New object:C1471("name"; "Claire Petit"; "partner"; "Partners"))
	$people.push(New object:C1471("name"; "Julien Garcia"; "partner"; "4D Staff"))
	$people.push(New object:C1471("name"; "Nora Lefevre"; "partner"; "Partners"))
	$people.push(New object:C1471("name"; "Hugo Marchand"; "partner"; "4D Staff"))
	
	var $randomPerson : Object
	$index:=(Random:C100%$people.length)
	$randomPerson:=$people[$index]
	
	var $user : cs:C1710.UsersEntity
	$user:=ds:C1482.Users.query("name = :1"; $randomPerson.name).first()
	
	If ($user=Null:C1517)
		$user:=ds:C1482.Users.new()
		$user.name:=$randomPerson.name
		$user.partner:=$randomPerson.partner
		
		$nameParts:=Split string:C1554($randomPerson.name; " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
		var $initials : Text
		If ($nameParts.length>=1)
			$initials:=Substring:C12($nameParts[0]; 1; 1)
		End if 
		If ($nameParts.length>=2)
			$initials:=$initials+Substring:C12($nameParts[1]; 1; 1)
		End if 
		$user.initial:=Uppercase:C13($initials)
		
		$user.save()
	End if 
	
	return $user
	