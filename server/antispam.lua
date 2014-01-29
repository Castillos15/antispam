class "AntiSpam"

function AntiSpam:__init ( )
	self.kickMessage = "was kicked for spamming." -- The message without the player name shown when kicked.
	self.kickReason = "Avoid spamming the chat." -- The message shown to the player kicked.
	self.messageColor = Color ( 255, 0, 0 ) -- The color of the message shown when kicked.
	self.maxWarnings = 3 -- When it reaches the maximum warnings, the player will be kicked.
	self.messagesResetInterval = 10 -- Defines the time in seconds to reset the anti spam table.
	self.messagesForWarning = 5
	self.warningsResetInterval = 180
	self.steamIDS = -- The steam IDs which will not be punished for spamming.
	{
		[ "YourSteamIDHere" ] = true
	}

	-- Don't touch below this:
	self.messagesSent = { }
	self.playerWarnings = { }
	self.resetTableTick = 0
	self.resetWarningsTick = 0

	Events:Subscribe ( "PlayerChat", self, self.OnChat )
	Events:Subscribe ( "PostTick", self, self.ResetTable )
end

function AntiSpam:OnChat ( args )
	if ( args.text:len ( ) > 0 ) then
		local steamID = args.player:GetSteamId ( ).id
		if ( not self.steamIDS [ steamID ] ) then
			if ( not self.messagesSent [ steamID ] ) then
				self.messagesSent [ steamID ] = 1
			elseif ( self.messagesSent [ steamID ] >= self.messagesForWarning ) then
				local warnings = tonumber ( self.playerWarnings [ steamID ] ) or 0
				if ( warnings < self.maxWarnings ) then
					self.playerWarnings [ steamID ] = ( warnings + 1 )
					args.player:SendChatMessage ( "Anti-Spam: Please refrain from spamming, warnings: ".. tostring ( self.playerWarnings [ steamID ] ) .."/".. tostring ( self.maxWarnings ), Color ( 255, 0, 0 ) )
					self.messagesSent [ steamID ] = 0
				else
					args.player:Kick ( self.kickReason )
					Chat:Broadcast ( tostring ( args.player:GetName ( ) ) .." ".. tostring ( self.kickMessage ), self.messageColor )
					self.messagesSent [ steamID ] = nil
					self.playerWarnings [ steamID ] = nil
				end

				return false
			else
				self.messagesSent [ steamID ] = ( self.messagesSent [ steamID ] + 1 )
			end
		end
	end
end

function AntiSpam:ResetTable ( )
	if ( Server:GetElapsedSeconds ( ) - self.resetTableTick >= self.messagesResetInterval ) then
		self.messagesSent = { }
		self.resetTableTick = Server:GetElapsedSeconds ( )
	end

	if ( Server:GetElapsedSeconds ( ) - self.resetWarningsTick >= self.warningsResetInterval ) then
		self.playerWarnings = { }
		self.resetWarningsTick = Server:GetElapsedSeconds ( )
	end
end

antispam = AntiSpam ( )