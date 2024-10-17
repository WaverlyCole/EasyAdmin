return function(Context)
	local Commands = {}
	
	local PlayersService = game:GetService("Players")
	
	Commands.Commands = {
		{
			Name = "credits";
			Aliases = {};
			Rank = 0;
			Category = "System";
			Args = {};
			Run = function(runningPlr,Args)
				local Credits = {}
				
				Credits["WaverlyCole"] = {"Creator of EasyAdmin"}
				
				for i,v in Commands.Commands do
					if v.Creator then
						if Credits[v.Creator] then
							table.insert(Credits[v.Creator],`{v.Name} Command`)
						else
							Credits[v.Creator] = {`{v.Name} Command`}
						end
					end
				end
				
				Context.Comm:SendTo(runningPlr,"DisplayTable",{Name = "Credits",Content = Credits})
			end;
		},
		{
			Name = "doll";
			Aliases = {"playerdoll"};
			Rank = 1;
			Category = "Character";
			Tags = {"Fun"},
			Args = {
				{
					Name = "UserId";
					Display = "UserId/Player";
					Type = "userid";
					Default = 1,
				},
			};
			Run = function(runningPlr,Args)
				local runningChar = Context.PlayerUtils:ResolveToCharacter(runningPlr)
				local username = Context.PlayerUtils:UserIdToName(Args.UserId)
				local armPart = runningChar:FindFirstChild("RightHand") or runningChar:FindFirstChild("Right Arm") or runningChar:FindFirstChild("Head")
				local success, characterModel = pcall(function()
					return PlayersService:CreateHumanoidModelFromUserId(Args.UserId)
				end)
			
				if not success then
					warn(characterModel)
					return nil
				end

				characterModel.Name = username

				Context.PlayerUtils:ScaleCharacter(characterModel,.4)
			
				local dollTool = Instance.new("Tool")
				dollTool.Name = "Doll"
			
				local handle = Instance.new("Part")
				handle.Size = Vector3.new(1, 1, 1)
				handle.Transparency = 1
				handle.CanCollide = false
				handle.Name = "Handle"
				handle.Parent = dollTool

				characterModel:PivotTo(armPart.CFrame)
				handle.CFrame = armPart.CFrame
			
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = handle
				weld.Part1 = characterModel.PrimaryPart
				weld.Parent = handle
			
				characterModel.Parent = dollTool

				for _, descendant in pairs(characterModel:GetDescendants()) do
					if descendant:IsA("Script") or descendant:IsA("LocalScript") then
						descendant:Destroy()
					end

					if descendant:IsA("BasePart") then
						descendant.Massless = true
						descendant.CanCollide = false
					end
				end

				dollTool.Parent = runningPlr.Backpack
			end;
		},
		{
			Name = "charsize";
			Aliases = {"playersize","size","scale"};
			Rank = 0;
			Category = "Character";
			Tags = {"Fun"},
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "Size";
					Display = "Size";
					Type = "number";
					Default = 1,
				},
			};
			Run = function(runningPlr,Args)
				for _,Plr in Args.Targets do
					local Char = Plr.Character

					if Char then
						Context.PlayerUtils:ScaleCharacter(Char,Args.Size,true)
					end
				end
			end;
		},
		{
			Name = "commandinfo";
			Aliases = {"cmdinfo","cmdhelp"};
			Rank = 1;
			Category = "System";
			Args = {
				{
					Name = "CommandSearch";
					Display = "Command";
					Type = "string";
				},
			};
			Run = function(runningPlr,Args)
				local tbl = {}
				local selectedCommand = nil

				for i,Command in Commands.Commands do
					if Command.Name:lower():find(Args.CommandSearch) then
						selectedCommand = Command
						break
					end
				end
				
				local stringifyArgs = function(tbl)
					local result = ""

					for _,v in tbl do
						result = result.." [".. (v.Display or v.Name or "None").."]"
					end

					return result
				end
				
				if selectedCommand then
					local textRank = Context.Options.RankLookup[selectedCommand.Rank]
					
					local tbl = {
						"Name: "..selectedCommand.Name,
						"Rank: "..(textRank or selectedCommand.Rank),
						"Category: "..selectedCommand.Category or "Misc",
						"Aliases: "..table.concat(selectedCommand.Aliases,", "),
						"Arguments: "..stringifyArgs(selectedCommand.Args)
					}
					
					Context.Comm:SendTo(runningPlr,"DisplayTable",{Name = "Command Info: "..selectedCommand.Name,Content = tbl})
				else
					Context.Comm:SendTo(runningPlr,"Notify",{Text = `No command matching "{Args.CommandSearch}" was found.`,Time = 5})
				end
			end;
		},
		{
			Name = "commands";
			Aliases = {"cmds","listcmds","listcommands"};
			Rank = 1;
			Category = "System";
			Args = {};
			Run = function(runningPlr,Args)
				local tbl = {}
				
				local stringifyArgs = function(tbl)
					local result = ""

					for _,v in tbl do
						result = result.." [".. (v.Display or v.Name or "None").."]"
					end

					return result
				end
				
				for i,Command in Commands:Get() do
					if not tbl[Command.Category] then
						tbl[Command.Category] = {}
					end

					table.insert(tbl[Command.Category],{Text = Context.Options.Prefix.. Command.Name .. stringifyArgs(Command.Args),Command = `cmdinfo {Command.Name}`})
				end
				
				Context.Comm:SendTo(runningPlr,"DisplayTable",{Name = "Command List",Content = tbl})
			end;
		},
		{
			Name = "listplayers";
			Aliases = {"lplayers","players","plrs"};
			Rank = 1;
			Category = "Util";
			Args = {};
			Run = function(runningPlr,Args)
				local function buildPlayersTable()
					local tbl = {}

					for i,Plr in PlayersService:GetPlayers() do
						local plrInfo = {}
						table.insert(plrInfo,`<i>Player Info</i>`)

						local loadedRank = Context.Ranks:Get(Plr)
						local textRank = Context.Options.RankLookup[loadedRank]

						table.insert(plrInfo,`Rank: {textRank or loadedRank}`)
						local formattedAge = Context.Util:formatTime(Plr.AccountAge * 86400,{"years","days"},true)
						table.insert(plrInfo,`Age: {formattedAge}`)

						table.insert(plrInfo,`<i>Commands</i>`)

						table.insert(plrInfo,{["Text"] = "Teleport To",["Command"] = `to {Plr.Name}`})
						table.insert(plrInfo,{["Text"] = "Teleport Here",["Command"] = `bring {Plr.Name}`})
						table.insert(plrInfo,{["Text"] = "View Tools",["Command"] = `viewtools {Plr.Name}`})
						table.insert(plrInfo,{["Text"] = "Respawn",["Command"] = `respawn {Plr.Name}`})

						tbl[`{Plr.Name}({Plr.UserId})`] = plrInfo
					end
					
					Context.Comm:SendTo(runningPlr,"DisplayTable",{Name = "Players",Content = tbl})
				end

				buildPlayersTable()
				
				local plrJoining = PlayersService.PlayerAdded:Connect(function(Plr)
					buildPlayersTable()
					Context.Comm:SendTo(runningPlr,"Notify",{Text = `{Plr.Name} joined the server.`,From = `Players`,Time = 10})
				end)
				local plrLeaving = PlayersService.PlayerRemoving:Connect(function(Plr)
					buildPlayersTable()
					Context.Comm:SendTo(runningPlr,"Notify",{Text = `{Plr.Name} left the server.`,From = `Players`,Time = 10})
				end)
				
				local containerConn;containerConn = Context.Comm:Hook("ClosedContainer",function(Plr,Name)
					if Name == "Players" then
						plrJoining:Disconnect()
						plrLeaving:Disconnect()
						containerConn:Disconnect()
					end
				end)
			end;
		},
		{
			Name = "viewtools";
			Aliases = {"seetools"};
			Rank = 1;
			Category = "Util";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				local function showTools(Player)
					local Tools = {}
					for _,v in pairs(Player.Backpack:GetChildren()) do
						if v:IsA("Tool") then
							table.insert(Tools, v.Name)
						end
					end
					
					local Char = Context.PlayerUtils:ResolveToCharacter(Player)
					if Char then
						local equippedTool = Char:FindFirstChildWhichIsA("BackpackItem")
						if equippedTool then
							table.insert(Tools,`[EQUIPPED] {equippedTool.Name}`)
						end
					end

					
					Context.Comm:SendTo(runningPlr,"DisplayTable",{Name = `{Player.Name}'s Tools`, Content = Tools})
				end
				
				for _,Player in Args.Targets do
					showTools(Player)
					
					local backpackAdded = Player.Backpack.ChildAdded:Connect(function()
						showTools(Player)
					end)
					
					local backpackRemoved = Player.Backpack.ChildRemoved:Connect(function()
						showTools(Player)
					end)
					
					local containerConn;containerConn = Context.Comm:Hook("ClosedContainer",function(Plr,Name)
						if Name == `{Player.Name}'s Tools` then
							backpackAdded:Disconnect()
							backpackRemoved:Disconnect()
							containerConn:Disconnect()
						end
					end)
				end
			end;
		},
		{
			Name = "showguis";
			Aliases = {};
			Rank = 1;
			Category = "Moderation";
			Args = {
				{
					Name = "Target";
					Display = "Player(s)";
					Type = "player";
				},
			};
			Run = function(runningPlr,Args)
				Context.Comm:SendTo(runningPlr,"Notify",{Text = `{Args.Target.Name}'s GUIs will be shown shortly.`,Time = 5})
				local uiData = Context.Comm:Invoke(Args.Target,"SerializeGuis")
				
				if uiData then
					Context.Comm:SendTo(runningPlr,"DeserializeGuis",uiData)
					Context.Comm:SendTo(runningPlr,"Notify",{Text = `Showing {Args.Target.Name}'s GUIs`,Time = 5})
				else
					Context.Comm:SendTo(runningPlr,"Notify",{Text = `Encountered an error tyring to serialize GUIs.`,Time = 5})
				end
			end;
		},
		{
			Name = "removehats";
			Aliases = {"nohats","clearhats"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Humanoid = Context.PlayerUtils:getHumanoid(Player)
					
					if Humanoid then
						local humanoidDesc = Humanoid:GetAppliedDescription()
						local DescsToRemove = {"BackAccessory","HatAccessory","HairAccessory","FaceAccessory","ShouldersAccessory","FrontAccessory","NeckAccessory","WaistAccessory"}
						for _, prop in DescsToRemove do
							humanoidDesc[prop] = ""
						end
						Humanoid:ApplyDescription(humanoidDesc, Enum.AssetTypeVerification.Always)
					end
				end
			end;
		},
		{
			Name = "removelayeredclothing";
			Aliases = {"nolayered","clearlayered"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Humanoid = Context.PlayerUtils:getHumanoid(Player)

					if Humanoid then
						local humanoidDesc = Humanoid:GetAppliedDescription()
						local accessoryBlob = humanoidDesc:GetAccessories()

						for i,v in accessoryBlob do
							if v.IsLayered then
								table.remove(accessoryBlob,i)
							end
						end

						humanoidDesc:SetAccessories(accessoryBlob, false)
						Humanoid:ApplyDescription(humanoidDesc, Enum.AssetTypeVerification.Always)
					end
				end
			end;
		},
		{
			Name = "removeaccessories";
			Aliases = {"noaccessories","clearaccessories"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Humanoid = Context.PlayerUtils:getHumanoid(Player)

					if Humanoid then
						Humanoid:RemoveAccessories()
					end
				end
			end;
		},
		{
			Name = "getping";
			Aliases = {"ping"};
			Rank = 1;
			Category = "Util";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					Context.Comm:SendTo(runningPlr,"Notify",{Text = `{Player.Name}'s Ping is {Player:GetNetworkPing() * 1000}ms`,Time = 10})
				end
			end;
		},
		{
			Name = "confirm";
			Aliases = {};
			Rank = 1;
			Category = "Util";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "Message";
					Display = "Message";
					Type = "string";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					task.spawn(function()
						local msg = Context.Text:FilterFor(Args.Message,runningPlr.UserId,Player.UserId)
						local response = Context.Comm:Invoke(Player,"Confirmation",{From = runningPlr.Name,Text = msg,Time = 15})
						
						if response == true then
							Context.Comm:SendTo(runningPlr,"Notify",{Text = `{Player.Name}' confirmed!`,Time = 10})
						elseif response == false then
							Context.Comm:SendTo(runningPlr,"Notify",{Text = `{Player.Name}' denied!`,Time = 10})
						elseif response == nil then
							Context.Comm:SendTo(runningPlr,"Notify",{Text = `{Player.Name}' did not respond!`,Time = 10})
						end
					end)
				end
			end;
		},
		{
			Name = "jump";
			Aliases = {};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Hum = Context.PlayerUtils:getHumanoid(Player)
					
					if Hum then
						Hum.Jump = true
					end
				end
			end;
		},
		{
			Name = "sit";
			Aliases = {};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Hum = Context.PlayerUtils:getHumanoid(Player)
					
					if Hum then
						Hum.Sit = true
					end
				end
			end;
		},
		{
			Name = "forcefield";
			Aliases = {"ff"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Char = Context.PlayerUtils:ResolveToCharacter(Player)
										
					local ff = Instance.new("ForceField")
					ff.Parent = Char
				end
			end;
		},
		{
			Name = "unforcefield";
			Aliases = {"unff"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Char = Context.PlayerUtils:ResolveToCharacter(Player)
					
					for i,v in Char:GetDescendants() do
						if v:IsA("ForceField") then
							v:Destroy()
						end
					end
				end
			end;
		},
		{
			Name = "kill";
			Aliases = {"unalive"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Humanoid = Context.PlayerUtils:getHumanoid(Player)

					Humanoid.Parent:BreakJoints()
				end
			end;
		},
		{
			Name = "heal";
			Aliases = {"mend"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Humanoid = Context.PlayerUtils:getHumanoid(Player)

					Humanoid.Health = Humanoid.MaxHealth
				end
			end;
		},
		{
			Name = "damage";
			Aliases = {"hurt"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "Damage";
					Display = "Damage";
					Type = "number";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Humanoid = Context.PlayerUtils:getHumanoid(Player)

					Humanoid:TakeDamage(Args.Damage)
				end
			end;
		},
		{
			Name = "kick";
			Aliases = {"byebye"};
			Rank = 2;
			Category = "Moderation";
			Args = {
				{
					Name = "Target";
					Display = "Player(s)";
					Type = "player";
				},
				{
					Name = "Reason";
					Display = "Reason";
					Type = "string";
				},
			};
			Run = function(runningPlr,Args)
				local runningRank = Context.Ranks:Get(runningPlr)
				local theirRank = Context.Ranks:Get(Args.Target)
				
				if runningRank >= theirRank then
					local kickMsg = Context.Text:FilterFor(Args.Reason,runningPlr.UserId,Args.Target.UserId)
					local response = Context.Comm:Invoke(runningPlr,"Confirmation",{Text = `Are you sure you want to kick "{Args.Target.Name}" for "{kickMsg}"?`,Time = 15})
					
					if response == true then
						Args.Target:Kick(`Kicked by {runningPlr.Name} for "{kickMsg}"`)
						Context.Comm:SendTo(runningPlr,"Notify",{Text = `Kicked {Args.Target.Name} for "{kickMsg}"`,Time = 10})
					end
				else
					Context.Comm:SendTo(runningPlr,"Notify",{Text = `Cannot kick players that are a higher rank than you.`,Time = 10})
				end
			end;
		},
		{
			Name = "permrank";
			Aliases = {};
			Rank = 3;
			Category = "Moderation";
			Args = {
				{
					Name = "UserId";
					Display = "Name/UserId";
					Type = "userid";
				},
				{
					Name = "Rank";
					Display = "Rank";
					Type = "int";
				},
			};
			Run = function(runningPlr,Args)
				local runningRank = Context.Ranks:calculateRank(runningPlr)
				local theirRank = Context.Ranks:calculateRank(Args.UserId)

				if runningRank > theirRank then
					if Args.Rank < runningRank then
						if Context.Data:saveRank(Args.UserId,Args.Rank) then
							local newRank = Context.Ranks:calculateRank(Args.UserId)
							
							Context.Comm:SendTo(runningPlr,"Notify",{Text = `Set {Context.PlayerUtils:UserIdToName(Args.UserId)}({Args.UserId})'s rank to {Args.Rank}`,Time = 10})
						end
					else
						Context.Comm:SendTo(runningPlr,"Notify",{Text = `Cannot set rank equal to or higher than your own.`,Time = 10})
					end
				else
					Context.Comm:SendTo(runningPlr,"Notify",{Text = `The target player is a higher or equal rank.`,Time = 10})
				end
			end;
		},
		{
			Name = "ban";
			Aliases = {};
			Rank = 3;
			Category = "Moderation";
			Args = {
				{
					Name = "UserId";
					Display = "Name/UserId";
					Type = "userid";
				},
				{
					Name = "Time";
					Display = "Time";
					Type = "time";
				},
				{
					Name = "Reason";
					Display = "Reason";
					Type = "string";
				},
			};
			Run = function(runningPlr,Args)
				local runningRank = Context.Ranks:Get(runningPlr)
				local theirRank = Context.Ranks:Get(Args.UserId)
				
				local timeString = Context.Util:formatTime(Args.Time)

				if runningRank > theirRank then
					local username = Context.PlayerUtils:UserIdToName(Args.UserId)
					
					local banConfig = {
						UserIds = {Args.UserId},
						Duration = Args.Time,
						DisplayReason = Args.Reason,
						PrivateReason = "Put anything here that the user should not know but is helpful for your records",
						ExcludeAltAccounts = false,
						ApplyToUniverse = true
					}
					
					local response = Context.Comm:Invoke(runningPlr,"Confirmation",{From = "Bans",Text = `Are you sure you want to ban "{username}" for {Context.Util:formatTime(Args.Time)} for {Args.Reason}?`,Time = 15})
					
					if response == true then
						local succ,result = pcall(function()
							return PlayersService:BanAsync(banConfig)
						end)

						if succ then

							Context.Comm:SendTo(runningPlr,"Notify",{From = "Bans",Text = `Banned {username}({Args.UserId}) for {timeString} for {Args.Reason}`})
						else
							Context.Comm:SendTo(runningPlr,"Notify",{From = "Bans",Text = `An error occured trying to ban {Args.UserId}`,Time = 10})
							Context.warn(result)
						end
					else
						Context.Comm:SendTo(runningPlr,"Notify",{From = "Bans",Text = `Ban cancelled.`,Time = 10})
					end
				else
					Context.Comm:SendTo(runningPlr,"Notify",{From = "Bans",Text = `Cannot Ban players that are a higher or same rank as you.`,Time = 10})
				end
			end;
		},
		{
			Name = "sudo";
			Aliases = {"runas"};
			Rank = 3;
			Category = "Util";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "Command";
					Display = "Command";
					Type = "string";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local runningRank = Context.Ranks:Get(runningPlr)
					local theirRank = Context.Ranks:Get(Player)
					
					if runningRank > theirRank then
						Context.Commands:runCommand(Player, Args.Command)
					else
						Context.Comm:SendTo(runningPlr,"Notify",{Text = `Cannot sudo players that are a higher or same rank as you.`,Time = 10})
					end
				end
			end;
		},
		{
			Name = "banhistory";
			Aliases = {};
			Rank = 2;
			Category = "Moderation";
			Args = {
				{
					Name = "UserId";
					Display = "Name/UserId";
					Type = "userid";
				},
			};
			Run = function(runningPlr,Args)
				local succ,result = pcall(function()
					return PlayersService:GetBanHistoryAsync(Args.UserId)
				end)
				
				if succ then
					local function pagesToTable(pages)
						local resultTable = {}
						local currentPage = pages:GetCurrentPage()

						while true do
							for _, item in ipairs(currentPage) do
								table.insert(resultTable, item)
							end

							if pages.IsFinished then
								break
							end

							pages:AdvanceToNextPageAsync()
							currentPage = pages:GetCurrentPage()
						end

						return resultTable
					end
					
					local banHistory = pagesToTable(result)
					local displayResults = {}
					
					for _,v in banHistory do
						displayResults[`{v.Ban and "Ban" or "Unban"} {v.StartTime}`] = {
							`Reason: {v.DisplayReason}`,
							`{v.Ban and "Duration" or "Remaining Duration:"}: {Context.Util:formatTime(v.Duration)}`
						}
					end
					
					Context.Comm:SendTo(runningPlr,"DisplayTable",{Name = `Ban history: {Context.PlayerUtils:UserIdToName(Args.UserId)}`,Content = displayResults,Refresh = `banhistory {Args.UserId}`})
				else
					Context.Comm:SendTo(runningPlr,"Notify",{From = "Bans",Text = `An error occured trying to get ban history for {Context.PlayerUtils:UserIdToName(Args.UserId)}({Args.UserId})`,Time = 10})
					Context.warn(result)
				end
			end;
		},
		{
			Name = "unban";
			Aliases = {};
			Rank = 3;
			Category = "Moderation";
			Args = {
				{
					Name = "UserId";
					Display = "Name/UserId";
					Type = "userid";
				},
			};
			Run = function(runningPlr,Args)
				local timeString = Context.Util:formatTime(Args.Time)

				local unbanConfig = {
					UserIds = {Args.UserId},
					ApplyToUniverse = true
				}
				
				local username = Context.PlayerUtils:UserIdToName(Args.UserId)
				
				Context.Commands:runCommand(runningPlr,`banhistory {Args.UserId}`)
				local response = Context.Comm:Invoke(runningPlr,"Confirmation",{From = "Bans",Text = `Are you sure you want to unban "{username}"?`,Time = 15})
				
				if response == true then
					local succ,result = pcall(function()
						return PlayersService:UnbanAsync(unbanConfig)
					end)

					if succ then
						Context.Comm:SendTo(runningPlr,"Notify",{From = "Bans",Text = `Unbanned {username}({Args.UserId}).`})
					else
						Context.Comm:SendTo(runningPlr,"Notify",{From = "Bans",Text = `An error occured trying to unban {Context.PlayerUtils:UserIdToName(Args.UserId)}({Args.UserId})`,Time = 10})
						Context.warn(result)
					end
				else
					Context.Comm:SendTo(runningPlr,"Notify",{From = "Bans",Text = `Unban cancelled.`,Time = 10})
				end
			end;
		},
		{
			Name = "inspectavatar";
			Aliases = {"viewavatar"};
			Rank = 0;
			Category = "Character";
			Args = {
				{
					Name = "UserId";
					Display = "Name/UserId";
					Type = "userid";
				},
			};
			Run = function(runningPlr,Args)
				Context.Comm:SendTo(runningPlr,"ViewAvatar",Args.UserId)
			end;
		},
		{
			Name = "respawn";
			Aliases = {};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					Player:LoadCharacter()
				end
			end;
		},
		{
			Name = "getrank";
			Aliases = {"viewrank","rank"};
			Rank = 0;
			Category = "System";
			Args = {
				{
					Name = "UserId";
					Display = "Name/UserId";
					Type = "userid";
				},
			};
			Run = function(runningPlr,Args)
				local loadedRank = Context.Ranks:Get(Args.UserId)
				local textRank = Context.Options.RankLookup[loadedRank]
				
				local username = Context.PlayerUtils:UserIdToName(Args.UserId)
				
				Context.Comm:SendTo(runningPlr,"Notify",{Text = `{username}({Args.UserId}) is rank {textRank or loadedRank} `,Time = 10})
			end;
		},
		{
			Name = "reloadcharacter";
			Aliases = {"reload","re"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local HRP = Context.PlayerUtils:getHRP(Player)
					
					if HRP then
						local cf = HRP.CFrame
						Player:LoadCharacter()
						local HRP = Context.PlayerUtils:getHRP(Player)
						HRP.CFrame = cf
					else
						Player:LoadCharacter()
					end
				end
			end;
		},
		{
			Name = "teleport";
			Aliases = {"tp"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets1";
					Display = "First Player(s)";
					Type = "players";
				},
				{
					Name = "Targets2";
					Display = "Second Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player1 in Args.Targets1 do
					for _,Player2 in Args.Targets2 do
						local HRP = Context.PlayerUtils:getHRP(Player2)
						
						Context.PlayerUtils:Teleport(Player1,HRP.CFrame)
					end
				end
			end;
		},
		{
			Name = "tie";
			Aliases = {"rope","leash"};
			Rank = 1;
			Category = "Character";
			Tags = {"Fun"},
			Args = {
				{
					Name = "Targets1";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "Targets2";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "Length";
					Display = "Length";
					Type = "number";
					Default = 5,
				},
			};
			Run = function(runningPlr,Args)
				for _,Player1 in Args.Targets1 do
					local HRP1 = Context.PlayerUtils:getHRP(Player1)
					for _,Player2 in Args.Targets2 do
						local HRP2 = Context.PlayerUtils:getHRP(Player2)

						local Attachment1 = Context.new("Attachment", {
							Parent = HRP1
						})
						local Attachment2 = Context.new("Attachment", {
							Parent = HRP2
						})
						
						local Rope = Context.new("RopeConstraint", {
							Visible = true,
							Parent = HRP1,
							Length = Args.Length,
							Attachment0 = Attachment1,
							Attachment1 = Attachment2
						})
					end
				end
			end;
		},
		{
			Name = "noobify";
			Aliases = {"makenoob"};
			Rank = 1;
			Category = "Character";
			Tags = {"Fun"},
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				local properties = {
					HeadColor = BrickColor.new("Bright yellow").Color,
					LeftArmColor = BrickColor.new("Bright yellow").Color,
					RightArmColor = BrickColor.new("Bright yellow").Color,
					LeftLegColor = BrickColor.new("Br. yellowish green").Color,
					RightLegColor = BrickColor.new("Br. yellowish green").Color,
					TorsoColor = BrickColor.new("Bright blue").Color,
					Pants = 0, Shirt = 0, LeftArm = 0, RightArm = 0,
					LeftLeg = 0, RightLeg = 0, Torso = 0
				}
				
				for _,Player in Args.Targets do
					local Humanoid = Context.PlayerUtils:getHumanoid(Player)
					
					if Humanoid then
						Context.Commands:runCommand(runningPlr,`removeaccessories {Player.Name}`)
						
						local description = Humanoid:GetAppliedDescription()

						for k, v in properties do
							description[k] = v
						end

						task.defer(Humanoid.ApplyDescription, Humanoid, description, Enum.AssetTypeVerification.Always)
					end
				end
			end;
		},
		{
			Name = "to";
			Aliases = {"tpto"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local HRP = Context.PlayerUtils:getHRP(Player)

					Context.PlayerUtils:Teleport(runningPlr,HRP.CFrame)
				end
			end;
		},
		{
			Name = "bring";
			Aliases = {"tphere"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				local HRP = Context.PlayerUtils:getHRP(runningPlr)
				for _,Player in Args.Targets do
					Context.PlayerUtils:Teleport(Player,HRP.CFrame)
				end
			end;
		},
		{
			Name = "displayname";
			Aliases = {"setname","setdisplayname"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "NewName";
					Display = "Name";
					Type = "string";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Humanoid = Context.PlayerUtils:getHumanoid(Player)
					if Humanoid then
						Humanoid.DisplayName = Args.NewName
						Context.Comm:SendTo(runningPlr,"Notify",{Text = `Set {Player.Name}'s display name to "{Args.NewName}"`,Time = 10})
						Context.Comm:SendTo(Player,"Notify",{Text = `{runningPlr.Name} set your display name to "{Args.NewName}"`,Time = 10}) --we need to let them know since they cant see themselves
					end
				end
			end;
		},
		{
			Name = "setappearance";
			Aliases = {"loadappearance","loaddescription","stealapp","disguise","setapp"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "UserId";
					Display = "Name/UserId";
					Type = "userid";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Humanoid = Context.PlayerUtils:getHumanoid(Player)
					local desc = game.Players:GetHumanoidDescriptionFromUserId(Args.UserId)
					
					if Humanoid and desc then
						Humanoid:ApplyDescription(desc)
						Context.Comm:SendTo(runningPlr,"Notify",{Text = `Set {Player.Name}'s appearance to "{Args.UserId}"`,Time = 10})
					end
				end
			end;
		},
		{
			Name = "jumppower";
			Aliases = {"jp","jumpheight","jh"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "Height";
					Type = "int";
					Default = 16;
				}
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Humanoid = Context.PlayerUtils:getHumanoid(Player)

					if Humanoid then
						pcall(function()
							Humanoid.JumpPower = Args.Height
							Humanoid.JumpHeight = Args.Height
						end)
					end
				end
			end;
		},
		{
			Name = "walkspeed";
			Aliases = {"speed","ws"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "Speed";
					Type = "int";
					Default = 16;
				}
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					local Humanoid = Context.PlayerUtils:getHumanoid(Player)

					if Humanoid then
						Humanoid.WalkSpeed = Args.Speed
					end
				end
			end;
		},
		{
			Name = "transparency";
			Aliases = {"trans"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "Trans";
					Display = "Transparency";
					Type = "int";
					Default = .5,
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					Context.PlayerUtils:SetCharacterTransparency(Player,Args.Trans)
				end
			end;
		},
		{
			Name = "invisible";
			Aliases = {"invis"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					Context.PlayerUtils:SetCharacterTransparency(Player,1)
				end
			end;
		},
		{
			Name = "ghostify";
			Aliases = {"ghost"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					Context.PlayerUtils:SetCharacterTransparency(Player,.9)
				end
			end;
		},
		{
			Name = "uninvisible";
			Aliases = {"uninvis","vis","unghost"};
			Rank = 1;
			Category = "Character";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
			};
			Run = function(runningPlr,Args)
				for _,Player in Args.Targets do
					Context.PlayerUtils:SetCharacterTransparency(Player,0)
				end
			end;
		},
		{
			Name = "notify";
			Aliases = {"h","hint","n","notif"};
			Rank = 1;
			Category = "System";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "Message";
					Type = "string";
				}
			};
			Run = function(runningPlr,Args)
				for _,Plr in Args.Targets do
					local filteredText = Context.Text:FilterFor(Args.Message,runningPlr.UserId,Plr.UserId)
					Context.Comm:SendTo(Plr,"Notify",{Text = filteredText,Time = 15,From = runningPlr.Name})
				end
			end;
		},
		{
			Name = "message";
			Aliases = {"m"};
			Rank = 1;
			Category = "System";
			Args = {
				{
					Name = "Targets";
					Display = "Player(s)";
					Type = "players";
				},
				{
					Name = "Message";
					Type = "string";
				}
			};
			Run = function(runningPlr,Args)
				for _,Plr in Args.Targets do
					local filteredText = Context.Text:FilterFor(Args.Message,runningPlr.UserId,Plr.UserId)
					Context.Comm:SendTo(Plr,"Message",{Text = filteredText,Time = 30,From = runningPlr.Name})
				end
			end;
		},
	}
	
	function Commands:processArg(Player,argString,argType,remainingArgs)
		if argType == "players" or argType == "player" then
			local selectedPlayers = {}
			
			if argString then
				local tokens = string.split(argString, ",")
				for _, token in ipairs(tokens) do
					local trimmedToken = token:match'^%s*(.*%S)' or ''
					
					if trimmedToken == "all" then
						for _, player in ipairs(PlayersService:GetPlayers()) do
							table.insert(selectedPlayers, player)
						end
					elseif trimmedToken == "me" or trimmedToken == "" or trimmedToken == "." then
						table.insert(selectedPlayers, Player)
					elseif trimmedToken == "others" then
						for _, player in ipairs(PlayersService:GetPlayers()) do
							if player ~= Player then
								table.insert(selectedPlayers, player)
							end
						end
					elseif string.sub(trimmedToken, 1, 1) == "-" then
						local playerName = string.sub(trimmedToken, 2)
						local playerToRemove = self:findPlayerByName(playerName)
						if playerToRemove then
							for i, player in ipairs(selectedPlayers) do
								if player == playerToRemove then
									table.remove(selectedPlayers, i)
									break
								end
							end
						end
					else
						local playerToAdd = self:findPlayerByName(trimmedToken)
						if playerToAdd then
							table.insert(selectedPlayers, playerToAdd)
						end
					end
				end
			else
				table.insert(selectedPlayers,Player)
			end

			if argType == "player" then
				return selectedPlayers[1]
			else
				return selectedPlayers
			end
		elseif argType == "userid" then
			if tonumber(argString) then
				return tonumber(argString)
			else
				local foundPlr = self:findPlayerByName(argString)
				
				if foundPlr then
					return foundPlr.UserId
				else
					if argString == "me" or argString == "." then
						return Player.UserId
					end
					
					local succ,UserId = pcall(function()
						return PlayersService:GetUserIdFromNameAsync(argString)
					end)
					
					if succ then
						return UserId
					else
						return 1
					end
				end
			end
		elseif argType == "boolean" then
			if string.lower(argString) == "true" or string.lower(argString) == "1" then
				return true
			elseif string.lower(argString) == "false" or string.lower(argString) == "0" then
				return false
			else
				return true, false
			end
		elseif argType == "number" then
			local numberValue = tonumber(argString)
			if numberValue then
				return numberValue
			else
				return 0, false
			end
		elseif argType == "int" then
			local intValue = tonumber(argString)
			if intValue then
				return math.floor(intValue)
			else
				return 0, false
			end
		elseif argType == "string" then
			return table.concat(remainingArgs, " ")
		elseif argType == "time" then
			local timeReturned,err = Context.Util:interpretTimeString(argString)
			
			if timeReturned then
				return timeReturned
			else
				return 0,err
			end
		else
			return argString  -- Default case: return the string itself
		end
	end
	
	function Commands:findPlayerByName(playerName)
		if playerName == nil then
			playerName = ""
		end
		
		for _, player in ipairs(PlayersService:GetPlayers()) do
			if string.lower(string.sub(player.Name, 1, #playerName)) == string.lower(playerName) then
				return player
			end
		end
		return nil
	end
	
	function Commands:runCommand(Player,cmdString)
		self:processCommand(Player,`{Context.Options.Prefix or "/"}{cmdString}`)
	end
	
	function Commands:processCommand(Player,cmdString)
		local globalPrefix = Context.Options.Prefix or ";"

		if string.sub(cmdString, 1, 1) == globalPrefix then
			cmdString = string.sub(cmdString, 2)
			local cmdSplit = string.split(cmdString, " ")
			local cmdName = cmdSplit[1]
			local cmdArgs = {table.unpack(cmdSplit, 2)}

			for _, Command in ipairs(self.Commands) do
				if Command.Disabled then continue end -- Skip disabled commands

				local runCommand = false

				-- Search for command name/alias
				if cmdName:lower() == Command.Name:lower() then
					runCommand = true
				else
					for _, Alias in ipairs(Command.Aliases or {}) do
						if cmdName:lower() == Alias:lower() then
							runCommand = true
							break
						end
					end
				end

				if runCommand then
					local processedArgs = {}
					for i, Arg in Command.Args do
						local remainingArgs = {table.unpack(cmdArgs, i)}
						local argValue, argSuccess = self:processArg(Player,cmdArgs[i], Arg.Type, remainingArgs)
												
						if argSuccess == false then
							if Arg.Default then
								argValue = Arg.Default
							end
						end
						
						processedArgs[Arg.Name] = argValue
					end

					-- Run the command with the processed arguments
					Command.Run(Player,processedArgs)
				end
			end
		end
	end
	
	function Commands:registerCommand(newCommand)
		table.insert(Commands.Commands,newCommand)

		if self:hasTag(newCommand,"Fun") and Context.Options.DisableFunCommands == true then
			newCommand.Disabled = true
		end
	end

	function Commands:Get() -- Returns all enabled commands
		local returnCommands = {}

		for _,Command in Commands.Commands do
			if Command.Disabled ~= true then
				table.insert(returnCommands,Command)
			end
		end

		return returnCommands
	end

	function Commands:disableTagged(Tag)
		for _,Command in Commands.Commands do
			if self:hasTag(Command,Tag) then
				Command.Disabled = true
			end
		end
	end

	function Commands:hasTag(Command,Tag)
		local commandTags = Command.Tags
		if commandTags then
			if table.find(commandTags,Tag) then
				return true
			end
		else
			return false
		end
	end
	
	function Commands:getCommand(commandName)
		for _,Command in self.Commands do
			if Command.Name == commandName then
				return Command
			else
				for _,Alias in Command.Aliases do
					if Alias == commandName then
						return Command
					end
				end
			end
		end
		
		return nil
	end
	
	function Commands.Start()
		-- Disable fun commands
		if Context.Options.DisableFunCommands then
			Commands:disableTagged("Fun")
		end
	end

	return Commands
end