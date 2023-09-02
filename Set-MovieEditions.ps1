# This script will set the 'Edition' of movies in a Plex library. It does this by looking for an [Edition] in the stored "file" path of the movie.
# It works for me, as mine are stored with the following format:
# /storage/Films/Movie Name (Year) [Edition]/Movie.Name.Year.Codecs.ext

# It can of course be adapted to suit your needs.

$LibraryName = "Films"

Write-Output "Getting Plex items for $LibraryName"
try
{
	$PlexItems = Get-PlexItem -LibraryTitle $LibraryName
}
catch
{
	throw $_
}


foreach($Item in $PlexItems)
{
	# If there is more than 1 part in $Item.Media.Part then I'm unsure how to proceed so continue to the next item
	if($Item.Media.Part.Count -gt 1)
	{
		Write-Output "$($Item.Title): Skipping because it has $($Item.Media.Part.Count) parts"
		continue
	}
	else
	{
		# If $Item.Media.Part.file (full path to the video) matches [] then we know we're working with
		# an 'edition' of the movie.

		if($Item.Media.Part.file -match "\[.*\]")
		{
			# Parse $Item.Media.Part.file (the full path to the movie) to extract the 'edition'
			$Edition = $Item.Media.Part.file -replace ".*\[", "" -replace "\].*", ""

			if($Null -eq $Item.editionTitle)
			{
				Write-Host "$($Item.Title): No editionTitle set. Setting to: $Edition" -ForegroundColor Red
				Set-PlexItemEdition -Id $Item.ratingKey -Edition $Edition
				Start-Sleep -Seconds 1
			}
			else
			{
				if($Item.editionTitle -ne $Edition)
				{
					Write-Host "$($Item.Title): editionTitle is $($Item.editionTitle) but should be $Edition. Updating." -ForegroundColor Yellow
					Set-PlexItemEdition -Id $Item.ratingKey -Edition $Edition
					Start-Sleep -Seconds 1
				}
				else
				{
					Write-Host "$($Item.Title): editionTitle is $($Item.editionTitle) and is correct" -ForegroundColor Green
				}
			}
		}
		else
		{
			#Write-Output "$($Item.Title): No edition"
		}
	}
}
